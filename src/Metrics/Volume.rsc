module Metrics::Volume

import IO;
import List;
import String;
import lang::java::jdt::m3::Core;
import ProjectLoader::Loader;
import util::Resources;


alias comment_details = tuple[int offset, int length, int beginline, int begincolumn, int endline, int endcolumn];

public comment_details createCommentDetails(loc comments){
	comment_details a = <comments.offset, comments.length, comments.begin.line, comments.begin.column, comments.end.line, comments.end.column>;
	return a;
}

public int calculateVolume(loc application){

	map[loc, list[comment_details]] comments_per_file = getComments(application);
	map[loc, list[str]] files = getFilesPerLocation(application);
	
	int volume = 0;
	
	for (x <- files){
		println("the file <x> contains:");
		volume += calculateLOC(files[x], comments_per_file[x]);
		
	}
	
	// no detection of empty lines or javadoc yet
	println("total lines of code : <volume>");

	return volume;
}


// calculate the lines of actual code per file
// comments do not count
public int calculateLOC(list[str] lines, list[comment_details] comments){

	int LOC = 0;
	int i = 1;

	void incrementLineCounter(){ i += 1; }
	void incrementLOC(){ LOC += 1; }
	
	// we have to detect 2 types of comments in the code
	
	//  - single line comments
	//    *  a single line comment may still contain code before the start of the comment
	
	//  - multi line comments
	//    * on the first line, it may contain code before the start of the multiline comment
	//    * on the last line, it may contain code after the end of the multiline comment
	//    * on the lines inbetween, no code can exsist
	
	
	map[int, comment_details] single_line_comments = ( c.beginline:c | c <- comments , c.beginline == c.endline);
	println("the single line comments are: <single_line_comments>");
	println();
		
		
	list[comment_details] multi_line_comments = [ c | c <- comments , c.beginline != c.endline];
	println("the multi line comments are: <multi_line_comments>");
	
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
			//  This case cannot contain any code, skip immediately
			incrementLineCounter();
			continue;
		}
		
		if (i in multi_line_begin){
			// TODO
			// This case may only contain code before the '/**'
			incrementLineCounter();
			continue;
		}
		
		if (i in multi_line_end){
			// TODO
			// This case may only contain code after the '*/'
			incrementLineCounter();
			continue;
		}
	
		if (single_line_comments[i]?){
			comment_details c = single_line_comments[i];
			
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
	println("lines are : <LOC>");
	return LOC;
}



public map[loc, list[str]] getFilesPerLocation(loc application){
	
	Resource r = getResourceFromEclipseProject(application);
	set[loc] file_locations = getJavaFileLocationsFromResource(r);
	
	//now we need to get all the lines for each file
	map[loc, list[str]] files = getJavaFilesFromLocations(file_locations);
	
	return files;
}

public map[loc, list[comment_details]] getComments(loc application){
	
	M3 model = getM3ModelFromEclipseProject(application);
	
	map[loc, list[comment_details]] comments_per_file  = ();
	
	for (doc <- model.documentation){

		loc uri = toLocation(doc.comments.uri);

	
		list[comment_details] comment_details_list = comments_per_file[uri]?[];
		comment_details_list += createCommentDetails(doc.comments);
		comments_per_file[uri] = comment_details_list;
	}
	
	//for (c <- comments_per_file){
	//	println("file <c> has comment specifications: <comments_per_file[c]>");
	//}
	
	return comments_per_file;
}