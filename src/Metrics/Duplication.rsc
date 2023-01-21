module Metrics::Duplication

import IO;
import Map;
import List;
import String;
import Relation;
import util::Math;
import util::Resources;
import ProjectLoader::Loader;

alias FileLine = tuple[str file, int line];

map[str,rel[rel[str,int],rel[str,int]]] duplicates = ();
map[str,FileLine] chunkHashes = ();
int totalCodeLength = 0;
int minimumLength=6;

@doc
{
	Resets the global values to default. Otherwise when the function is called 
	multiple times, the values will be reused.
}
private void reset()
{
    chunkHashes = ();
    duplicates = ();
    totalCodeLength = 0;
}

@doc
{
	Maps linenumbers with their corresponding line
	Import statements are not added to the list, but they are 
	 included in the totalCodeLength for the total percentage
	 calculation.
	Parameters:
	 list[str] code | The code to map
	returns a map with linenumber mappings to the corresponding line.
}
private map[int, str] mapLines(list[str] code)
{
    map[int, str] codes = ();
    int lineNumber = 1;
	for (line <- code)
    {
    	totalCodeLength+=1;
        line = trim(line);
        codes+=(lineNumber:line);
        lineNumber+=1;
    }
    return codes;
}

@doc
{
	Creates a map with files and their lines of code from a project
	Parameters:
	 loc application | project
	returns a map with files and their code
	
}
public map[loc, list[str]] getFilesPerLocation(loc application)
{
	Resource resource = getResourceFromEclipseProject(application);
	set[loc] fileLocations = getJavaFileLocationsFromResource(resource);
	return getJavaFilesFromLocations(fileLocations);
}

@doc
{
	Calculate the final duplication percentage, this calculates ofer all the files provided
	Parameters:
	 loc application | project
	returns integer as the percentage, actual calculation is 'duplicate lines' / 'total lines' * 100
}
public int calculateDuplication(loc application)
{
    reset();
    map[loc, list[str]] files = getFilesPerLocation(application);
	for (file <- files)
	{
		calculateDuplicationForFile(files[file], file.file);
		//if (size(duplicates) > 2)
		//break;
	}
	int totalDuplicateLines = 0;
	for (duplicate <- duplicates) totalDuplicateLines+=size(duplicate);
	println(duplicates);
	println("size m <totalDuplicateLines>");
	println(totalCodeLength);
    return percent(totalDuplicateLines, totalCodeLength);
}

void addDuplicate(str src, int srcLine, str dest, int destLine)
{
	//println("src: <src>:<srcLine> dest: <dest>:<destLine>");
	if (src notin(duplicates)) duplicates+=(src:{});
	duplicates[src]+=<{<src,srcLine>},{<dest,destLine>}>;
}

@doc
{
	Iterates through the line mapping to find duplicates.
	It starts with line number 1, and iterates through the size of the 
	 mapping plus 1 since lines are starting on 1 and not on 0.
	It creates chunks of a minimum length lines (default 6 in SIG)
	 those chunks are hashed and stored in a map with the first found line, if a hash later found again
	 which already exists in the map, then it means a duplicate has been found.
	Parameters:
	 list[str] code | the code of that file
}
private void calculateDuplicationForFile(list[str] code, str file)
{
	//println("<file>");
    map[int,str] lineMapping = mapLines(code);
    for (startLine <- [1..size(lineMapping)+1])
    {
    	list[str] chunk = [(lineMapping[line]) | line <- [startLine..(startLine+minimumLength)], (startLine+minimumLength-1) <= size(lineMapping), !startsWith(lineMapping[line], "import")];
        if (size(chunk) != minimumLength) continue;
        str hash = md5Hash(chunk);
        if (hash notin(chunkHashes)) chunkHashes+=(hash:<file, startLine>);
        else
        {
			for (i <- [0..minimumLength])
			{
				addDuplicate(chunkHashes[hash].file, chunkHashes[hash].line+i, file, startLine+i);
			}
        }
    }
}





