module Metrics::Duplication

import IO;
import Map;
import List;
import String;
import Relation;
import util::Math;

//% = lines of duplicate/total*100
map[str,int] chunkHashes = ();
map[int,int] duplicates = ();
int totalCodeLenth = 0;
int minimumLength=6;

private void reset()
{
    chunkHashes = ();
    duplicates = ();
    totalCodeLenth = 0;
}

private map[int, str] readDup(loc file)
{
    map[int, str] codes = ();
    int lineNumber = 1;
	for (line <- readFileLines(file))
    {
        line = trim(line);
    	if (startsWith(line, "import") || startsWith(line, "package")) continue;//replace with m3 model
    	println("line: <line>");
        codes+=(lineNumber:line);
        lineNumber+=1;
    }
    return codes;
}

public int calculateDuplication()
{
    reset();
	list[loc] files = [|file:///C:/Users/Bart/Desktop/rascal/dupCode.txt|];
    files += |file:///C:/Users/Bart/Desktop/rascal/dupCode2.txt|;
	for (file <- files) {println("dsf");calculateDuplicationForFile(file);};
    println("[debug] : <totalCodeLenth> <size(duplicates)> <percent(size(duplicates), totalCodeLenth)>");
    return percent(size(duplicates), totalCodeLenth);
}

private void calculateDuplicationForFile(loc file)
{
    // println(file);
    map[int,str] code = readDup(file);
    for (startLine <- [1..size(code)+1])
    {
    	list[str] chunk = [(code[line]) | line <- [startLine..(startLine+minimumLength)], (startLine+minimumLength-1) <= size(code)];
        if (isEmpty(chunk)) continue;
        str hash = md5Hash(chunk);
        if (hash notin(chunkHashes)) chunkHashes+=(hash:startLine);
        else
        {
			for (i <- [0..minimumLength])
			{
				duplicates+=(startLine+i:0);
			}
        }
    }
    totalCodeLenth+=size(code);
}





