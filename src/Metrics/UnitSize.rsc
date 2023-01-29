module Metrics::UnitSize

import Helpers::Documentation;
import DataTypes::LocationDetails;
import ProjectLoader::Loader;
import lang::java::m3::AST;
import IO;
import String;
import Metrics::Volume;

public lrel[Declaration method, int size] calculateUnitsAndSize(application){

	map[loc, list[LocationDetails]] comments = getComments(application);
	
	set[loc] files = getJavaFileLocationsFromResource(getResourceFromEclipseProject(application));
	
	set[Declaration] asts = createAstsFromFiles(files, false);
	
	lrel[Declaration method, int size] allFunctionsAndSizes = [];
	
	visit(asts){
		case function: \method(_, _, _, _, Statement impl): {
			allFunctionsAndSizes += addFunction(function, comments);
		}
		case constructor: \constructor(_, _, _, Statement impl):
		{
			allFunctionsAndSizes += addFunction(constructor, comments);
		}
	}
	
	return allFunctionsAndSizes;
}

private tuple[Declaration method, int size] addFunction(function, map[loc, list[LocationDetails]] comments)
{
	list[str] functionLines = readFileLines(function.src);				
	loc functionLocation = toLocation(function.src.uri);
	int volume = calculateLOC(functionLines, comments[functionLocation]?[], function.src.begin.line);
	tuple[Declaration method, int size] DeclarationAndSize = <function, volume>;
	return DeclarationAndSize;
}










