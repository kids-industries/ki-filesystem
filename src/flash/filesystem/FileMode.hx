package flash.filesystem;
/*class FileMode
{
	public static inline var READ : String = "read";
	public static inline var WRITE : String = "write";
	public static inline var UPDATE : String = "update";
	public static inline var APPEND : String = "append";
}*/
@:fakeEnum(String) extern enum FileMode
{
	READ;
	WRITE;
	UPDATE;
	APPEND;
}