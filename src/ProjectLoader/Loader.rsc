module ProjectLoader::Loader

import lang::java::jdt::m3::Core;
import util::Resources;

import IO;

public Resource getResourceFromEclipseProject(loc application){
	return getProject(application);
}

public M3 getM3ModelFromEclipseProject(loc application){
	return createM3FromEclipseProject(application);
}



public set[loc] getJavaFileLocationsFromResource(Resource r) {
	set[loc] file_list = { a | /file(a) <- r, a.extension == "java" };
	return file_list;
}

public map[loc, list[str]] getJavaFilesFromLocations ( set[loc] file_locations ){
	
	map[loc, list[str]] files = ();
	
	for (f <- file_locations ){	
		files[f] = readFileLines(f);
	}
	
	return files;
}

public map[loc, list[str]] getFilesPerLocation(loc application){
	
	Resource r = getResourceFromEclipseProject(application);
	set[loc] file_locations = getJavaFileLocationsFromResource(r);
	
	//now we need to get all the lines for each file
	map[loc, list[str]] files = getJavaFilesFromLocations(file_locations);
	
	return files;
}
