package flash.filesystem;
/*
	[Version("air2.0")]
	[native(cls="StorageVolumeInfoClass", instance="StorageVolumeInfoObject", methods="auto", construct="native")]
	[Event(name="storageVolumeUnmount", type="flash.events.StorageVolumeChangeEvent")]
	[Event(name="storageVolumeMount", type="flash.events.StorageVolumeChangeEvent")]
 */
extern class StorageVolumeInfo
{
	function getStorageVolumes() : Array<StorageVolume>;

	//[Version("air2.0")]
	static var isSupported(default, null) : Bool;

	static var storageVolumeInfo(default, null) : StorageVolumeInfo;
}
