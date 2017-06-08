package ;

import mcover.coverage.client.PrintClient;
import tink.testrunner.Runner;
import tink.unit.TestBatch;

class Tester
{
	//public var result(default, null) : TestResult;

	public static function main() : Void
	{
//		#if air
//		TestRunner.print = flash.Lib.trace;
//		#end

		var tester = new Tester();
		tester.test(
			function(results : BatchResult) : Void
			{
				//tester.coverage();

				exit(results.summary().failures.length);
			});

		//exit(0);
		//exit(runner.result.success ? 0 : 1);
	}

	public function new()
	{
	}

	private function test(handler : BatchResult -> Void) : Void
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

		/*var runner = new TestRunner();
		result = runner.result;
		runner.add(new filesystem.FileTestCase());*/

//		#if air
//		try
//		{
//			runner.run();
//		}
//		catch(error : flash.errors.Error)
//		{
//			print(error.getStackTrace());
//			exit(1);
//		}
//		#else
//		runner.run();
//		#end
	}

	private function coverage() : Void
	{
		print("---------------------------------------");
		print("-------------- COVERAGE ---------------");
		print("---------------------------------------");

		var logger = mcover.coverage.MCoverage.getLogger();
		logger.addClient(new CustomPrintClient());
		logger.report();
	}

	private static function exit(code : Int = 0) : Void
	{
		#if (sys || nodejs)
		Sys.exit(code);
		#elseif air
		untyped __global__["flash.desktop.NativeApplication"].nativeApplication.exit(code);
		#end
	}

	public inline static function print(v : Dynamic) : Void
	{
		trace(v);
		//TestRunner.print(v);
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