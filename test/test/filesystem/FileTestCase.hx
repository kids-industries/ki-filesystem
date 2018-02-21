package test.filesystem;

import filesystem.File;
import haxe.io.Path;
import tink.CoreApi.Noise;
import tink.testrunner.Case.BasicCase;
import tink.unit.AssertionBuffer;

using filesystem.FileTools;

class FileTestCase extends BasicCase
{
	private static inline var ROOT : String = #if air 'app:/' + #end 'test-data';

	private static inline var LOREM_IPSUM : String = 'Lorem Ipsum';
	private static inline var LOREM_IPSUM_TXT : String = LOREM_IPSUM + '.' + TXT;
	private static inline var LOREM_IPSUM_ZIP : String = LOREM_IPSUM + '.' + ZIP;

	private static inline var DASHES_IN_FILENAME : String = 'dashes-in-filename';
	private static inline var DASHES_IN_FILENAME_TXT : String = DASHES_IN_FILENAME + '.' + TXT;
	private static inline var SPACES_IN_FILENAME : String = 'spaces in filename';
	private static inline var SPACES_IN_FILENAME_TXT : String = SPACES_IN_FILENAME + '.' + TXT;

	private static inline var ONLY_NAME : String = 'only-name';
	private static inline var ONLY_EXT : String = 'only-ext';

	private static inline var SUB_FOLDER_01 : String = 'sub-folder-01';
	private static inline var SUB_FOLDER_02 : String = 'sub folder 02';
	private static inline var SUB_FILE : String = 'sub-file';
	private static inline var SUB_FILE_TXT : String = 'sub-file' + '.' + TXT;

	private static inline var NON_EXISTANT_FILE : String = 'not-a-file.gz';
	private static inline var NON_EXISTANT_FOLDER : String = 'not-a-folder';
	private static inline var NON_EXISTANT_SUB_FOLDER : String = 'yet-another';

	private static inline var ZIP : String = 'zip';
	private static inline var TXT : String = 'txt';

	private var _root : File;

	private var _loremIpsumTxt : File;
	private var _loremIpsumZip : File;

	private var _dashesInFilename : File;
	private var _spacesInFilename : File;

	private var _onlyName : File;
	private var _onlyExt : File;

	private var _subFolder01 : File;
	private var _subFolder02 : File;
	private var _subFile01 : File;
	private var _subFile02 : File;

	private var _nonExistantFile : File;
	private var _nonExistantFolder : File;
	private var _nonExistantSubFolder : File;
	private var _nonExistantSubFile : File;

	private var _playground : File;

	//--------------------------------------------------------------------------------------------------------------------------------//
	// SETUP
	//--------------------------------------------------------------------------------------------------------------------------------//
	@:before
	public function setup()
	{
		_root = new File(ROOT);

		_loremIpsumTxt = _root.resolvePath(LOREM_IPSUM_TXT);
		_loremIpsumZip = _root.resolvePath(LOREM_IPSUM_ZIP);

		_dashesInFilename = _root.resolvePath(DASHES_IN_FILENAME_TXT);
		_spacesInFilename = _root.resolvePath(SPACES_IN_FILENAME_TXT);

		_onlyName = _root.resolvePath(ONLY_NAME);
		_onlyExt = _root.resolvePath('.' + ONLY_EXT);

		_subFolder01 = _root.resolvePath(SUB_FOLDER_01);
		_subFolder02 = _root.resolvePath(SUB_FOLDER_02);
		_subFile01 = _subFolder01.resolvePath(SUB_FILE_TXT);
		_subFile02 = _subFolder02.resolvePath(SUB_FILE_TXT);

		_nonExistantFile = _root.resolvePath(NON_EXISTANT_FILE);
		_nonExistantFolder = _root.resolvePath(NON_EXISTANT_FOLDER);
		_nonExistantSubFolder = _nonExistantFolder.resolvePath(NON_EXISTANT_SUB_FOLDER);
		_nonExistantSubFile = _nonExistantSubFolder.resolvePath(NON_EXISTANT_FILE);

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
		_loremIpsumZip = null;

		_dashesInFilename = null;
		_spacesInFilename = null;

		_onlyName = null;
		_onlyExt = null;

		_subFolder01 = null;
		_subFolder02 = null;
		_subFile01 = null;
		_subFile02 = null;

		_nonExistantFile = null;
		_nonExistantFolder = null;
		_nonExistantSubFolder = null;
		_nonExistantSubFile = null;

		return Noise;
	}

	//--------------------------------------------------------------------------------------------------------------------------------//
	// BASIC
	//--------------------------------------------------------------------------------------------------------------------------------//

	/**
	* Are we null?
	**/
	public function testConstruct()
	{
		var buffer = new AssertionBuffer();

		buffer.assert(isNotNull(_root));
		buffer.assert(isNotNull(_loremIpsumTxt));
		buffer.assert(isNotNull(_loremIpsumZip));
		buffer.assert(isNotNull(_dashesInFilename));
		buffer.assert(isNotNull(_spacesInFilename));
		buffer.assert(isNotNull(_onlyName));
		buffer.assert(isNotNull(_onlyExt));
		buffer.assert(isNotNull(_subFolder01));
		buffer.assert(isNotNull(_subFolder02));
		buffer.assert(isNotNull(_subFile01));
		buffer.assert(isNotNull(_subFile02));

		return buffer.done();
	}

	/**
	* file.resolveAbsolutePath()
	**/
	public function testResolveAbsolutePath()
	{
		var buffer = new AssertionBuffer();

		var cwd = getCWD();

		// AIR paths are always absolute, so don't prefix the protocal twice
		#if air
		cwd = "";
		#end

		buffer.assert(isEqual(Path.join([cwd, _root.path]), _root.resolveAbsolutePath('').path));
		buffer.assert(isEqual(Path.join([cwd, _subFolder01.path]), _subFolder01.resolveAbsolutePath('').path));
		buffer.assert(isEqual(Path.join([cwd, _subFile01.path]), _subFile01.resolveAbsolutePath('').path));

		return buffer.done();
	}

	/**
	* file.getParent()
	**/
	public function testGetParent()
	{
		var buffer = new AssertionBuffer();

		try
		{
			_root.getParent();
		}
		catch(error : Any)
		{
			buffer.assert(isTrue(true));
		}

		var absoluteRoot = _root.resolveAbsolutePath('');
		// FIXME: getCWD() won't work on all platforms, swap with ENV value set by test runner
		buffer.assert(isEqual(Path.join([getCWD()]), absoluteRoot.getParent().path));

		buffer.assert(isEqual(_root.path, _loremIpsumTxt.getParent().path));
		buffer.assert(isEqual(_root.path, _subFolder01.getParent().path));
		buffer.assert(isEqual(_subFolder01.path, _subFile01.getParent().path));

		return buffer.done();
	}

	/**
	* file.toString() === file.path
	*
	* Ensure that path and toString are always the same
	**/
	public function testToString()
	{
		var buffer = new AssertionBuffer();

		buffer.assert(isEqual(_root.path, _root.toString()));
		buffer.assert(isEqual(_loremIpsumTxt.path, _loremIpsumTxt.toString()));
		buffer.assert(isEqual(_loremIpsumZip.path, _loremIpsumZip.toString()));
		buffer.assert(isEqual(_dashesInFilename.path, _dashesInFilename.toString()));
		buffer.assert(isEqual(_spacesInFilename.path, _spacesInFilename.toString()));
		buffer.assert(isEqual(_onlyName.path, _onlyName.toString()));
		buffer.assert(isEqual(_onlyExt.path, _onlyExt.toString()));
		buffer.assert(isEqual(_subFolder01.path, _subFolder01.toString()));
		buffer.assert(isEqual(_subFolder02.path, _subFolder02.toString()));
		buffer.assert(isEqual(_subFile01.path, _subFile01.toString()));
		buffer.assert(isEqual(_subFile02.path, _subFile02.toString()));

		return buffer.done();
	}

	/**
	* file.clone()
	**/
	public function testClone()
	{
		var buffer = new AssertionBuffer();

		// Not Null
		buffer.assert(isNotNull(_root.clone()));
		// New Instance
		buffer.assert(isFalse(_root.clone() == _root));
		// Same Path
		buffer.assert(isEqual(_root.path, _root.clone().path));

		return buffer.done();
	}

	//--------------------------------------------------------------------------------------------------------------------------------//
	// PATH PROPERTIES
	//--------------------------------------------------------------------------------------------------------------------------------//

	/**
	* file.path
	*
	* Full path including directory filename and extension, seperated by system supported delimiter.
	*
	* folder/filename.ext
	* file:///folder/filename.ext
	* C:/folder/filename.ext
	**/
	public function testPath()
	{
		var buffer = new AssertionBuffer();

		// Type
		buffer.assert(isTrue(Std.is(_root.path, String)));

		// Values
		buffer.assert(isEqual(ROOT, _root.path));

		buffer.assert(isEqual(Path.join([ROOT, LOREM_IPSUM_TXT]), _loremIpsumTxt.path));
		buffer.assert(isEqual(Path.join([ROOT, LOREM_IPSUM_ZIP]), _loremIpsumZip.path));

		buffer.assert(isEqual(Path.join([ROOT, DASHES_IN_FILENAME_TXT]), _dashesInFilename.path));
		buffer.assert(isEqual(Path.join([ROOT, SPACES_IN_FILENAME_TXT]), _spacesInFilename.path));

		buffer.assert(isEqual(Path.join([ROOT, ONLY_NAME]), _onlyName.path));
		buffer.assert(isEqual(Path.join([ROOT, '.' + ONLY_EXT]), _onlyExt.path));

		buffer.assert(isEqual(Path.join([ROOT, SUB_FOLDER_01]), _subFolder01.path));
		buffer.assert(isEqual(Path.join([ROOT, SUB_FOLDER_02]), _subFolder02.path));

		buffer.assert(isEqual(Path.join([ROOT, SUB_FOLDER_01, SUB_FILE_TXT]), _subFile01.path));
		buffer.assert(isEqual(Path.join([ROOT, SUB_FOLDER_02, SUB_FILE_TXT]), _subFile02.path));

		buffer.assert(isEqual('C:/folder/filename.txt', new File('C:/folder/filename.txt').path));

		// Should we convert seperators?
		//buffer.assert(isEqual('C:\\folder\\filename.txt', new File('C:/folder/filename.txt').path));

		return buffer.done();
	}

	/**
	* file.name
	*
	* Name of the file without the extension:
	*
	* folder/{file.name}.ext
	**/
	public function testName()
	{
		var buffer = new AssertionBuffer();

		buffer.assert(isEqual(ROOT.split('/').pop(), _root.name));

		buffer.assert(isEqual(LOREM_IPSUM, _loremIpsumTxt.name));
		buffer.assert(isEqual(LOREM_IPSUM, _loremIpsumZip.name));

		buffer.assert(isEqual(DASHES_IN_FILENAME, _dashesInFilename.name));
		buffer.assert(isEqual(SPACES_IN_FILENAME, _spacesInFilename.name));

		buffer.assert(isEqual(ONLY_NAME, _onlyName.name));
		buffer.assert(isEqual("", _onlyExt.name));

		buffer.assert(isEqual(SUB_FOLDER_01, _subFolder01.name));
		buffer.assert(isEqual(SUB_FOLDER_02, _subFolder02.name));
		buffer.assert(isEqual(SUB_FILE, _subFile01.name));
		buffer.assert(isEqual(SUB_FILE, _subFile02.name));

		return buffer.done();
	}

	/**
	* file.dir
	*
	* The directory.
	*
	* {this/is/the/directory/part}/filename.ext
	* {this/is/the/directory/part}/some-folder
	**/
	public function testDir()
	{
		var buffer = new AssertionBuffer();

		buffer.assert(isEqual(null, _root.dir));

		buffer.assert(isEqual(ROOT, _loremIpsumTxt.dir));
		buffer.assert(isEqual(ROOT, _loremIpsumZip.dir));

		buffer.assert(isEqual(ROOT, _dashesInFilename.dir));
		buffer.assert(isEqual(ROOT, _spacesInFilename.dir));

		buffer.assert(isEqual(ROOT, _onlyName.dir));
		buffer.assert(isEqual(ROOT, _onlyExt.dir));

		buffer.assert(isEqual(ROOT, _subFolder01.dir));
		buffer.assert(isEqual(ROOT, _subFolder02.dir));
		buffer.assert(isEqual(Path.join([ROOT, SUB_FOLDER_01]), _subFile01.dir));
		buffer.assert(isEqual(Path.join([ROOT, SUB_FOLDER_02]), _subFile02.dir));

		return buffer.done();
	}

	/**
	* file.ext
	*
	* The file extension
	*
	* folder/filename.{ext}
	**/
	public function testExt()
	{
		var buffer = new AssertionBuffer();

		buffer.assert(isEqual(null, _root.ext));

		buffer.assert(isEqual(TXT, _loremIpsumTxt.ext));
		buffer.assert(isEqual(ZIP, _loremIpsumZip.ext));

		buffer.assert(isEqual(TXT, _dashesInFilename.ext));
		buffer.assert(isEqual(TXT, _spacesInFilename.ext));

		buffer.assert(isEqual(null, _onlyName.ext));
		buffer.assert(isEqual(ONLY_EXT, _onlyExt.ext));

		buffer.assert(isEqual(null, _subFolder01.ext));
		buffer.assert(isEqual(null, _subFolder02.ext));
		buffer.assert(isEqual(TXT, _subFile01.ext));
		buffer.assert(isEqual(TXT, _subFile02.ext));

		return buffer.done();
	}

	/**
	* file.file
	*
	* The file's full name including ext
	*
	* folder/{name.ext}
	**/
	public function testFile()
	{
		var buffer = new AssertionBuffer();

		buffer.assert(isEqual(ROOT.split('/').pop(), _root.file));

		buffer.assert(isEqual(LOREM_IPSUM_TXT, _loremIpsumTxt.file));
		buffer.assert(isEqual(LOREM_IPSUM_ZIP, _loremIpsumZip.file));

		buffer.assert(isEqual(DASHES_IN_FILENAME_TXT, _dashesInFilename.file));
		buffer.assert(isEqual(SPACES_IN_FILENAME_TXT, _spacesInFilename.file));

		buffer.assert(isEqual(ONLY_NAME, _onlyName.file));
		buffer.assert(isEqual('.' + ONLY_EXT, _onlyExt.file));

		buffer.assert(isEqual(SUB_FOLDER_01, _subFolder01.file));
		buffer.assert(isEqual(SUB_FOLDER_02, _subFolder02.file));
		buffer.assert(isEqual(SUB_FILE_TXT, _subFile01.file));
		buffer.assert(isEqual(SUB_FILE_TXT, _subFile02.file));

		return buffer.done();
	}

	/**
	* file.isAbsolute
	*
	* The file extension
	*
	* folder/filename.{ext}
	**/
	public function testIsAbsolute()
	{
		var buffer = new AssertionBuffer();

		// All AIR paths are absolute
		var isBool = #if air isTrue #else isFalse #end;

		buffer.assert(isBool(_root.isAbsolute));

		buffer.assert(isBool(_loremIpsumTxt.isAbsolute));
		buffer.assert(isBool(_loremIpsumZip.isAbsolute));

		buffer.assert(isBool(_dashesInFilename.isAbsolute));
		buffer.assert(isBool(_spacesInFilename.isAbsolute));

		buffer.assert(isBool(_onlyName.isAbsolute));
		buffer.assert(isBool(_onlyExt.isAbsolute));

		buffer.assert(isBool(_subFolder01.isAbsolute));
		buffer.assert(isBool(_subFolder02.isAbsolute));
		buffer.assert(isBool(_subFile01.isAbsolute));
		buffer.assert(isBool(_subFile02.isAbsolute));

		buffer.assert(isTrue(new File('/some/path').isAbsolute));

		// AIR can't handle these paths
		#if !air
		buffer.assert(isTrue(new File('C:/some/path').isAbsolute));
		// TODO: handle file protocol as absolute path - TRIPLE SLASH!!
		//buffer.assert(isTrue(new File('file:///some/path').isAbsolute));
		#end

		return buffer.done();
	}

	//--------------------------------------------------------------------------------------------------------------------------------//
	// READ ONLY I/O
	//--------------------------------------------------------------------------------------------------------------------------------//

	/**
	* file.exists
	*
	* Whether the file exists or not.
	**/
	public function testExists()
	{
		var buffer = new AssertionBuffer();

		buffer.assert(isTrue(_root.exists));

		buffer.assert(isTrue(_loremIpsumTxt.exists));
		buffer.assert(isTrue(_loremIpsumZip.exists));

		buffer.assert(isTrue(_dashesInFilename.exists));
		buffer.assert(isTrue(_spacesInFilename.exists));

		buffer.assert(isTrue(_onlyName.exists));
		buffer.assert(isTrue(_onlyExt.exists));

		buffer.assert(isTrue(_subFolder01.exists));
		buffer.assert(isTrue(_subFolder02.exists));
		buffer.assert(isTrue(_subFile01.exists));
		buffer.assert(isTrue(_subFile02.exists));

		buffer.assert(isFalse(_nonExistantFile.exists));
		buffer.assert(isFalse(_nonExistantFolder.exists));
		buffer.assert(isFalse(_nonExistantSubFolder.exists));
		buffer.assert(isFalse(_nonExistantSubFile.exists));

		return buffer.done();
	}

	/**
	* file.isDirectory
	*
	* Directory or not?
	*
	* Note that files/folders that do not exists must be false.
	**/
	public function testIsDirectory()
	{
		var buffer = new AssertionBuffer();

		buffer.assert(isTrue(_root.isDirectory));

		buffer.assert(isFalse(_loremIpsumTxt.isDirectory));
		buffer.assert(isFalse(_loremIpsumZip.isDirectory));

		buffer.assert(isFalse(_dashesInFilename.isDirectory));
		buffer.assert(isFalse(_spacesInFilename.isDirectory));

		buffer.assert(isFalse(_onlyName.isDirectory));
		buffer.assert(isFalse(_onlyExt.isDirectory));

		buffer.assert(isTrue(_subFolder01.isDirectory));
		buffer.assert(isTrue(_subFolder02.isDirectory));
		buffer.assert(isFalse(_subFile01.isDirectory));
		buffer.assert(isFalse(_subFile02.isDirectory));

		buffer.assert(isFalse(_nonExistantFile.isDirectory));
		buffer.assert(isFalse(_nonExistantFolder.isDirectory));
		buffer.assert(isFalse(_nonExistantSubFolder.isDirectory));
		buffer.assert(isFalse(_nonExistantSubFile.isDirectory));

		return buffer.done();
	}

	/**
	* file.getDirectoryListing(false)
	**/
	public function testGetDirectoryListing()
	{
		var buffer = new AssertionBuffer();

		var files = _root.getDirectoryListing();

		buffer.assert(isNotNull(files));
		buffer.assert(isEqual(files.length, 8));

		var expected = [
			'$ROOT/$LOREM_IPSUM_TXT',
			'$ROOT/$LOREM_IPSUM_ZIP',
			'$ROOT/$SPACES_IN_FILENAME_TXT',
			'$ROOT/$DASHES_IN_FILENAME_TXT',
			'$ROOT/$ONLY_NAME',
			'$ROOT/.$ONLY_EXT',
			'$ROOT/$SUB_FOLDER_01',
			'$ROOT/$SUB_FOLDER_02'
		];

		for(file in files)
			buffer.assert(isTrue(expected.indexOf(file.path) != -1));

		return buffer.done();
	}

	/**
	* file.getDirectoryListing(true)
	**/
	public function testGetDirectoryListingRecursive()
	{
		var buffer = new AssertionBuffer();

		var files = _root.getDirectoryListing(true);

		buffer.assert(isNotNull(files));
		buffer.assert(isEqual(files.length, 10));

		var expected = [
			'$ROOT/$LOREM_IPSUM_TXT',
			'$ROOT/$LOREM_IPSUM_ZIP',
			'$ROOT/$SPACES_IN_FILENAME_TXT',
			'$ROOT/$DASHES_IN_FILENAME_TXT',
			'$ROOT/$ONLY_NAME',
			'$ROOT/.$ONLY_EXT',
			'$ROOT/$SUB_FOLDER_01',
			'$ROOT/$SUB_FOLDER_02',
			'$ROOT/$SUB_FOLDER_01/$SUB_FILE_TXT',
			'$ROOT/$SUB_FOLDER_02/$SUB_FILE_TXT'
		];

		for(file in files)
			buffer.assert(isTrue(expected.indexOf(file.path) != -1));

		return buffer.done();
	}

	//--------------------------------------------------------------------------------------------------------------------------------//
	// READ/WRITE I/O
	//--------------------------------------------------------------------------------------------------------------------------------//

	/**
	* file.createDirectory(true|false)
	**/
	public function testCreateDirectory()
	{
		var buffer = new AssertionBuffer();

		// CREATE
		buffer.assert(isFalse(_playground.exists));

		_playground.createDirectory();

		buffer.assert(isTrue(_playground.exists));
		buffer.assert(isTrue(_playground.isDirectory));

		var subFolder01 = _playground.resolvePath('folder-01');
		var subFolder02 = subFolder01.resolvePath('folder 02');
		var subFolder03 = subFolder02.resolvePath('folder_03');

		buffer.assert(isFalse(subFolder01.exists));
		buffer.assert(isFalse(subFolder02.exists));
		buffer.assert(isFalse(subFolder03.exists));

		subFolder03.createDirectory(true);

		buffer.assert(isTrue(subFolder01.exists));
		buffer.assert(isTrue(subFolder02.exists));
		buffer.assert(isTrue(subFolder03.exists));

		buffer.assert(isTrue(subFolder01.isDirectory));
		buffer.assert(isTrue(subFolder02.isDirectory));
		buffer.assert(isTrue(subFolder03.isDirectory));

		return buffer.done();
	}

	/**
	* file.copyTo()
	**/
	public function testCopyTo()
	{
		var buffer = new AssertionBuffer();

		// CREATE
		var file = _playground.resolvePath(LOREM_IPSUM_TXT);
		var subFolder01 = _playground.resolvePath(SUB_FOLDER_01);
		var subFolder02 = _playground.resolvePath(SUB_FOLDER_02);
		var subFile01 = subFolder01.resolvePath(SUB_FILE_TXT);
		var subFile02 = subFolder02.resolvePath(SUB_FILE_TXT);

		buffer.assert(isFalse(_playground.exists));
		buffer.assert(isFalse(file.exists));
		buffer.assert(isFalse(subFolder01.exists));
		buffer.assert(isFalse(subFile01.exists));

		// Single file copyTo
		_loremIpsumTxt.copyTo(file);
		_subFile01.copyTo(subFile01);

		buffer.assert(isTrue(_playground.exists));
		buffer.assert(isTrue(_playground.isDirectory));
		buffer.assert(isTrue(file.exists));
		buffer.assert(isTrue(subFolder01.exists));
		buffer.assert(isTrue(subFolder01.isDirectory));
		buffer.assert(isTrue(subFile01.exists));

		// Recursive copyTo
		_root.copyTo(_playground, true);

		var paths = [
			'$LOREM_IPSUM_TXT',
			'$LOREM_IPSUM_ZIP',
			'$SPACES_IN_FILENAME_TXT',
			'$DASHES_IN_FILENAME_TXT',
			'$ONLY_NAME',
			'.$ONLY_EXT',
			'$SUB_FOLDER_01',
			'$SUB_FOLDER_02',
			'$SUB_FOLDER_01/$SUB_FILE_TXT',
			'$SUB_FOLDER_02/$SUB_FILE_TXT'
		];

		for(path in paths)
			buffer.assert(isTrue(_playground.resolvePath(path).exists));

		buffer.assert(isTrue(subFolder02.isDirectory));

		// Test overwriteIfNewer
		var expectedText = "Modified!!";

		file.writeString("Modified!!");
		_root.copyTo(_playground, false, true);
		buffer.assert(isEqual(file.readString(), expectedText));

		// FIXME: Re-enable test once we have setModificationDate
		/*subFile01.writeString(expectedText);
		subFolder01.copyTo(subFolder02, false, true);
		buffer.assert(isEqual(subFile02.readString(), expectedText));*/

		// TODO: Validate contents of the copied files

		return buffer.done();
	}

	/**
	* file.copyInto()
	**/
	public function testCopyInto()
	{
		var buffer = new AssertionBuffer();

		// CREATE
		var file = _playground.resolvePath(LOREM_IPSUM_TXT);
		var subFolder = _playground.resolvePath(SUB_FOLDER_01);
		var subFile = subFolder.resolvePath(SUB_FILE_TXT);

		buffer.assert(isFalse(_playground.exists));
		buffer.assert(isFalse(file.exists));
		buffer.assert(isFalse(subFolder.exists));
		buffer.assert(isFalse(subFile.exists));

		// Single file copyTo
		_loremIpsumTxt.copyInto(_playground);
		_subFile01.copyInto(subFolder);

		buffer.assert(isTrue(_playground.exists));
		buffer.assert(isTrue(_playground.isDirectory));
		buffer.assert(isTrue(file.exists));
		buffer.assert(isTrue(subFolder.exists));
		buffer.assert(isTrue(subFolder.isDirectory));
		buffer.assert(isTrue(subFile.exists));

		// Recursive copyTo
		_root.copyInto(_playground.getParent(), true);

		var paths = [
			'$LOREM_IPSUM_TXT',
			'$LOREM_IPSUM_ZIP',
			'$SPACES_IN_FILENAME_TXT',
			'$DASHES_IN_FILENAME_TXT',
			'$ONLY_NAME',
			'.$ONLY_EXT',
			'$SUB_FOLDER_01',
			'$SUB_FOLDER_02',
			'$SUB_FOLDER_01/$SUB_FILE_TXT',
			'$SUB_FOLDER_02/$SUB_FILE_TXT'
		];

		for(path in paths)
			buffer.assert(isTrue(_playground.resolvePath(path).exists));

		buffer.assert(isTrue(_playground.resolvePath(SUB_FOLDER_02).isDirectory));

		// TODO: Validate contents of the copied files

		return buffer.done();
	}

	/**
	* file.moveTo()
	**/
	public function testMoveTo()
	{
		var buffer = new AssertionBuffer();

		// Create a working copy first
		_root.copyTo(_playground);

		var file = _playground.resolvePath(LOREM_IPSUM_TXT);
		var fileTarget = _playground.resolvePath('new-file.txt');

		buffer.assert(isFalse(fileTarget.exists));

		file.moveTo(fileTarget);

		buffer.assert(isFalse(file.exists));
		buffer.assert(isTrue(fileTarget.exists));

		var folder = _playground.resolvePath(SUB_FOLDER_01);
		var folderTarget = _playground.resolvePath('new-folder');

		buffer.assert(isFalse(folderTarget.exists));

		folder.moveTo(folderTarget);

		buffer.assert(isFalse(folder.exists));
		buffer.assert(isTrue(folderTarget.exists));

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
