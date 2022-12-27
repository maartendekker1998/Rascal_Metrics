module Metrics::UnitSize
import Helpers::Documentation;
import DataTypes::LocationDetails;
import ProjectLoader::Loader;
import lang::java::m3::AST;
import IO;
import String;
import Metrics::Volume;

public map[str,map[str,int]] calculateUnitSize(lrel[Declaration method, int size] allFunctionsAndSizes)
{
	for (<method,size> <- allFunctionsAndSizes)
	{
	;
		//println (method.src);
		//if (contains(method.src.uri, "ConcreteSlide")) println("<toLocation(method.src.uri)><method.name>: <size>");
	}
	return ();
}

public lrel[Declaration method, int size] calculateUnitsAndSize(application){

	map[loc, list[LocationDetails]] comments = getComments(application);
	
	set[loc] files = getJavaFileLocationsFromResource(getResourceFromEclipseProject(application));
	
	set[Declaration] asts = createAstsFromFiles(files, false);
	
	lrel[Declaration method, int size] allFunctionsAndSizes = [];
	
	visit(asts){
		case function: \method(_, _, _, _, Statement impl): {
			allFunctionsAndSizes += addFunction(function, comments);
		}
		case function: \method(_, _, _, _): {
			allFunctionsAndSizes += addFunction(function, comments);
		}
		case constructor: \constructor(_, _, _, Statement impl):
		{
			allFunctionsAndSizes += addFunction(constructor, comments);
		}
	}
	
	for (x <- allFunctionsAndSizes){
		println("<x.method.src><x.method.name> has size <x.size>\n");
	}
	
	return allFunctionsAndSizes;
}

private tuple[Declaration method, int size] addFunction(function, map[loc, list[LocationDetails]] comments)
{
	list[str] function_lines = readFileLines(function.src);				
	loc function_location = toLocation(function.src.uri);
	int volume = calculateLOC(function_lines, comments[function_location]?[], function.src.begin.line);
	tuple[Declaration method, int size] DeclarationAndSize = <function, volume>;
	return DeclarationAndSize;
}










