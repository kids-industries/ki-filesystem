package filesystem;

import haxe.io.Path;
import haxe.unit.TestCase;

class FileTestCase extends TestCase
{
	private static inline var ROOT : String = 'test-data';

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
	public override function setup() : Void
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

		_playground = _root.resolvePath(['../', 'bin', 'test-data']);
	}

	public override function tearDown() : Void
	{
		// Try and clean up test-data after each test
		_playground = _root.resolvePath(['../', 'bin', 'test-data']);
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
	}

	//--------------------------------------------------------------------------------------------------------------------------------//
	// BASIC
	//--------------------------------------------------------------------------------------------------------------------------------//

	/**
	* Are we null?
	**/
	public function testConstruct() : Void
	{
		assertTrue(_root != null);
		assertTrue(_loremIpsumTxt != null);
		assertTrue(_loremIpsumZip != null);
		assertTrue(_dashesInFilename != null);
		assertTrue(_spacesInFilename != null);
		assertTrue(_onlyName != null);
		assertTrue(_onlyExt != null);
		assertTrue(_subFolder01 != null);
		assertTrue(_subFolder02 != null);
		assertTrue(_subFile01 != null);
		assertTrue(_subFile02 != null);
	}

	/**
	* file.resolveAbsolutePath()
	**/
	public function testResolveAbsolutePath() : Void
	{
		// FIXME: Sys.getCwd() won't work on all platforms, swap with ENV value set by test runner
		assertEquals(Path.join([Sys.getCwd(), _root.path]), _root.resolveAbsolutePath('').path);
		assertEquals(Path.join([Sys.getCwd(), _subFolder01.path]), _subFolder01.resolveAbsolutePath('').path);
		assertEquals(Path.join([Sys.getCwd(), _subFile01.path]), _subFile01.resolveAbsolutePath('').path);
	}

	/**
	* file.getParent()
	**/
	public function testGetParent() : Void
	{
		try
		{
			_root.getParent();
		}
		catch(error : Any)
		{
			assertTrue(true);
		}

		var absoluteRoot = _root.resolveAbsolutePath('');
		// FIXME: Sys.getCwd() won't work on all platforms, swap with ENV value set by test runner
		assertEquals(Path.join([Sys.getCwd()]), absoluteRoot.getParent().path);

		assertEquals(_root.path, _loremIpsumTxt.getParent().path);
		assertEquals(_root.path, _subFolder01.getParent().path);
		assertEquals(_subFolder01.path, _subFile01.getParent().path);
	}

	/**
	* file.toString() === file.path
	*
	* Ensure that path and toString are always the same
	**/
	public function testToString() : Void
	{
		assertEquals(_root.path, _root.toString());
		assertEquals(_loremIpsumTxt.path, _loremIpsumTxt.toString());
		assertEquals(_loremIpsumZip.path, _loremIpsumZip.toString());
		assertEquals(_dashesInFilename.path, _dashesInFilename.toString());
		assertEquals(_spacesInFilename.path, _spacesInFilename.toString());
		assertEquals(_onlyName.path, _onlyName.toString());
		assertEquals(_onlyExt.path, _onlyExt.toString());
		assertEquals(_subFolder01.path, _subFolder01.toString());
		assertEquals(_subFolder02.path, _subFolder02.toString());
		assertEquals(_subFile01.path, _subFile01.toString());
		assertEquals(_subFile02.path, _subFile02.toString());
	}

	/**
	* file.clone()
	**/
	public function testClone() : Void
	{
		// Not Null
		assertTrue(_root.clone() != null);
		// New Instance
		assertFalse(_root.clone() == _root);
		// Same Path
		assertEquals(_root.path, _root.clone().path);
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
	public function testPath() : Void
	{
		// Type
		assertTrue(Std.is(_root.path, String));

		// Values
		assertEquals(ROOT, _root.path);

		assertEquals(Path.join([ROOT, LOREM_IPSUM_TXT]), _loremIpsumTxt.path);
		assertEquals(Path.join([ROOT, LOREM_IPSUM_ZIP]), _loremIpsumZip.path);

		assertEquals(Path.join([ROOT, DASHES_IN_FILENAME_TXT]), _dashesInFilename.path);
		assertEquals(Path.join([ROOT, SPACES_IN_FILENAME_TXT]), _spacesInFilename.path);

		assertEquals(Path.join([ROOT, ONLY_NAME]), _onlyName.path);
		assertEquals(Path.join([ROOT, '.' + ONLY_EXT]), _onlyExt.path);

		assertEquals(Path.join([ROOT, SUB_FOLDER_01]), _subFolder01.path);
		assertEquals(Path.join([ROOT, SUB_FOLDER_02]), _subFolder02.path);

		assertEquals(Path.join([ROOT, SUB_FOLDER_01, SUB_FILE_TXT]), _subFile01.path);
		assertEquals(Path.join([ROOT, SUB_FOLDER_02, SUB_FILE_TXT]), _subFile02.path);
	}

	/**
	* file.name
	*
	* Name of the file without the extension:
	*
	* folder/{file.name}.ext
	**/
	public function testName() : Void
	{
		assertEquals(ROOT, _root.name);

		assertEquals(LOREM_IPSUM, _loremIpsumTxt.name);
		assertEquals(LOREM_IPSUM, _loremIpsumZip.name);

		assertEquals(DASHES_IN_FILENAME, _dashesInFilename.name);
		assertEquals(SPACES_IN_FILENAME, _spacesInFilename.name);

		assertEquals(ONLY_NAME, _onlyName.name);
		assertEquals("", _onlyExt.name);

		assertEquals(SUB_FOLDER_01, _subFolder01.name);
		assertEquals(SUB_FOLDER_02, _subFolder02.name);
		assertEquals(SUB_FILE, _subFile01.name);
		assertEquals(SUB_FILE, _subFile02.name);
	}

	/**
	* file.dir
	*
	* The directory.
	*
	* {this/is/the/directory/part}/filename.ext
	* {this/is/the/directory/part}/some-folder
	**/
	public function testDir() : Void
	{
		assertEquals(null, _root.dir);

		assertEquals(ROOT, _loremIpsumTxt.dir);
		assertEquals(ROOT, _loremIpsumZip.dir);

		assertEquals(ROOT, _dashesInFilename.dir);
		assertEquals(ROOT, _spacesInFilename.dir);

		assertEquals(ROOT, _onlyName.dir);
		assertEquals(ROOT, _onlyExt.dir);

		assertEquals(ROOT, _subFolder01.dir);
		assertEquals(ROOT, _subFolder02.dir);
		assertEquals(Path.join([ROOT, SUB_FOLDER_01]), _subFile01.dir);
		assertEquals(Path.join([ROOT, SUB_FOLDER_02]), _subFile02.dir);
	}

	/**
	* file.ext
	*
	* The file extension
	*
	* folder/filename.{ext}
	**/
	public function testExt() : Void
	{
		assertEquals(null, _root.ext);

		assertEquals(TXT, _loremIpsumTxt.ext);
		assertEquals(ZIP, _loremIpsumZip.ext);

		assertEquals(TXT, _dashesInFilename.ext);
		assertEquals(TXT, _spacesInFilename.ext);

		assertEquals(null, _onlyName.ext);
		assertEquals(ONLY_EXT, _onlyExt.ext);

		assertEquals(null, _subFolder01.ext);
		assertEquals(null, _subFolder02.ext);
		assertEquals(TXT, _subFile01.ext);
		assertEquals(TXT, _subFile02.ext);
	}

	/**
	* file.file
	*
	* The file's full name including ext
	*
	* folder/{name.ext}
	**/
	public function testFile() : Void
	{
		assertEquals(ROOT, _root.file);

		assertEquals(LOREM_IPSUM_TXT, _loremIpsumTxt.file);
		assertEquals(LOREM_IPSUM_ZIP, _loremIpsumZip.file);

		assertEquals(DASHES_IN_FILENAME_TXT, _dashesInFilename.file);
		assertEquals(SPACES_IN_FILENAME_TXT, _spacesInFilename.file);

		assertEquals(ONLY_NAME, _onlyName.file);
		assertEquals('.' + ONLY_EXT, _onlyExt.file);

		assertEquals(SUB_FOLDER_01, _subFolder01.file);
		assertEquals(SUB_FOLDER_02, _subFolder02.file);
		assertEquals(SUB_FILE_TXT, _subFile01.file);
		assertEquals(SUB_FILE_TXT, _subFile02.file);
	}

	/**
	* file.isAbsolute
	*
	* The file extension
	*
	* folder/filename.{ext}
	**/
	public function testIsAbsolute() : Void
	{
		assertFalse(_root.isAbsolute);

		assertFalse(_loremIpsumTxt.isAbsolute);
		assertFalse(_loremIpsumZip.isAbsolute);

		assertFalse(_dashesInFilename.isAbsolute);
		assertFalse(_spacesInFilename.isAbsolute);

		assertFalse(_onlyName.isAbsolute);
		assertFalse(_onlyExt.isAbsolute);

		assertFalse(_subFolder01.isAbsolute);
		assertFalse(_subFolder02.isAbsolute);
		assertFalse(_subFile01.isAbsolute);
		assertFalse(_subFile02.isAbsolute);

		assertTrue(new File('/some/path').isAbsolute);
		assertTrue(new File('C:/some/path').isAbsolute);
		// TODO: handle file protocol as absolute path - TRIPLE SLASH!!
		//assertTrue(new File('file:///some/path').isAbsolute);
	}

	//--------------------------------------------------------------------------------------------------------------------------------//
	// READ ONLY I/O
	//--------------------------------------------------------------------------------------------------------------------------------//

	/**
	* file.exists
	*
	* Whether the file exists or not.
	**/
	public function testExists() : Void
	{
		assertTrue(_root.exists);

		assertTrue(_loremIpsumTxt.exists);
		assertTrue(_loremIpsumZip.exists);

		assertTrue(_dashesInFilename.exists);
		assertTrue(_spacesInFilename.exists);

		assertTrue(_onlyName.exists);
		assertTrue(_onlyExt.exists);

		assertTrue(_subFolder01.exists);
		assertTrue(_subFolder02.exists);
		assertTrue(_subFile01.exists);
		assertTrue(_subFile02.exists);

		assertFalse(_nonExistantFile.exists);
		assertFalse(_nonExistantFolder.exists);
		assertFalse(_nonExistantSubFolder.exists);
		assertFalse(_nonExistantSubFile.exists);
	}

	/**
	* file.isDirectory
	*
	* Directory or not?
	*
	* Note that files/folders that do not exists must be false.
	**/
	public function testIsDirectory() : Void
	{
		assertTrue(_root.isDirectory);

		assertFalse(_loremIpsumTxt.isDirectory);
		assertFalse(_loremIpsumZip.isDirectory);

		assertFalse(_dashesInFilename.isDirectory);
		assertFalse(_spacesInFilename.isDirectory);

		assertFalse(_onlyName.isDirectory);
		assertFalse(_onlyExt.isDirectory);

		assertTrue(_subFolder01.isDirectory);
		assertTrue(_subFolder02.isDirectory);
		assertFalse(_subFile01.isDirectory);
		assertFalse(_subFile02.isDirectory);

		assertFalse(_nonExistantFile.isDirectory);
		assertFalse(_nonExistantFolder.isDirectory);
		assertFalse(_nonExistantSubFolder.isDirectory);
		assertFalse(_nonExistantSubFile.isDirectory);
	}

	/**
	* file.getDirectoryListing(false)
	**/
	public function testGetDirectoryListing() : Void
	{
		var files = _root.getDirectoryListing();

		assertTrue(files != null);
		assertTrue(files.length == 8);

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
			assertTrue(expected.indexOf(file.path) != -1);
	}

	/**
	* file.getDirectoryListing(true)
	**/
	public function testGetDirectoryListingRecursive() : Void
	{
		var files = _root.getDirectoryListing(true);

		assertTrue(files != null);
		assertTrue(files.length == 10);

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
			assertTrue(expected.indexOf(file.path) != -1);
	}

	//--------------------------------------------------------------------------------------------------------------------------------//
	// READ/WRITE I/O
	//--------------------------------------------------------------------------------------------------------------------------------//

	/**
	* file.createDirectory(true|false)
	**/
	public function testCreateDirectory() : Void
	{
		// CREATE
		assertFalse(_playground.exists);

		_playground.createDirectory();

		assertTrue(_playground.exists);
		assertTrue(_playground.isDirectory);

		var subFolder01 = _playground.resolvePath('folder-01');
		var subFolder02 = subFolder01.resolvePath('folder 02');
		var subFolder03 = subFolder02.resolvePath('folder_03');

		assertFalse(subFolder01.exists);
		assertFalse(subFolder02.exists);
		assertFalse(subFolder03.exists);

		subFolder03.createDirectory(true);

		assertTrue(subFolder01.exists);
		assertTrue(subFolder02.exists);
		assertTrue(subFolder03.exists);

		assertTrue(subFolder01.isDirectory);
		assertTrue(subFolder02.isDirectory);
		assertTrue(subFolder03.isDirectory);
	}

	/**
	* file.copyTo()
	**/
	public function testCopyTo() : Void
	{
		// CREATE
		var file = _playground.resolvePath(LOREM_IPSUM_TXT);
		var subFolder = _playground.resolvePath(SUB_FOLDER_01);
		var subFile = subFolder.resolvePath(SUB_FILE_TXT);

		assertFalse(_playground.exists);
		assertFalse(file.exists);
		assertFalse(subFolder.exists);
		assertFalse(subFile.exists);

		// Single file copyTo
		_loremIpsumTxt.copyTo(file);
		_subFile01.copyTo(subFile);

		assertTrue(_playground.exists);
		assertTrue(_playground.isDirectory);
		assertTrue(file.exists);
		assertTrue(subFolder.exists);
		assertTrue(subFolder.isDirectory);
		assertTrue(subFile.exists);

		// Recursive copyTo
		_root.copyTo(_playground);

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
			assertTrue(_playground.resolvePath(path).exists);

		assertTrue(_playground.resolvePath(SUB_FOLDER_02).isDirectory);

		// TODO: Validate contents of the copied files
	}

	/**
	* file.copyInto()
	**/
	public function testCopyInto() : Void
	{
		// CREATE
		var file = _playground.resolvePath(LOREM_IPSUM_TXT);
		var subFolder = _playground.resolvePath(SUB_FOLDER_01);
		var subFile = subFolder.resolvePath(SUB_FILE_TXT);

		assertFalse(_playground.exists);
		assertFalse(file.exists);
		assertFalse(subFolder.exists);
		assertFalse(subFile.exists);

		// Single file copyTo
		_loremIpsumTxt.copyInto(_playground);
		_subFile01.copyInto(subFolder);

		assertTrue(_playground.exists);
		assertTrue(_playground.isDirectory);
		assertTrue(file.exists);
		assertTrue(subFolder.exists);
		assertTrue(subFolder.isDirectory);
		assertTrue(subFile.exists);

		// Recursive copyTo
		_root.copyInto(_playground.getParent());

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
			assertTrue(_playground.resolvePath(path).exists);

		assertTrue(_playground.resolvePath(SUB_FOLDER_02).isDirectory);

		// TODO: Validate contents of the copied files
	}

	/**
	* file.moveTo()
	**/
	public function testMoveTo() : Void
	{
		// Create a working copy first
		_root.copyTo(_playground);

		var file = _playground.resolvePath(LOREM_IPSUM_TXT);
		var fileTarget = _playground.resolvePath('new-file.txt');

		assertFalse(fileTarget.exists);

		file.moveTo(fileTarget);

		assertFalse(file.exists);
		assertTrue(fileTarget.exists);

		var folder = _playground.resolvePath(SUB_FOLDER_01);
		var folderTarget = _playground.resolvePath('new-folder');

		assertFalse(folderTarget.exists);

		folder.moveTo(folderTarget);

		assertFalse(folder.exists);
		assertTrue(folderTarget.exists);
	}

	//--------------------------------------------------------------------------------------------------------------------------------//
	// HELPERS
	//--------------------------------------------------------------------------------------------------------------------------------//

	private function println(v : Dynamic)
	{
		print(v);
		print("\n");
	}
}
