module Metrics::UnitTestCoverage

import IO;
import util::Resources;
import lang::java::m3::AST;
import ProjectLoader::Loader;

public map[str,int] countAsserts(loc application)
{
	set[loc] files = getJavaFileLocationsFromResource(getResourceFromEclipseProject(application));
	int asserts = 0;
	int fails = 0;
	map[str,int] assertions = ();
	visit (createAstsFromFiles(files, false))
	{
		case /assert(Equals|NotEquals|True|False|Throws|rrayEquals|Null|NotNull|Same|NotSame|That|All|IterableEquals|LinesMatch|Timeout|TimeoutPreemptively)/:asserts+=1;
		case /^fail$/:fails+=1;
	}
	assertions+=("assert":asserts);
	assertions+=("fail":fails);
	return assertions;
}