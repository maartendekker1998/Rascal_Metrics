module Helpers::Loader

import lang::java::jdt::m3::Core;
import util::Resources;
import IO;

@doc
{
	Uses the M3 model to get the project itself from Eclipse
}
public Resource getResourceFromEclipseProject(loc application){
	return getProject(application);
}

@doc
{
	Uses the M3 model to create an Eclipse project
}
public M3 getM3ModelFromEclipseProject(loc application){
	return createM3FromEclipseProject(application);
}

@doc
{
	Obtains only the files that uses the ".java" extension.
}
public set[loc] getJavaFileLocationsFromResource(Resource r) {
	set[loc] fileList = { a | /file(a) <- r, a.extension == "java" };
	return fileList;
}

@doc
{
	Obtains the code of java files from file locations.
}
public map[loc, list[str]] getJavaFilesFromLocations(set[loc] fileLocations){
	
	map[loc, list[str]] files = ();
	
	for (f <- fileLocations ){	
		files[f] = readFileLines(f);
	}
	
	return files;
}


@doc
{
	Obtains all the files from an application
}
private map[loc, list[str]] getFilesPerLocation(loc application){
	
	Resource r = getResourceFromEclipseProject(application);
	set[loc] fileLocations = getJavaFileLocationsFromResource(r);
	
	//now we need to get all the lines for each file
	map[loc, list[str]] files = getJavaFilesFromLocations(fileLocations);
	
	return files;
}