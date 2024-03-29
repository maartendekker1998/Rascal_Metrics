module Helpers::Documentation

import DataTypes::LocationDetails;
import Helpers::Loader;
import lang::java::jdt::m3::Core;
import String;

@doc
{
	gets all the documentation (comments) out of an application
}
public map[loc, list[LocationDetails]] getComments(loc application){
	
	M3 model = getM3ModelFromEclipseProject(application);
	
	map[loc, list[LocationDetails]] commentsPerFile  = ();
	
	for (doc <- model.documentation){

		loc uri = toLocation(doc.comments.uri);

		list[LocationDetails] locationDetailsList = commentsPerFile[uri]?[];
		locationDetailsList += createCommentDetails(doc.comments);
		commentsPerFile[uri] = locationDetailsList;
	}
	
	return commentsPerFile;
}