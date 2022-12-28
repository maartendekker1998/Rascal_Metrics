module Metrics::UnitSize
import Helpers::Documentation;
import DataTypes::LocationDetails;
import ProjectLoader::Loader;
import lang::java::m3::AST;
import IO;
import String;
import Metrics::Volume;

lrel[Declaration method, int size] calculateUnitsAndSize(application){

	map[loc, list[LocationDetails]] comments = getComments(application);
	
	set[loc] files = getJavaFileLocationsFromResource(getResourceFromEclipseProject(application));
	
	set[Declaration] asts = createAstsFromFiles(files, false);
	
	lrel[Declaration method, int size] allFunctionsAndSizes = [] ;
	
	visit(asts){
		case function: \method(_, _, _, _, Statement impl): {
		
			list[str] function_lines = readFileLines(function.src);				
			loc function_location = toLocation(function.src.uri);
			int volume = calculateLOC(function_lines, comments[function_location]?[], function.src.begin.line);
			lrel[Declaration method, int size] DeclarationAndSize = [<function, volume>];
			allFunctionsAndSizes += DeclarationAndSize;
		}
	}
	
	//for (x <- allFunctionsAndSizes){
	//	println("<x.method.name> has size <x.size>");
	//	break;
	//}

	return allFunctionsAndSizes;
}