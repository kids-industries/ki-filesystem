package flash.filesystem;

import flash.events.EventDispatcher;
import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;

/*
	[API("661")]
	[native(cls="FileStreamClass", instance="FileStreamObject", methods="auto", construct="check")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="outputProgress", type="flash.events.OutputProgressEvent")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="close", type="flash.events.Event")]
 */
extern class FileStream extends EventDispatcher implements IDataInput implements IDataOutput
{
	var bytesAvailable(default, null) : UInt;

	var endian : Endian;

	var objectEncoding : UInt;

	var position : Float;

	var readAhead : Float;

	function close() : Void;

	function open(file : File, fileMode : FileMode) : Void;

	function openAsync(file : File, fileMode : FileMode) : Void;

	function readBoolean() : Bool;

	function readByte() : Int;

	function readBytes(bytes : ByteArray, offset : UInt = 0, length : UInt = 0) : Void;

	function readDouble() : Float;

	function readFloat() : Float;

	function readInt() : Int;

	function readMultiByte(length : UInt, charSet : String) : String;

	function readObject() : Dynamic;

	function readShort() : Int;

	function readUTF() : String;

	function readUTFBytes(length : UInt) : String;

	function readUnsignedByte() : UInt;

	function readUnsignedInt() : UInt;

	function readUnsignedShort() : UInt;

	function truncate() : Void;

	function writeBoolean(value : Bool) : Void;

	function writeByte(value : Int) : Void;

	function writeBytes(bytes : ByteArray, offset : UInt = 0, length : UInt = 0) : Void;

	function writeDouble(value : Float) : Void;

	function writeFloat(value : Float) : Void;

	function writeInt(value : Int) : Void;

	function writeMultiByte(value : String, charSet : String) : Void;

	function writeObject(object : Dynamic) : Void;

	function writeShort(value : Int) : Void;

	function writeUTF(value : String) : Void;

	function writeUTFBytes(value : String) : Void;

	function writeUnsignedInt(value : UInt) : Void;
}
