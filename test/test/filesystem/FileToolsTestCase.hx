package test.filesystem;

import filesystem.File;
import tink.CoreApi.Noise;
import tink.testrunner.Case.BasicCase;
import tink.unit.AssertionBuffer;

using filesystem.FileTools;

class FileToolsTestCase extends BasicCase
{
	private static inline var ROOT : String = #if air 'app:/' + #end 'test-data';

	private static inline var LOREM_IPSUM : String = 'Lorem Ipsum';
	private static inline var LOREM_IPSUM_TXT : String = LOREM_IPSUM + '.' + TXT;

	private static inline var TXT : String = 'txt';
	private static inline var SUB_FOLDER_01 : String = 'sub-folder-01';

	private var _root : File;

	private var _loremIpsumTxt : File;

	private var _playground : File;

	private var _loremIpsumTxtContent : String = CompileTime.readFile('test-data/Lorem Ipsum.txt');

	//--------------------------------------------------------------------------------------------------------------------------------//
	// SETUP
	//--------------------------------------------------------------------------------------------------------------------------------//
	@:before
	public function setup()
	{
		_root = new File(ROOT);

		_loremIpsumTxt = _root.resolvePath(LOREM_IPSUM_TXT);

		#if air
		_playground = new File('app-storage:/test-data');
		#else
		_playground = _root.resolvePath(['../', 'bin', 'test-data']);
		#end

		return Noise;
	}

	@:after
	public function tearDown()
	{
		// Try and clean up test-data after each test
		#if air
		_playground = new File('app-storage:/test-data');
		#else
		_playground = _root.resolvePath(['../', 'bin', 'test-data']);
		#end
		if(_playground.exists)
			_playground.delete();

		_playground = null;

		_root = null;
		_loremIpsumTxt = null;

		return Noise;
	}

	//--------------------------------------------------------------------------------------------------------------------------------//
	// READ
	//--------------------------------------------------------------------------------------------------------------------------------//

	public function testRead()
	{
		var buffer = new AssertionBuffer();

		var bytes = _loremIpsumTxt.read();

		buffer.assert(isNotNull(bytes));
		#if openfl
		buffer.assert(isTrue(Std.is(bytes, openfl.utils.ByteArray)));
		#elseif air
		buffer.assert(isTrue(Std.is(bytes, flash.utils.ByteArray)));
		#else
		buffer.assert(isTrue(Std.is(bytes, haxe.io.Bytes)));
		#end

		return buffer.done();
	}

	public function testReadString()
	{
		var buffer = new AssertionBuffer();

		var data = _loremIpsumTxt.readString();

		buffer.assert(isNotNull(data));
		buffer.assert(isNotEqual(data, ""));
		buffer.assert(isEqual(data, _loremIpsumTxtContent));

		return buffer.done();
	}

	//--------------------------------------------------------------------------------------------------------------------------------//
	// WRITE
	//--------------------------------------------------------------------------------------------------------------------------------//
	public function testWrite()
	{
		_playground.createDirectory(true);

		var buffer = new AssertionBuffer();

		var targetFile = _playground.resolvePath('target.txt');
		var source = _loremIpsumTxt.read();
		var sourceTxt = _loremIpsumTxt.readString();

		targetFile.write(source);

		var target = targetFile.readString();

		buffer.assert(isNotNull(target));
		buffer.assert(isEqual(target, sourceTxt));

		return buffer.done();
	}

	public function testWriteString()
	{
		_playground.createDirectory(true);

		var buffer = new AssertionBuffer();

		var targetFile = _playground.resolvePath('target.txt');
		var source = _loremIpsumTxt.read();
		var sourceTxt = _loremIpsumTxt.readString();

		targetFile.writeString(sourceTxt);

		var target = targetFile.readString();

		buffer.assert(isNotNull(target));
		buffer.assert(isEqual(target, sourceTxt));

		return buffer.done();
	}

	public function testAppend()
	{
		_playground.createDirectory(true);

		var buffer = new AssertionBuffer();

		var targetFile = _playground.resolvePath('target.txt');
		var source = _loremIpsumTxt.read();
		var sourceTxt = _loremIpsumTxt.readString();

		targetFile.append(source);
		targetFile.append(source);

		var target = targetFile.readString();

		buffer.assert(isNotNull(target));
		buffer.assert(isEqual(target, sourceTxt + sourceTxt));

		return buffer.done();
	}

	public function testAppendString()
	{
		_playground.createDirectory(true);

		var buffer = new AssertionBuffer();

		var targetFile = _playground.resolvePath('target.txt');
		var source = _loremIpsumTxt.read();
		var sourceTxt = _loremIpsumTxt.readString();

		targetFile.appendString(sourceTxt);
		targetFile.appendString(sourceTxt);

		var target = targetFile.readString();

		buffer.assert(isNotNull(target));
		buffer.assert(isEqual(target, sourceTxt + sourceTxt));

		return buffer.done();
	}

	public function testGetModificationDate()
	{
		_playground.createDirectory(true);

		var buffer = new AssertionBuffer();

		var targetFile = _playground.resolvePath('modtime.txt');

		//TODO: Python date handling
		targetFile.writeString('modtimetest');
		var modNowDate : Date = Date.now();

		buffer.assert(isEqual(targetFile.getModificationDate().toString(), modNowDate.toString()));

		return buffer.done();
	}

	public function testGetModificationDate_NonExistantFile()
	{
		_playground.createDirectory(true);

		var buffer = new AssertionBuffer();
		var isNoFileError = false;

		var targetFile = _playground.resolvePath('nofile.txt');

		try
		{
			targetFile.getModificationDate();
		}
		catch(err : Dynamic)
		{
			if(err != null) isNoFileError = true;
		}

		buffer.assert(isTrue(isNoFileError));

		return buffer.done();
	}

	public function testGetModificationDate_Directory()
	{
		_playground.createDirectory(true);
		var modNowDate : Date = Date.now();

		var buffer = new AssertionBuffer();

		buffer.assert(isEqual(_playground.getModificationDate().toString(), modNowDate.toString()));

		return buffer.done();
	}

	public function testGetSize()
	{
		var buffer = new AssertionBuffer();

		var expectedSize : Int = 2653;

		buffer.assert(isEqual(expectedSize, _loremIpsumTxt.getSize()));

		return buffer.done();
	}

	public function testGetSize_NonExistantFile()
	{
		_playground.createDirectory(true);
		var buffer = new AssertionBuffer();
		var isNoFileError = false;

		var targetFile = _playground.resolvePath('nofile.txt');
		try
		{
			targetFile.getSize();
		}
		catch(err : Dynamic)
		{
			if(err != null) isNoFileError = true;
		}

		buffer.assert(isTrue(isNoFileError));

		return buffer.done();
	}

	public function testGetSize_Directory()
	{
		var subFol = _root.resolvePath(SUB_FOLDER_01);

		_playground.createDirectory(true);
		_loremIpsumTxt.copyInto(_playground);
		subFol.copyInto(_playground, true);

		var buffer = new AssertionBuffer();

		var expectedSize : Int = 5306;

		buffer.assert(isEqual(expectedSize, _playground.getSize()));

		return buffer.done();
	}

	//--------------------------------------------------------------------------------------------------------------------------------//
	// HELPERS
	//--------------------------------------------------------------------------------------------------------------------------------//

	private static inline function isTrue(value : Bool)
	{
		return value == true;
	}

	private static inline function isFalse(value : Bool)
	{
		return value == false;
	}

	private static inline function isNull(value : Dynamic)
	{
		return value == null;
	}

	private static inline function isNotNull(value : Dynamic)
	{
		return value != null;
	}

	private static inline function isEqual(value1 : Dynamic, value2 : Dynamic)
	{
		return value1 == value2;
	}

	private static inline function isNotEqual(value1 : Dynamic, value2 : Dynamic)
	{
		return value1 != value2;
	}

	private inline function getCWD() : String
	{
		#if (sys || nodejs || macro)
		return Sys.getCwd();
		#elseif air
		return "app:/";
		#elseif phantomjs
		return js.phantomjs.FileSystem.workingDirectory;
		#else
		throw "Can't get working directory of unknow platform.";
		#end
	}
}
