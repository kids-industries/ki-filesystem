package flash.filesystem;

import flash.net.FileReference;

/*
	[API("661")]
	[native(cls="FileClass", instance="FileObject", methods="auto")]
	[Event(name="directoryListing", type="flash.events.FileListEvent")]
	[Event(name="selectMultiple", type="flash.events.FileListEvent")]
	[Event(name="select", type="flash.events.Event")]
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="cancel", type="flash.events.Event")]
 */
extern class File extends FileReference
{
	static var applicationDirectory(default, never) : File;
	static var applicationStorageDirectory(default, never) : File;
	static var cacheDirectory(default, never) : File;
	static var desktopDirectory(default, never) : File;
	static var documentsDirectory(default, never) : File;
	static var userDirectory(default, never) : File;

	static var lineEnding(default, never) : String;
	static var systemCharset(default, never) : String;
	static var separator(default, never) : String;

	static function createTempDirectory() : File;
	static function createTempFile() : File;
	static function getRootDirectories() : Array<File>;

	var parent(default, never) : File;

	var nativePath : String;
	var url : String;

	var exists(default, never) : Bool;
	var downloaded : Bool;

	var isDirectory(default, never) : Bool;
	var isHidden(default, never) : Bool;
	var isPackage(default, never) : Bool;
	var isSymbolicLink(default, never) : Bool;

	var preventBackup : Bool;
	var spaceAvailable(default, never) : Float;

	function new(path : String = null) : Void;

	function clone() : File;

	function browseForDirectory(title : String) : Void;
	function browseForOpen(title : String, typeFilter : Array<Dynamic> = null) : Void;
	function browseForOpenMultiple(title : String, typeFilter : Array<Dynamic> = null) : Void;
	function browseForSave(title : String) : Void;

	function canonicalize() : Void;

	function copyTo(newLocation : FileReference, overwrite : Bool = false) : Void;
	function copyToAsync(newLocation : FileReference, overwrite : Bool = false) : Void;

	function moveTo(newLocation : FileReference, overwrite : Bool = false) : Void;
	function moveToAsync(newLocation : FileReference, overwrite : Bool = false) : Void;
	function moveToTrash() : Void;
	function moveToTrashAsync() : Void;

	function createDirectory() : Void;
	function deleteDirectory(deleteDirectoryContents : Bool = false) : Void;
	function deleteDirectoryAsync(deleteDirectoryContents : Bool = false) : Void;

	function deleteFile() : Void;
	function deleteFileAsync() : Void;

	function getDirectoryListing() : Array<File>;
	function getDirectoryListingAsync() : Void;

	function resolvePath(path : String) : File;
	function getRelativePath(ref : FileReference, useDotDot : Bool = false) : String;

	function openWithDefaultApplication() : Void;

	// FIXME: file.icon not implemented
	//var icon() : Icon;
}
