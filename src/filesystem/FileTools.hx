package filesystem;

class FileTools
{
	#if (air || openfl)

	public static function read(file : File) : flash.utils.ByteArray
	{
		var bytes = new flash.utils.ByteArray();

		var stream = new flash.filesystem.FileStream();
		stream.open(@:privateAccess file._flFile, flash.filesystem.FileMode.READ);

		while(stream.bytesAvailable > 0)
			stream.readBytes(bytes, cast stream.position, cast stream.bytesAvailable);
		stream.close();

		return bytes;
	}

	public static function readString(file : File) : String
	{
		var bytes = read(file);
		bytes.position = 0;
		return bytes.readUTFBytes(bytes.length);
	}

	public static function write(file : File, bytes : flash.utils.ByteArray) : Void
	{
		var stream = new flash.filesystem.FileStream();
		stream.open(@:privateAccess file._flFile, flash.filesystem.FileMode.WRITE);
		stream.writeBytes(bytes);
		stream.close();
	}

	public static function writeString(file : File, data : String) : Void
	{
		var stream = new flash.filesystem.FileStream();
		stream.open(@:privateAccess file._flFile, flash.filesystem.FileMode.WRITE);
		stream.writeUTFBytes(data);
		stream.close();
	}

	public static function append(file : File, bytes : flash.utils.ByteArray) : Void
	{
		var stream = new flash.filesystem.FileStream();
		stream.open(@:privateAccess file._flFile, flash.filesystem.FileMode.APPEND);
		stream.writeBytes(bytes);
		stream.close();
	}

	public static function appendString(file : File, data : String) : Void
	{
		var stream = new flash.filesystem.FileStream();
		stream.open(@:privateAccess file._flFile, flash.filesystem.FileMode.APPEND);
		stream.writeUTFBytes(data);
		stream.close();
	}

	#else

	/**
	* Read file contents.
	**/
	public static function read(file : File) : haxe.io.Bytes
	{
		return sys.io.File.getBytes(file.path);
	}

	/**
	* Read file contents as String.
	**/
	public static function readString(file : File) : String
	{
		return sys.io.File.getContent(file.path);
	}

	/**
	* Write file contents.
	**/
	public static function write(file : File, bytes : haxe.io.Bytes) : Void
	{
		sys.io.File.saveBytes(file.path, bytes);
	}

	/**
	* Write file contents as String.
	**/
	public static function writeString(file : File, data : String) : Void
	{
		sys.io.File.saveContent(file.path, data);
	}

	/**
	* Append onto file.
	*
	* Non-existant file will be created.
	**/
	public static function append(file : File, bytes : haxe.io.Bytes) : Void
	{
		#if nodejs
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
		#if nodejs
		js.node.Fs.appendFileSync(file.path, data, 'a');
		#else
		var output = sys.io.File.append(file.path, true);
		output.writeString(data);
		output.close();
		#end
	}

	#end
}
