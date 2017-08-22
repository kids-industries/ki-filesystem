package filesystem;

private typedef BytesType = #if (air || openfl) flash.utils.ByteArray #else haxe.io.Bytes #end;

class FileTools
{
	/**
	* Read file contents.
	**/
	public static function read(file : File) : BytesType
	{
		#if (air || openfl)
		var bytes = new flash.utils.ByteArray();

		var stream = new flash.filesystem.FileStream();
		stream.open(@:privateAccess file._flFile, flash.filesystem.FileMode.READ);

		while(stream.bytesAvailable > 0)
			stream.readBytes(bytes, cast stream.position, cast stream.bytesAvailable);
		stream.close();

		return bytes;
		#else
		return sys.io.File.getBytes(file.path);
		#end
	}

	/**
	* Read file contents as String.
	**/
	public static function readString(file : File) : String
	{
		#if (air || openfl)
		var bytes = read(file);
		bytes.position = 0;
		return bytes.readUTFBytes(bytes.length);
		#else
		return sys.io.File.getContent(file.path);
		#end
	}

	/**
	* Write file contents.
	**/
	public static function write(file : File, bytes : BytesType) : Void
	{
		#if (air || openfl)
		var stream = new flash.filesystem.FileStream();
		stream.open(@:privateAccess file._flFile, flash.filesystem.FileMode.WRITE);
		stream.writeBytes(bytes);
		stream.close();
		#else
		sys.io.File.saveBytes(file.path, bytes);
		#end
	}

	/**
	* Write file contents as String.
	**/
	public static function writeString(file : File, data : String) : Void
	{
		#if (air || openfl)
		var stream = new flash.filesystem.FileStream();
		stream.open(@:privateAccess file._flFile, flash.filesystem.FileMode.WRITE);
		stream.writeUTFBytes(data);
		stream.close();
		#else
		sys.io.File.saveContent(file.path, data);
		#end
	}

	/**
	* Append onto file.
	*
	* Non-existant file will be created.
	**/
	public static function append(file : File, bytes : BytesType) : Void
	{
		#if (air || openfl)
		var stream = new flash.filesystem.FileStream();
		stream.open(@:privateAccess file._flFile, flash.filesystem.FileMode.APPEND);
		stream.writeBytes(bytes);
		stream.close();
		#elseif nodejs
		appendString(file, bytes.getString(0, bytes.length));
		#else
		var output = sys.io.File.append(file.path, true);
		output.write(bytes);
		output.close();
		#end
	}

	/**
	* Append onto file as String.
	*
	* Non-existant file will be created.
	**/
	public static function appendString(file : File, data : String) : Void
	{
		#if (air || openfl)
		var stream = new flash.filesystem.FileStream();
		stream.open(@:privateAccess file._flFile, flash.filesystem.FileMode.APPEND);
		stream.writeUTFBytes(data);
		stream.close();
		#elseif nodejs
		js.node.Fs.appendFileSync(file.path, data);
		#else
		var output = sys.io.File.append(file.path, true);
		output.writeString(data);
		output.close();
		#end
	}
}
