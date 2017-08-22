package ;

import mcover.coverage.client.EMMAPrintClient;
import tink.testrunner.Runner;
import tink.unit.TestBatch;

class Tester
{
	public static function main() : Void
	{
		#if phantomjs
		js.Browser.window.onerror = function(event : haxe.extern.EitherType<js.html.Event, String>, msg : String, line : Int, char : Int, data : Dynamic) : Bool
		{
			print('UNCAUGHT ERROR: ' + event);
			print('Exiting...');
			haxe.Timer.delay(function() js.phantomjs.Phantom.exit(1), 250);
			return false;
		}
		#end
		test(function(result : BatchResult) : Void
			 {
				 coverage();

				 Runner.exit(result);
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
					new test.filesystem.FileTestCase(),
					new test.filesystem.FileToolsTestCase()
				])
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
		#elseif js
		js.Browser.window.console.log(v);
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
		newline = "\n";
		tab = " ";
	}

	override function printReport()
	{
		super.printReport();
		output += newline;

		Tester.print(newline + output);
	}
}