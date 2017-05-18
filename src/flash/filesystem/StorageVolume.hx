package flash.filesystem;

//[Version("air2.0")]
extern class StorageVolume
{
	function new(rootDirPath : File, name : String, writable : Bool, removable : Bool, fileSysType : String, drive : String) : Void;

	var drive(default, null) : String;

	var fileSystemType(default, null) : String;

	var isRemovable(default, null) : Bool;

	var isWritable(default, null) : Bool;

	var name(default, null) : String;

	var rootDirectory(default, null) : File;
}
