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
	private static inline var SPACES_IN_FILENAME : String = 'spaces in filename';

	private static inline var ONLY_NAME : String = 'only-name';
	private static inline var ONLY_EXT : String = 'only-ext';

	private static inline var SUB_FOLDER_01 : String = 'sub-folder-01';
	private static inline var SUB_FOLDER_02 : String = 'sub folder 02';
	private static inline var SUB_FILE : String = 'sub-file';
	private static inline var SUB_FILE_TXT : String = 'sub-file' + '.' + TXT;

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

	public override function setup() : Void
	{
		_root = new File(ROOT);

		_loremIpsumTxt = _root.resolvePath(LOREM_IPSUM_TXT);
		_loremIpsumZip = _root.resolvePath(LOREM_IPSUM_ZIP);

		_dashesInFilename = _root.resolvePath(DASHES_IN_FILENAME);
		_spacesInFilename = _root.resolvePath(SPACES_IN_FILENAME);

		_onlyName = _root.resolvePath(ONLY_NAME);
		_onlyExt = _root.resolvePath('.' + ONLY_EXT);

		_subFolder01 = _root.resolvePath(SUB_FOLDER_01);
		_subFolder02 = _root.resolvePath(SUB_FOLDER_02);
		_subFile01 = _subFolder01.resolvePath(SUB_FILE_TXT);
		_subFile02 = _subFolder02.resolvePath(SUB_FILE_TXT);
	}

	public override function tearDown() : Void
	{
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
	}

	public function testConstruct() : Void
	{
		assertTrue(_root != null);
	}

	public function testPath() : Void
	{
		// Type
		assertTrue(Std.is(_root.path, String));

		// Values
		_testPath(ROOT, _root);

		_testPath(Path.join([ROOT, LOREM_IPSUM_TXT]), _loremIpsumTxt);
		_testPath(Path.join([ROOT, LOREM_IPSUM_ZIP]), _loremIpsumZip);

		_testPath(Path.join([ROOT, DASHES_IN_FILENAME]), _dashesInFilename);
		_testPath(Path.join([ROOT, SPACES_IN_FILENAME]), _spacesInFilename);

		_testPath(Path.join([ROOT, ONLY_NAME]), _onlyName);
		_testPath(Path.join([ROOT, '.' + ONLY_EXT]), _onlyExt);

		_testPath(Path.join([ROOT, SUB_FOLDER_01]), _subFolder01);
		_testPath(Path.join([ROOT, SUB_FOLDER_02]), _subFolder02);

		_testPath(Path.join([ROOT, SUB_FOLDER_01, SUB_FILE_TXT]), _subFile01);
		_testPath(Path.join([ROOT, SUB_FOLDER_02, SUB_FILE_TXT]), _subFile02);
	}

	private function _testPath(value : String, file : File) : Void
	{
		assertEquals(file.toString(), file.path);
		assertEquals(value, file.path);
		assertEquals(value, file.toString());
	}

	public function testPathName() : Void
	{
		assertEquals(ROOT, _root.name);
		assertEquals(LOREM_IPSUM, _loremIpsumTxt.name);
		assertEquals(LOREM_IPSUM, _loremIpsumZip.name);
	}

//	public function testPathDir() : Void
//	{
//		trace(_root.path);
//		trace(_root.name);
//		trace(_root.dir);
//		trace(_root.ext);
//		assertEquals(_root.dir, null);
//		assertEquals(_loremIpsumTxt.dir, ROOT);
//		assertEquals(_loremIpsumZip.name, ROOT);
//	}
}
