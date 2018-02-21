package filesystem;

import haxe.macro.Expr;
private typedef BytesType = #if (sys || nodejs || phantomjs || macro) haxe.io.Bytes #else flash.utils.ByteArray #end;

class FileTools
{
	/**
	* Read file contents.
	**/
	public static function read(file : File) : BytesType
	{
		#if (sys || nodejs || macro)
		return sys.io.File.getBytes(file.path);
		#elseif phantomjs
		return haxe.io.Bytes.ofString(readString(file));
		#else
		var bytes = new flash.utils.ByteArray();

		var stream = new flash.filesystem.FileStream();
		stream.open(@:privateAccess file._flFile, flash.filesystem.FileMode.READ);

		while(stream.bytesAvailable > 0)
			stream.readBytes(bytes, cast stream.position, cast stream.bytesAvailable);
		stream.close();

		return bytes;
		#end
	}

	/**
	* Read file contents as String.
	**/
	public static function readString(file : File) : String
	{
		#if (sys || nodejs || macro)
		return sys.io.File.getContent(file.path);
		#elseif phantomjs
		return js.phantomjs.FileSystem.read(file.path);
		#else
		var bytes = read(file);
		bytes.position = 0;
		return bytes.readUTFBytes(bytes.length);
		#end
	}

	/**
	* Write file contents.
	**/
	public static function write(file : File, bytes : BytesType) : Void
	{
		#if (sys || nodejs || macro)
		sys.io.File.saveBytes(file.path, bytes);
		#elseif phantomjs
		writeString(file, bytes.toString());
		#else
		var stream = new flash.filesystem.FileStream();
		stream.open(@:privateAccess file._flFile, flash.filesystem.FileMode.WRITE);
		stream.writeBytes(bytes);
		stream.close();
		#end
	}

	/**
	* Write file contents as String.
	**/
	public static function writeString(file : File, data : String) : Void
	{
		#if (sys || nodejs || macro)
		sys.io.File.saveContent(file.path, data);
		#elseif phantomjs
		js.phantomjs.FileSystem.write(file.path, data, 'w');
		#else
		var stream = new flash.filesystem.FileStream();
		stream.open(@:privateAccess file._flFile, flash.filesystem.FileMode.WRITE);
		stream.writeUTFBytes(data);
		stream.close();
		#end
	}

	/**
	* Append onto file.
	*
	* Non-existant file will be created.
	**/
	public static function append(file : File, bytes : BytesType) : Void
	{
		#if (sys || macro)
		var output = sys.io.File.append(file.path, true);
		output.write(bytes);
		output.close();
		#elseif (nodejs || phantomjs)
		appendString(file, bytes.toString());
		#else
		var stream = new flash.filesystem.FileStream();
		stream.open(@:privateAccess file._flFile, flash.filesystem.FileMode.APPEND);
		stream.writeBytes(bytes);
		stream.close();
		#end
	}

	/**
	* Append onto file as String.
	*
	* Non-existant file will be created.
	**/
	public static function appendString(file : File, data : String) : Void
	{
		#if (sys || macro)
		var output = sys.io.File.append(file.path, true);
		output.writeString(data);
		output.close();
		#elseif nodejs
		js.node.Fs.appendFileSync(file.path, data);
		#elseif phantomjs
		js.phantomjs.FileSystem.write(file.path, data, 'a');
		#else
		var stream = new flash.filesystem.FileStream();
		stream.open(@:privateAccess file._flFile, flash.filesystem.FileMode.APPEND);
		stream.writeUTFBytes(data);
		stream.close();
		#end
	}

	/**
	* Read file last modified time.
	**/
	public static function getModificationDate(file : File) : Date
	{
		if(!file.exists) throwOperationNotAllowedOnNonexistant(file);

		#if (sys || nodejs || macro)
		return sys.FileSystem.stat(file.path).mtime;
		#elseif phantomjs
		return js.Lib.require('fs').lastModified(file.path);
		#else
		return @:privateAccess file._flFile.modificationDate;
		#end
	}

	/**
	* Read file or directory size.
	**/
	public static function getSize(file : File) : Int
	{
		if(file.isDirectory)
		{
			var total = 0;
			for(file in file.getDirectoryListing())
				total += getSize(file);

			return total;
		}

		if(!file.exists) throwOperationNotAllowedOnNonexistant(file);

		#if (sys || nodejs || macro)
		return sys.FileSystem.stat(file.path).size;
		#elseif phantomjs
		return js.phantomjs.FileSystem.size(file.path);
		#else
		return cast @:privateAccess file._flFile.size;
		#end
	}

	//--------------------------------------------------------------------------------------------------------------------------------//
	// ERRORS
	//--------------------------------------------------------------------------------------------------------------------------------//
	/**
	* Throw an error with a message. Generic prefix will be added.
	**/
	private static macro function throwError(msg : String) : Expr
	{
		var prefix : String = '[${Type.getClassName(File)}] ';
		return macro {
			throw $v{prefix} + '${msg}';
		};
	}

	/**
	* Throw error for operation attempt on non-existant file.
	**/
	private static inline function throwOperationNotAllowedOnNonexistant(file : File) : Void
	{
		throwError('Operation not allowed on non-existant file: $file');
	}
}
