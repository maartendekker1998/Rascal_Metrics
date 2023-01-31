module Metrics::Volume

import String;
import lang::java::jdt::m3::Core;
import Helpers::Loader;
import util::Resources;
import Helpers::Documentation;
import DataTypes::LocationDetails;

@doc
{
	Calculates volume of a given application
}
public int calculateVolume(loc application){

	map[loc, list[LocationDetails]] commentsPerFile = getComments(application);
	map[loc, list[str]] files = getFilesPerLocation(application);
	
	int volume = 0;
	
	for (x <- files){
		volume += calculateLOC(files[x], commentsPerFile[x]?[], 1);
	}
	
	return volume;
}

@doc
{
	Calculates the lines of actual code per file, comments do not count
	There are 2 types of comments to detect in the code
	- Single line comments
	    *  a single line comment may still contain code before the start of the comment
	
	- Multi line comments
	    * on the first line, it may contain code before the start of the multiline comment
	    * on the last line, it may contain code after the end of the multiline comment
	    * on the lines inbetween, no code can exsist
}
public int calculateLOC(list[str] lines, list[LocationDetails] comments, int startIndex){

	int LOC = 0;
	int i = startIndex;

	void incrementLineCounter(){ i += 1; }
	void incrementLOC(){ LOC += 1; }
	
	map[int, LocationDetails] singleLineComments = (c.beginline:c | c <- comments, c.beginline == c.endline);
		
	list[LocationDetails] multiLineComments = [ c | c <- comments, c.beginline != c.endline];
	
	list[int] multiLineBegin = [];
	list[int] multiLineEnd = [];
	list[int] multiLineMiddle = [];
		
	for (mlc <- multiLineComments){
		multiLineBegin += mlc.beginline;
		multiLineEnd += mlc.endline;
		multiLineMiddle += [(mlc.beginline+1)..mlc.endline];
	}
	
	for (l <- lines){
	
		if (isEmpty(trim(l))) {
			incrementLineCounter();
			continue;
		}
	
		if (i in multiLineMiddle){
			//  This case can not contain any code, skip immediately
			incrementLineCounter();
			continue;
		}
		
		if (i in multiLineBegin){
			// This case may only contain code before the '/**'
			// if the line starts with /** then it is a pure comment and we can skip it
			
			if (/^\/\*/ := trim(l)) {
				incrementLineCounter();
				continue;
			}
		}
		
		if (i in multiLineEnd){
			// This case may only contain code after the '*/'
			// if this line ends with '*/' then it is a pure comment and we can skip it			
			if (/\*\/$/ := trim(l)) {
				incrementLineCounter();
				continue;
			}
		}
	
		if (singleLineComments[i]?){
			LocationDetails c = singleLineComments[i];
			
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
}

@doc
{
	Obtains all the files per location of an application
}
private map[loc, list[str]] getFilesPerLocation(loc application){
	
	Resource r = getResourceFromEclipseProject(application);
	set[loc] fileLocations = getJavaFileLocationsFromResource(r);
	
	//now we need to get all the lines for each file
	map[loc, list[str]] files = getJavaFilesFromLocations(fileLocations);
	
	return files;
}