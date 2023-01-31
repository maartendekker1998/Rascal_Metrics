module DataTypes::LocationDetails

public alias LocationDetails = tuple[int offset, int length, int beginline, int begincolumn, int endline, int endcolumn];

public LocationDetails createCommentDetails(loc comments){
	return <comments.offset, comments.length, comments.begin.line, comments.begin.column, comments.end.line, comments.end.column>;
}





