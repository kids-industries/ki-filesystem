package filesystem;

private typedef BytesType = #if (sys || nodejs || macro) haxe.io.Bytes #else flash.utils.ByteArray #end;

class FileTools
{
	/**
	* Read file contents.
	**/
	public static function read(file : File) : BytesType
	{
		#if (sys || nodejs || macro)
		return sys.io.File.getBytes(file.path);
		#else
		var bytes = new flash.utils.ByteArray();

		var stream = new flash.filesystem.FileStream();
		stream.open(@:privateAccess file._flFile, flash.filesystem.FileMode.READ);

		while (stream.bytesAvailable > 0)
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
		#elseif nodejs
		appendString(file, bytes.getString(0, bytes.length));
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
		#else
		var stream = new flash.filesystem.FileStream();
		stream.open(@:privateAccess file._flFile, flash.filesystem.FileMode.APPEND);
		stream.writeUTFBytes(data);
		stream.close();
		#end
	}
}
