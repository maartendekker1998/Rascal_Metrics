module Helpers::Math

import util::Math;
import String;


@doc
{
	Rounds a percentage of to 1 digit after the dot, the buildin Rascal
	function to calculate a percentage and rounds off to an integer
}
public real roundTwoDigits(real n)
{
	if (endsWith(toString(n),".")) return n;
	return toReal(substring(toString(n),0,findFirst(toString(n),".")+2));
}