package ;

import haxe.unit.TestResult;
import haxe.unit.TestRunner;
import mcover.coverage.client.PrintClient;

class Runner
{
	public var result(default, null) : TestResult;

	public static function main() : Void
	{
		#if air
		TestRunner.print = flash.Lib.trace;
		#end

		var runner = new Runner();
		runner.test();
		runner.coverage();

		exit(runner.result.success ? 0 : 1);
	}

	public function new()
	{
	}

	private function test() : Void
	{
		print("---------------------------------------");
		print("----------- STARTING RUNNER -----------");
		print("---------------------------------------");

		var runner = new TestRunner();
		result = runner.result;
		runner.add(new filesystem.FileTestCase());

		#if air
		try
		{
			runner.run();
		}
		catch(error : flash.errors.Error)
		{
			print(error.getStackTrace());
			exit(1);
		}
		#else
		runner.run();
		#end
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
		#if (cpp || cs || hl || java || lua || neko || php || python || macro)
		Sys.exit(code);
		#elseif air
		var app = untyped __global__["flash.desktop.NativeApplication"];
		app.nativeApplication.exit(code);
		#end
	}

	public inline static function print(v : Dynamic) : Void
	{
		TestRunner.print(v);
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

		Runner.print(newline + output);
	}
}