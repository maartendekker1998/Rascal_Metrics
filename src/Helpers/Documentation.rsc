module Helpers::Documentation

import DataTypes::LocationDetails;
import ProjectLoader::Loader;
import lang::java::jdt::m3::Core;
import String;

// gets all the documentation out of a application
public map[loc, list[LocationDetails]] getComments(loc application){
	
	M3 model = getM3ModelFromEclipseProject(application);
	
	map[loc, list[LocationDetails]] comments_per_file  = ();
	
	for (doc <- model.documentation){

		loc uri = toLocation(doc.comments.uri);

		list[LocationDetails] LocationDetails_list = comments_per_file[uri]?[];
		LocationDetails_list += createCommentDetails(doc.comments);
		comments_per_file[uri] = LocationDetails_list;
	}
	
	return comments_per_file;
}