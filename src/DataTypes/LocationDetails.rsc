module DataTypes::LocationDetails

public alias LocationDetails = tuple[int offset, int length, int beginline, int begincolumn, int endline, int endcolumn];
public alias DuplicationData = tuple[int percent, Duplication duplication];
public alias Duplication = map[str,rel[rel[str,int],rel[str,int],str]];
public alias Pair = tuple[int line, str file];
public alias DuplicationItem = tuple[Pair src, Pair dest, str code];

public LocationDetails createCommentDetails(loc comments){
	return <comments.offset, comments.length, comments.begin.line, comments.begin.column, comments.end.line, comments.end.column>;
}