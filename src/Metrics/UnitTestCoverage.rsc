module Metrics::UnitTestCoverage

import IO;
import Map;
import Relation;
import List;
import String;
import util::Resources;
import lang::java::m3::AST;
import ProjectLoader::Loader;
import lang::java::jdt::m3::Core;

map[loc,Declaration] unitTestFiles = ();
map[loc,Declaration] allFiles = ();

public map[str,int] calculateUnitTestCoverage(loc application, lrel[Declaration method, int size] allFunctionsAndSizes)
{
	map[str,int] unitTestCoverage = countAsserts(application);
	calculateCoverage(application, allFunctionsAndSizes);
	return unitTestCoverage;
}

private map[str,int] countAsserts(loc application)
{
	set[loc] files = getJavaFileLocationsFromResource(getResourceFromEclipseProject(application));
	int asserts = 0;
	int fails = 0;
	map[str,int] assertions = ();
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
			default: 
			{
				allFiles+=(ast.src:ast);
			}
		}
	}
	assertions+=("assert":asserts);
	assertions+=("fail":fails);
	return assertions;
}

private void calculateCoverage(loc ap, lrel[Declaration method, int size] allFunctionsAndSizes)
{
	M3 model = createM3FromEclipseProject(ap);
	set[loc] methods = methods(model);
	set[Declaration] fileAST = createAstsFromFiles(methods, false);
	for (x <- fileAST)
	{
		if (contains(x.src.path, "testFunction"))
		{
			println("<x.src>");
		}
		
		
	}
	//methodFiles = model.declarations[l];
	//println(methodFiles);
	//Declaration fileAST = createAstFromFile(l2, true);
	//println(model.declarations[l2]);
	//for (m <- methods)
	//{
	//	//println(m);
	//	
	//	Declaration fileAST = createAstFromFile(l, true);
	//	println(fileAST);
	//	for (x <- fileAST)
	//	{
	//		println(x);
	//	}
	//	//for (x <- methodASTs)
	//	//{
	//	//println("haloooooooooooooooo <contains(x,"testFile")>");
	//	//}
	//	//visit (fileAST)
	//	//{
	//	//	case e:\methodCall(_,_,_):
	//	//	{
	//	//		println("E: <e>");
	//	//	}
	//	//	case e:\methodCall(_,_,_,_):
	//	//	{
	//	//		println("E: <e>");
	//	//	}
	//	//}
	//	
	//	//println(fileAST.decl);
	//	break;
	//}
	//println(model.containment);

}
//private void calculateCoverage(lrel[Declaration method, int size] allFunctionsAndSizes)
//{
//	map[str,int] calledMethods = ();
//	map[str,int] bla = ();
//	list[Declaration] p = [i | <i,y> <- allFunctionsAndSizes];
//	for (d <- p)
//	{
//		bla+=("<d.name>":0);
//	}
//	//println(size(allFiles-unitTestFiles));
//	//println(size(unitTestFiles));
//	for (f <- unitTestFiles)
//	{
//		visit (unitTestFiles[f])
//		{
//			case e:\methodCall(_,_,_):
//			{
//				calledMethods+=("<e.name>":0);
//			}
//			case Expression e:\methodCall(_,_,_,_):
//			{
//				visit (e)
//				{
//					case ee:\simpleName(_): 
//					{
//					println(e.decl);
//					calledMethods+=("<e.name>":0);
//					}
//				}
//			}
//		}
//		//if (contains(m.path, "TestIdentifer")) println(unitTestMethods[m]);
//	}
//	println(size(calledMethods));
//	for (x <- calledMethods)
//	{
//	;
//		//println("   <x>");
//		//println(x in(bla));
//	}
//	println(size(p));
//}

