module Metrics::Duplication

import IO;
import Map;
import List;
import String;
import Relation;
import util::Math;

map[str,int] chunkHashes = ();
map[int,int] duplicates = ();
int totalCodeLenth = 0;
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
    totalCodeLenth = 0;
}

@doc
{
	Returns a map with linenumber mappings to the corresponding line.
	Import statements are not added to the list, but they are 
	 included in the totalCodeLength for the total percentage
	 calculation.
}
private map[int, str] mapLines(loc file)
{
    map[int, str] codes = ();
    int lineNumber = 1;
	for (line <- readFileLines(file))
    {
    	totalCodeLenth+=1;
        line = trim(line);
    	if (startsWith(line, "import")) continue;//replace with m3 model
    	println("line: <line>");
        codes+=(lineNumber:line);
        lineNumber+=1;
    }
    return codes;
}

@doc
{
	Obtain files
	returns list with files
}
private list[loc] getFiles()
{
	list[loc] files = [|file:///G:/rascal/Rascal-OU/dupCode.txt|];
    files += |file:///G:/rascal/Rascal-OU/dupCode2.txt|;
    return files;
}

@doc
{
	Calculate the final duplication percentage, this calculates ofer all the files provided
	returns integer as the percentage, actual calculation is 'duplicate lines' / 'total lines' * 100
}
public int calculateDuplication()
{
    reset();
	list[loc] files = getFiles();
	for (file <- files) calculateDuplicationForFile(file);
    println("[debug] : <totalCodeLenth> <size(duplicates)> <percent(size(duplicates), totalCodeLenth)>");
    return percent(size(duplicates), totalCodeLenth);
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
	 loc file | file to check
}
private void calculateDuplicationForFile(loc file)
{
    // println(file);
    map[int,str] lineMapping = mapLines(file);
    for (startLine <- [1..size(lineMapping)+1])
    {
    	list[str] chunk = [(lineMapping[line]) | line <- [startLine..(startLine+minimumLength)], (startLine+minimumLength-1) <= size(lineMapping)];
        if (isEmpty(chunk)) continue;
        str hash = md5Hash(chunk);
        if (hash notin(chunkHashes)) chunkHashes+=(hash:startLine);
        else
        {
			for (i <- [0..minimumLength]) duplicates+=(startLine+i:0);
        }
    }
}





