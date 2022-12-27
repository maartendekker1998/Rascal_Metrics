module DataTypes::LocationDetails

alias LocationDetails = tuple[int offset, int length, int beginline, int begincolumn, int endline, int endcolumn];

public LocationDetails createCommentDetails(loc comments){
	LocationDetails ld = <comments.offset, comments.length, comments.begin.line, comments.begin.column, comments.end.line, comments.end.column>;
	return ld;
}