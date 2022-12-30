module Metrics::UnitTestCoverage

import lang::java::m3::AST;
import ProjectLoader::Loader;

map[loc,Declaration] unitTestFiles = ();

public map[str,int] calculateUnitTestCoverage(loc application, lrel[Declaration method, int size] allFunctionsAndSizes)
{
	unitTestFiles = ();
	map[str,int] unitTestCoverage = countAsserts(application);
	unitTestCoverage += calculateCoverage();
	return unitTestCoverage;
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

private map[str,int] calculateCoverage()
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

