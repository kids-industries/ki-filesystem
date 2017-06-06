package ;

import filesystem.FileTestCase;
import haxe.unit.TestRunner;

class Runner
{
	public static function main() : Void
	{
		trace("---------------------------------------");
		trace("----------- STARTING RUNNER -----------");
		trace("---------------------------------------");

		var runner = new TestRunner();
		runner.add(new FileTestCase());
		runner.run();

		trace("---------------------------------------");
		trace("-------------- COVERAGE ---------------");
		trace("---------------------------------------");

		mcover.coverage.MCoverage.getLogger().report();

		Sys.exit(runner.result.success ? 0 : 1);
	}
}
