module Metrics::UnitComplexity

import lang::java::m3::AST;

@doc
{
	Calculates the complexity, for all functions
}
public lrel[Declaration, int, int] getComplexity(lrel[Declaration method, int size] allFunctionsAndSizes){

	lrel[Declaration method, int size, int complexity] allFunctionsWithSizeAndComplexity = [];
	
	for(f <- allFunctionsAndSizes){
		int cc = computeComplexity(f.method);
		allFunctionsWithSizeAndComplexity += <f.method, f.size, cc>;
	}
	
	return allFunctionsWithSizeAndComplexity;
}

@doc
{
	Visits the method and increases the complexity if a match has been found,
	the cases used here are recommended by Davy Landman, a Rascal Core Developer
	
	the source:
	
	Davy Landman, Alexander Serebrenik, and Jurgen Vinju. “Empirical Analysis 
	of the Relationship between CC and SLOC in a Large Corpus of Java Methods”. 
	In: Sept. 2014. doi: 10.1109/ICSME.2014.44.
}
private int computeComplexity(Declaration method){

	int result = 1;
    visit (method.impl) {
        case \if(_,_) : result += 1;
        case \if(_,_,_) : result += 1;
        case \case(_) : result += 1;
        case \do(_,_) : result += 1;
        case \while(_,_) : result += 1;
        case \for(_,_,_) : result += 1;
        case \for(_,_,_,_) : result += 1;
        case \foreach(_,_,_) : result += 1;
        case \catch(_,_): result += 1;
        case \conditional(_,_,_): result += 1;
        case \infix(_,"&&",_) : result += 1;
        case \infix(_,"||",_) : result += 1;
    }
        
    return result;
}