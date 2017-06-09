package ;

import mcover.coverage.client.EMMAPrintClient;
import tink.testrunner.Runner;
import tink.unit.TestBatch;

class Tester
{
	public static function main() : Void
	{
		test(function(result : BatchResult) : Void
		     {
			     coverage();

			     #if air
			     untyped __global__["flash.desktop.NativeApplication"]
							.nativeApplication
							.exit(result.summary().failures.length);
			     #else
			     Runner.exit(result);
			     #end
		     });
	}

	private static function test(handler : BatchResult -> Void) : Void
	{
		print("%%%RUNNER-START%%%");
		print("---------------------------------------");
		print("----------- STARTING RUNNER -----------");
		print("---------------------------------------");

		Runner.run(
			TestBatch.make(
				[
					new filesystem.FileTestCase()
				])
			#if air , new AIRRunnerReporter() #end
		).handle(function(result : BatchResult) : Void
		         {
			         print("%%%RUNNER-END%%%");
			         handler(result);
		         });
	}

	private static function coverage() : Void
	{
		print("%%%COVERAGE-START%%%");
		print("---------------------------------------");
		print("-------------- COVERAGE ---------------");
		print("---------------------------------------");

		var emma = new EMMAPrintClient();

		var logger = mcover.coverage.MCoverage.getLogger();
		logger.addClient(emma);
		logger.addClient(new CoveragePrintClient());
		logger.report();

		print("%%%COVERAGE-END%%%");
		print("");
		print("%%%EMMA-START%%%");
		print(emma.xml.toString());
		print("%%%EMMA-END%%%");
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

class CoveragePrintClient extends mcover.coverage.client.PrintClient
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

#if air
class AIRRunnerReporter extends tink.testrunner.Reporter.BasicReporter
{
	override function println(v : String) flash.Lib.trace(v);
}
#end