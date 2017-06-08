package ;

import mcover.coverage.client.PrintClient;
import tink.testrunner.Runner;
import tink.unit.TestBatch;

class Tester
{
	public static function main() : Void
	{
		test(function(result : BatchResult) : Void
		     {
			     coverage();

			     Runner.exit(result);
		     });
	}

	private static function test(handler : BatchResult -> Void) : Void
	{
		print("---------------------------------------");
		print("----------- STARTING RUNNER -----------");
		print("---------------------------------------");

		Runner.run(
			TestBatch.make(
				[
					new filesystem.FileTestCase()
				])
		).handle(handler);
	}

	private static function coverage() : Void
	{
		print("---------------------------------------");
		print("-------------- COVERAGE ---------------");
		print("---------------------------------------");

		var logger = mcover.coverage.MCoverage.getLogger();
		logger.addClient(new CustomPrintClient());
		logger.report();
	}

	public inline static function print(v : Dynamic) : Void
	{
		#if air
		flash.Lib.trace(v);
		#elseif (sys || nodejs)
		Sys.println(v);
		#else
		haxe.unit.TestRunner.print(v);
		#end
	}
}

class CustomPrintClient extends PrintClient
{
	public function new()
	{
		super();
		newline = #if js "<br/>" #else "\n" #end;
		tab = #if js "&nbsp;" #else " " #end;
	}

	override function printReport()
	{
		super.printReport();
		output += newline;

		Tester.print(newline + output);
	}
}