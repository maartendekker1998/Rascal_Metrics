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