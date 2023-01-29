module DataTypes::LocationDetails

import lang::java::m3::AST;

public alias LocationDetails = tuple[int offset, int length, int beginline, int begincolumn, int endline, int endcolumn];
public alias DuplicationData = tuple[int percent, Duplication duplication];
public alias Duplication = map[loc,rel[rel[loc,int],rel[loc,int],str]];
public alias Pair = tuple[int line, str file];
public alias DuplicationItem = tuple[Pair src, Pair dest, str code];
public alias UnitComplexity = tuple[lrel[Declaration, int, int] functionsWithSizeAndComplexity,map[str,real] complexity];

public alias DashboardData = tuple
[
	str name,
	DuplicationData duplication, 
	UnitComplexity unitComplexity,
	map[str,real] unitSize,
	int linesOfCode,
	int totalFunctions,
	map[str,int] unitTests,
	str executionTime
];

public LocationDetails createCommentDetails(loc comments){
	return <comments.offset, comments.length, comments.begin.line, comments.begin.column, comments.end.line, comments.end.column>;
}