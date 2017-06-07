package filesystem;

import haxe.extern.EitherType;
import haxe.io.Path;

#if (!air || macro)
import sys.FileSystem;
#end

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
	* The file's name without extension.
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
	* The full file name, including extension.
	*
	* TESTED
	**/
	public var file(default, null) : String;

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
		{
			#if air
			path = 'app:/';
			#else
			path = "/";
			#end
		}
		#if air
		else if(path.startsWith("/"))
			path = path.substr(1);
		#end

		// TODO: Check triple slash on all platforms (I think Android has an issue with this)s
		// Ensure file:// protocol has a triple slash
		// path = PathUtil.fixProtocolTripleSlash(path);

		// TODO: Check spaces in path on all platforms
		// Ensure path is escaped of spaces
		// path = PathUtil.escapeSpaces(path);

		var p = new Path(path);
		this.name = p.file;
		this.dir = p.dir;
		this.ext = p.ext;
		this.file = name + (ext == null ? '' : '.$ext');

		#if (!macro && air)

		// Ensure paths are always absolute
		var proto = null;
		var protoPattern = ~/^(.*):\//gi;
		if(!protoPattern.match(path))
			path = 'app:/$path';
		else
			proto = protoPattern.matched(1);

		_flFile = new FlashFile(path);

		this.path = _flFile.url.urlDecode();

		if(proto != null && this.dir == '$proto:')
			this.dir = null;

		#else
		this.path = p.toString();
		#end

		this.isAbsolute = #if air true; #else Path.isAbsolute(this.path); #end
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
		#if (!macro && air)
		return resolvePath(pathOrSegments);
		#else
		var path = joinPaths(pathOrSegments);

		if(Path.isAbsolute(path))
			throwError('Input path ($path) is already absolute. Only relative path can be resolved into absolute paths.');

		return new File(FileSystem.absolutePath(path));
		#end
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

	/**
	* Copies the file or directory at the location specified by this File object
	* to the location specified by the dest parameter. The copy process creates
	* any required parent directories (if possible). When overwriting files
	* using copyTo(), the file attributes are also overwritten.
	*
	* TESTED
	**/
	public function copyTo(dest : File, overwrite : Bool = false) : Void
	{
		if(!isDirectory)
		{
			if(dest.exists)
			{
				if(!overwrite)
					throwError('Unable to copy onto existing file: ${dest.path}.');
				else
					dest.delete();
			}

			#if (!macro && air)
			_flFile.copyTo(dest._flFile, false);
			#else
			dest.getParent().createDirectory(true);
			sys.io.File.copy(path, dest.path);
			#end
		}
		else
		{
			var files : Array<File> = getDirectoryListing();

			var iL : Int = files.length;
			for(i in 0...iL)
			{
				var file : File = files[i];
				var targetPath : String = file.path.replace(path, dest.path);
				var targetFile : File = new File(targetPath);

				file.copyTo(targetFile, overwrite);
			}
		}
	}

	/**
	* Same as copyTo, expect the target must a be a directory and current 'file' name is retained.
	*
	* /directory/file.ext -> /other/directory/elsewhere
	* Results in file.ext to be cloned to /other/directory/elsewhere/file.ext
	* Same goes for directories
	*
	* /source/stuff -> /new/location
	* Results in 'stuff' to be cloned to /new/location/stuff
	*
	* TESTED
	**/
	public function copyInto(directory : File, overwrite : Bool = false) : Void
	{
		if(!overwrite && directory.exists && !directory.isDirectory)
			throwError('Can\'t copy into target existing file.');

		copyTo(directory.resolvePath(file), overwrite);
	}

	/**
	* Move to new location.
	*
	* TESTED
	**/
	public function moveTo(dest : File, overwrite : Bool = false) : Void
	{
		#if (!macro && air)
		_flFile.moveTo(dest._flFile, overwrite);
		#else
		if(overwrite && dest.exists)
			dest.delete();

		FileSystem.rename(path, dest.path);
		#end
	}

	/**
	* Deletes file or directory recursively.
	*
	* TESTED
	**/
	public function delete() : Void
	{
		if(!exists)
			return;

		if(isDirectory)
		{
			#if (!macro && air)
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
			#if (!macro && air)
			_flFile.deleteFile();
			#else
			FileSystem.deleteFile(path);
			#end
		}
	}

	/**
	* Creates directory optionally with parent directories as well.
	*
	* No action is taken if the directory exists.
	*
	* TESTED
	**/
	public function createDirectory(andParents : Bool = false) : Void
	{
		if(!exists)
		{
			var parent : File = getParent();
			if(andParents && !parent.exists)
				parent.createDirectory(true);

			if(parent.exists)
			{
				#if (!macro && air)
				_flFile.createDirectory();
				#else
				FileSystem.createDirectory(path);
				#end
			}
			else
				throwError('Parent directory doesn\'t exist: $path');
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

		#if (!macro && air)
		paths = [];
		var ff : Array<FlashFile> = _flFile.getDirectoryListing();
		var iL : Int = ff.length;
		for(i in 0...iL)
			paths.push(ff[i].url.urlDecode());
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
		#if (!macro && air)
		return _flFile.exists;
		#else
		return FileSystem.exists(path);
		#end
	}

	private function get_isDirectory() : Bool
	{
		if(!exists)
			return false;

		#if (!macro && air)
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