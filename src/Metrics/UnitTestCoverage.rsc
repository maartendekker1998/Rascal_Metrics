module Metrics::UnitTestCoverage

import lang::java::m3::AST;
import Helpers::Loader;

private map[loc,Declaration] unitTestFiles = ();

@doc
{
	Calculates unit tests and returns a map consisting them.
}
public map[str,int] calculateUnitTests(loc application, lrel[Declaration method, int size] allFunctionsAndSizes)
{
	unitTestFiles = ();
	map[str,int] unitTests = countAsserts(application);
	unitTests += countUnitTests();
	return unitTests;
}

@doc
{
	Counts asset checks in the unittest framework, all posible 
	asserts are checked and counted as an assert.
	Fail asserts are also counted
}
private map[str,int] countAsserts(loc application)
{
	set[loc] files = getJavaFileLocationsFromResource(getResourceFromEclipseProject(application));
	int asserts = 0;
	int fails = 0;
	set[Declaration] asts = createAstsFromFiles(files, false);
	for (ast <- asts)
	{
		visit (ast)
		{
			case /assert(Equals|NotEquals|True|False|Throws|ArrayEquals|Null|NotNull|Same|NotSame|That|All|IterableEquals|LinesMatch|Timeout|TimeoutPreemptively)/:
			{
				unitTestFiles+=(ast.src:ast);
				asserts+=1;
			}
			case /^fail$/:
			{
				unitTestFiles+=(ast.src:ast);
				fails+=1;
			}
		}
	}
	return ("assert":asserts, "fail":fails);
}

@doc
{
	Counts unittest functions
}
private map[str,int] countUnitTests()
{
	int unitTestFunctions = 0;
	for (file <- unitTestFiles)
	{
		visit (unitTestFiles[file])
		{
			case e:\method(_, _, _, _, Statement impl):
			{
				unitTestFunctions+=1;
			}
		}
	}
	return ("tests":unitTestFunctions);
}