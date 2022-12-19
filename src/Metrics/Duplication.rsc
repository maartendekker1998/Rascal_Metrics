module Metrics::Duplication

import IO;
import Map;
import List;
import Relation;
import util::Math;

//% = lines of duplicate/total*100

int minimumLength=6;

private map[int, str] readDup()
{
    map[int, str] codes = ();
    loc code = |file:///G:/rascal/Rascal-OU/dupCode.txt|;
    int lineNumber = 1;
    for (line <- readFileLines(code))
    {
        codes+=(lineNumber:line);
        lineNumber+=1;
    }
    return codes;
}

public void dup6()
{
	map[int,int] duplicates = ();
    map[int,str] code = readDup();
    map[str,int] chunkHashes = ();
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
				duplicates+=(chunkHashes[hash]+i:0);
				duplicates+=(startLine+i:0);
			}
        }
    }
    real a = size(duplicates)/toReal(size(code))*100;
    int percent = percent(toReal(size(duplicates)),toReal(size(code)));
    println("duplicate code: <a>%");
}





