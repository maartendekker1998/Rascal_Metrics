module DataTypes::DuplicationDetails

public alias Duplication = map[loc,rel[rel[loc,int],rel[loc,int],str]];
public alias DuplicationData = tuple[real percent, Duplication duplication];
public alias Pair = tuple[int line, str file];
public alias DuplicationItem = tuple[Pair src, Pair dest, str code];