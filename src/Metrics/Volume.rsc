module Metrics::Volume

import String;
import lang::java::jdt::m3::Core;
import ProjectLoader::Loader;
import util::Resources;
import Helpers::Documentation;
import DataTypes::LocationDetails;

public int calculateVolume(loc application){

	map[loc, list[LocationDetails]] comments_per_file = getComments(application);
	map[loc, list[str]] files = getFilesPerLocation(application);
	
	int volume = 0;
	
	for (x <- files){
		volume += calculateLOC(files[x], comments_per_file[x]?[], 1);
	}
	
	return volume;
}


// calculate the lines of actual code per file
// comments do not count
public int calculateLOC(list[str] lines, list[LocationDetails] comments, int startIndex){

	int LOC = 0;
	int i = startIndex;

	void incrementLineCounter(){ i += 1; }
	void incrementLOC(){ LOC += 1; }
	
	// we have to detect 2 types of comments in the code
	
	//  - single line comments
	//    *  a single line comment may still contain code before the start of the comment
	
	//  - multi line comments
	//    * on the first line, it may contain code before the start of the multiline comment
	//    * on the last line, it may contain code after the end of the multiline comment
	//    * on the lines inbetween, no code can exsist
	
	
	map[int, LocationDetails] single_line_comments = ( c.beginline:c | c <- comments , c.beginline == c.endline);
	//println("the single line comments are: <single_line_comments>");
		
	list[LocationDetails] multi_line_comments = [ c | c <- comments , c.beginline != c.endline];
	//println("the multi line comments are: <multi_line_comments>");
	
	list[int] multi_line_begin = [];
	list[int] multi_line_end = [];
	list[int] multi_line_middle = [];
		
	for (mlc <- multi_line_comments){
		multi_line_begin += mlc.beginline;
		multi_line_end += mlc.endline;
		multi_line_middle += [(mlc.beginline+1)..mlc.endline];
	}
	
	for (l <- lines){
	
		if (isEmpty(trim(l))) {
			incrementLineCounter();
			continue;
		}
	
		if (i in multi_line_middle){
			//  This case can not contain any code, skip immediately
			incrementLineCounter();
			continue;
		}
		
		if (i in multi_line_begin){
			// This case may only contain code before the '/**'
			// if the line starts with /** then it is a pure comment and we can skip it
			
			if (/^\/\*/ := trim(l)) {
				incrementLineCounter();
				continue;
			}
		}
		
		if (i in multi_line_end){
			// This case may only contain code after the '*/'
			// if this line ends with '*/' then it is a pure comment and we can skip it			
			if (/\*\/$/ := trim(l)) {
				incrementLineCounter();
				continue;
			}
		}
	
		if (single_line_comments[i]?){
			LocationDetails c = single_line_comments[i];
			
			//a single line comment may still contain code before the start of the comment
			
			//if the size of the line itself is not bigger then the length of the comment, this line only contains a comment
			//therefore we do not count this line towards the LOC of the file.
			if (!(size(trim(l)) > c.length)){
				incrementLineCounter();
				continue;
			} 
		}
		
		incrementLineCounter();
		incrementLOC();
	}
	return LOC;
}public map[loc, list[str]] getFilesPerLocation(loc application){
	
	Resource r = getResourceFromEclipseProject(application);
	set[loc] file_locations = getJavaFileLocationsFromResource(r);
	
	//now we need to get all the lines for each file
	map[loc, list[str]] files = getJavaFilesFromLocations(file_locations);
	
	return files;
}

