package filesystem;

import haxe.macro.Context;
import haxe.extern.EitherType;
import haxe.io.Path;
import sys.FileSystem;

using StringTools;

#if (!macro && air)
private typedef FlashFile = flash.filesystem.File;
#end

class File
{
	/**
	* The resolved path. Note this might differ from the instanciated
	* value based on platform.
	*
	* TESTED
	**/
	public var path(default, null) : String;

	/**
	* The file name.
	*
    * This is the part of the part between the directory and the extension.
	*
    * If there is no file name, e.g. for ".htaccess" or "/dir/", the value
	* is the empty String "".
	*
	* TESTED
	**/
	public var name(default, null) : String;

	/**
	* The directory.
	*
	* This is the leading part of the path that is not part of the file name
	* and the extension.
	*
	* Does not end with a `/` or `\` separator.
	* If the path has no directory, the value is null.
	*
	* TESTED
	**/
	public var dir(default, null) : String;

	/**
	* The file extension.
	*
	* It is separated from the file name by a dot. This dot is not part of
	* the extension.
	*
	* If the path has no extension, the value is null.
	*
	* TESTED
	**/
	public var ext(default, null) : String;

	/**
	* Whether the path is absolute or relative.
	*
	* TESTED
	**/
	public var isAbsolute(default, null) : Bool;

	/**
	* Checks if the file exists on disk.
	*
	* !!Performs IO!!
	*
	* TESTED
	**/
	public var exists(get, never) : Bool;

	/**
	* Checks if the given path is a file or directory.
	* This value will only be true if it's an directory that exists on disk, otherwise false.
	*
	* !!Performs IO!!
	*
	* TESTED
	**/
	public var isDirectory(get, never) : Bool;

	#if (!macro && air)
	private var _flFile : FlashFile;
	#end

	/**
	* Constructor, note that NO I/O will be performed on construction.
	**/
	public function new(path : String)
	{
		if(path == null)
			throwError('Can\'t create File with null path.');

		// TODO: ./ or / ?????
		if(path == "")
			path = "/";

		// TODO: Check triple slash on all platforms (I think Android has an issue with this)s
		// Ensure file:// protocol has a triple slash
		// path = PathUtil.fixProtocolTripleSlash(path);

		// TODO: Check spaces in path on all platforms
		// Ensure path is escaped of spaces
		// path = PathUtil.escapeSpaces(path);

		var p = new Path(path);

		#if (cpp || cs || hl || java || lua || macro || neko || php || python)

		this.path = p.toString();

		#elseif air

		if(path == "/")
			path = "app:/";
		_flFile = new FlashFile(path);

		this.path = _flFile.url;

		#end

		this.name = p.file;
		this.dir = p.dir;
		this.ext = p.ext;
		this.isAbsolute = Path.isAbsolute(this.path);
	}

	/**
	* Creates a new File object with a path relative to this File object's path, based on the path parameter (a string).
	*
	* You can use a relative path or absolute path as the path parameter.
	*
	* If you specify a relative path, the given path is "appended" to the path of the File object. However, use of ".." in the path can return a resulting path that is not a child of the File object. The resulting reference need not refer to an actual file system location.
	*
	* If you specify an absolute file reference, the method returns the File object pointing to that path. The absolute file reference should use valid native path syntax for the user's operating system (such as "C:\\test" on Windows). Do not use a URL (such as "file:///c:/test") as the path parameter.
	*
	* All resulting paths are normalized as follows:
	*    Any "." element is ignored.
	*    Any ".." element consumes its parent entry.
	*    No ".." reference that reaches the file system root or the application-persistent storage root passes that node; it is ignored.
	*
	* You should always use the forward slash (/) character as the path separator. On Windows, you can also use the backslash (\) character, but you should not. Using the backslash character can lead to applications that do not work on other platforms.
	*
	* Filenames and directory names are case-sensitive on non-Windows.
	*
	* IMPLICIDLY TESTED
	**/
	public function resolvePath(pathOrSegments : EitherType<String, Array<String>>) : File
	{
		return new File(joinPaths(pathOrSegments));
	}

	/**
	* Resolve absolute path. Same as resolvePath, but the File instance's path will be the full system path.
	*
	* TESTED
	**/
	public function resolveAbsolutePath(pathOrSegments : EitherType<String, Array<String>>) : File
	{
		var path = joinPaths(pathOrSegments);

		if(Path.isAbsolute(path))
			throwError('Input path ($path) is already absolute. Only relative path can be resolved into absolute paths.');

		#if air
		throwNotImplemented("resolveAbsolutePath");
		#else
		path = FileSystem.absolutePath(path);
		#end

		return new File(path);
	}

	/**
	* Get the parent file instance, same as '../' for directories.
	* Non directories will be return the parent directory.
	*
	* TESTED
	**/
	public function getParent() : File
	{
		var path = Path.join([path, "../"]);
		if(!isAbsolute && path == "")
			throwError('Can\'t step out of CWD, use resolveAbsolutePath("../") instead.');
		return new File(path);
	}

	public function copyTo(dest : File, overwrite : Bool = false) : Void
	{
		#if air
		_flFile.copyTo(dest._flFile, overwrite);
		#else
		if(overwrite && dest.exists)
			dest.delete();

		if(!isDirectory)
			sys.io.File.copy(path, dest.path);
		else
		{
			// Create target directory
			dest.createDirectory();

			var files : Array<File> = getDirectoryListing();
			var basePath : String = path;
			var targetBasePath : String = dest.path;

			var iL : Int = files.length;
			for(i in 0...iL)
			{
				var file : File = files[i];
				var targetPath : String = file.path.replace(basePath, targetBasePath);
				var targetFile : File = new File(targetPath);

				file.copyTo(targetFile, overwrite);
			}
		}
		#end
	}

	public function moveTo(dest : File, overwrite : Bool = false) : Void
	{
		#if air
		_flFile.moveTo(dest._flFile, overwrite);
		#else
		if(overwrite && dest.exists)
			dest.delete();

		FileSystem.rename(path, dest.path);
		#end
	}

	public function delete() : Void
	{
		if(!exists)
			return;

		if(isDirectory)
		{
			#if air
			_flFile.deleteDirectory(true);
			#else
			var files : Array<File> = getDirectoryListing(false);

			// Delete the children first
			while(files.length > 0)
				files.pop().delete();

			FileSystem.deleteDirectory(path);
			#end
		}
		else
		{
			#if air
			_flFile.deleteFile();
			#else
			FileSystem.deleteFile(path);
			#end
		}
	}

	public function createDirectory(andParents : Bool = false) : Void
	{
		if(!exists)
		{
			var parent : File = getParent();
			if(andParents && !parent.exists)
				parent.createDirectory(true);

			if(parent.exists)
			{
				#if air
				_flFile.createDirectory();
				#else
				FileSystem.createDirectory(path);
				#end
			}
			else
				throw "Parent directory doesn't exist: " + path;
		}
	}

	/**
	* Get all files and folders in directory.
	*
	* TESTED
	**/
	public function getDirectoryListing(recursive : Bool = false) : Array<File>
	{
		if(!exists)
			throwError('Can\'t get directory listing on a non-existant File: $path');

		if(!isDirectory)
			throwError('Can\'t get directory listing on a file: $path');

		var paths : Array<String>;
		var files : Array<File> = [];

		#if air
		paths = [];
		var ff : Array<FlashFile> = _flFile.getDirectoryListing();
		var iL : Int = ff.length;
		for(i in 0...iL)
			paths.push(ff[i].url);
		#else
		var path : String = path;
		paths = FileSystem.readDirectory(path);

		var iL : Int = paths.length;
		for(i in 0...iL)
			paths[i] = Path.join([path, paths[i]]);
		#end

		var iL : Int = paths.length;
		for(i in 0...iL)
			files.push(new File(paths[i]));

		if(recursive)
		{
			var subFiles : Array<File> = [];
			for(i in 0...iL)
			{
				var subFile : File = files[i];
				if(subFile.isDirectory)
					subFiles = subFiles.concat(subFile.getDirectoryListing(true));
			}

			files = files.concat(subFiles);
		}

		return files;
	}

	/**
	* Create new File instance from this instance.
	*
	* TESTED
	**/
	public inline function clone() : File
	{
		return new File(path);
	}

	/**
	* Get path as string.
	*
	* TESTED
	**/
	public inline function toString() : String
	{
		return path;
	}

	//--------------------------------------------------------------------------------------------------------------------------------//
	// BOILERPLATE
	//--------------------------------------------------------------------------------------------------------------------------------//

	private function get_exists() : Bool
	{
		#if air
		return _flFile.exists;
		#else
		return FileSystem.exists(path);
		#end
	}

	private function get_isDirectory() : Bool
	{
		if(!exists)
			return false;

		#if air
		return _flFile.isDirectory;
		#else
		return FileSystem.isDirectory(path);
		#end
	}

	//--------------------------------------------------------------------------------------------------------------------------------//
	// UTILS
	//--------------------------------------------------------------------------------------------------------------------------------//

	/**
	* Join path or segements
	**/
	private function joinPaths(pathOrSegments : EitherType<String, Array<String>>) : String
	{
		if(Std.is(pathOrSegments, String))
			return Path.join([path, pathOrSegments]);

		return Path.join([path].concat(pathOrSegments));
	}

	//--------------------------------------------------------------------------------------------------------------------------------//
	// ERRORS
	//--------------------------------------------------------------------------------------------------------------------------------//
	/**
	* Throw and error with a message. Generic prefix will be added.
	**/
	private static macro function throwError(msg : String)
	{
		return macro {
			throw '[${Type.getClassName(File)}] $msg';
		};
	}

	/**
	* Not Implemented Error.
	**/
	private static inline function throwNotImplemented(msg : String) : Void
	{
		throwError('Not Implemented: $msg');
	}
}