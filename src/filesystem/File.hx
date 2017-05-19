package filesystem;

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

	public function new(path : String)
	{
		if(path == null)
			throw 'Can\'t create File with null path';

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

		if(path == "" || path == "/")
			path = "app:/";
		_flFile = new FlashFile(path);

		this.path = _flFile.url;

		#end

		this.name = p.file;
		this.dir = p.dir;
		this.ext = p.ext;
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
	**/
	public function resolvePath(pathOrPaths : EitherType<String, Array<String>>) : File
	{
		if(Std.is(pathOrPaths, String))
			return new File(Path.join([toString(), pathOrPaths]));

		return new File(Path.join([toString()].concat(pathOrPaths)));
	}

	public function getParent() : File
	{
		return new File(Path.addTrailingSlash(Path.join([toString(), "../"])));
	}

	public function copyTo(dest : File, overwrite : Bool = false) : Void
	{
		#if air
		_flFile.copyTo(dest._flFile, overwrite);
		#else
		if(overwrite && dest.exists)
			dest.delete();

		if(!isDirectory)
			sys.io.File.copy(toString(), dest.toString());
		else
		{
			// Create target directory
			dest.createDirectory();

			var files : Array<File> = getDirectoryListing();
			var basePath : String = toString();
			var targetBasePath : String = dest.toString();

			var iL : Int = files.length;
			for(i in 0...iL)
			{
				var file : File = files[i];
				var targetPath : String = file.toString().replace(basePath, targetBasePath);
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

		FileSystem.rename(toString(), dest.toString());
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

			FileSystem.deleteDirectory(toString());
			#end
		}
		else
		{
			#if air
			_flFile.deleteFile();
			#else
			FileSystem.deleteFile(toString());
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
				FileSystem.createDirectory(toString());
				#end
			}
			else
				throw "Parent directory doesn't exist: " + toString();
		}
	}

	public function getDirectoryListing(recursive : Bool = false) : Array<File>
	{
		if(!exists)
			throw "Can't get directory listing on a non-existant File: " + toString();

		if(!isDirectory)
			throw "Can't get directory listing on a file: " + toString();

		var paths : Array<String>;
		var files : Array<File> = [];

		#if air
		paths = [];
		var ff : Array<FlashFile> = _flFile.getDirectoryListing();
		var iL : Int = ff.length;
		for(i in 0...iL)
			paths.push(ff[i].url);
		#else
		var path : String = toString();
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
	**/
	public inline function clone() : File
	{
		return new File(toString());
	}

	/**
	* Get path as string.
	**/
	public inline function toString() : String
	{
		return path;
	}

	private function get_exists() : Bool
	{
		#if air
		return _flFile.exists;
		#else
		return FileSystem.exists(toString());
		#end
	}

	private function get_isDirectory() : Bool
	{
		if(!exists)
			return false;

		#if air
		return _flFile.isDirectory;
		#else
		return FileSystem.isDirectory(toString());
		#end
	}
}