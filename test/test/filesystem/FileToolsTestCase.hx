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
