module Metrics::Duplication

import IO;
import Map;
import Set;
import List;
import String;
import Relation;
import util::Math;
import util::Resources;
import ProjectLoader::Loader;
import DataTypes::LocationDetails;

private alias FileLine = tuple[loc file, int line];

Duplication duplicates = ();
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
private rel[map[int, str],map[int, str]] mapLines(list[str] code)
{
	rel[map[int, str],map[int, str]] allCodes = {};
    map[int, str] codesTrimmed = ();
    map[int, str] originalCodes = ();
    int lineNumber = 1;
	for (line <- code)
    {
    	totalCodeLength+=1;
        codesTrimmed+=(lineNumber:trim(line));
        originalCodes+=(lineNumber:line);
        lineNumber+=1;
    }
    allCodes+={<codesTrimmed,originalCodes>};
    return allCodes;
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
public DuplicationData calculateDuplication(loc application)
{
    reset();
    map[loc, list[str]] files = getFilesPerLocation(application);
	for (file <- files) calculateDuplicationForFile(files[file], file);
	int totalDuplicateLines = 0;
	for (duplicate <- duplicates) totalDuplicateLines+=size(duplicates[duplicate]);
    return <percent(totalDuplicateLines, totalCodeLength), duplicates>;
}

private void addDuplicate(loc src, int srcLine, loc dest, int destLine, str codeLine)
{
	if (src notin(duplicates)) duplicates+=(src:{});
	duplicates[src]+=<{<src,srcLine>},{<dest,destLine>},codeLine>;
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
private void calculateDuplicationForFile(list[str] code, loc file)
{
    rel[map[int, str],map[int, str]] lineMapping = mapLines(code);
    map[int, str] codes = getFirstFrom(domain(lineMapping));
    map[int, str] original = getFirstFrom(range(lineMapping));
    for (startLine <- [1..size(codes)+1])
    {
    	list[str] chunk = [(codes[line]) | line <- [startLine..(startLine+minimumLength)], (startLine+minimumLength-1) <= size(codes), !startsWith(codes[line], "import"), !startsWith(codes[line], "//"),!startsWith(codes[line], "/*"),!startsWith(codes[line], "*/"),!startsWith(codes[line], "*")];
        if (size(chunk) != minimumLength) continue;
        str hash = md5Hash(chunk);
        if (hash notin(chunkHashes)) chunkHashes+=(hash:<file, startLine>);
        else
        {
			for (i <- [0..minimumLength])
			{
				addDuplicate(chunkHashes[hash].file, chunkHashes[hash].line+i, file, startLine+i, original[startLine+i]);
			}
        }
    }
}





