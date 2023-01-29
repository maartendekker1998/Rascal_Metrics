module Metrics::UnitComplexity

import lang::java::m3::AST;

public lrel[Declaration, int, int] getComplexity(lrel[Declaration method, int size] allFunctionsAndSizes){

	lrel[Declaration method, int size, int complexity] allFunctionsWithSizeAndComplexity = [];
	
	for(f <- allFunctionsAndSizes){
		int cc = computeComplexity(f.method);
		allFunctionsWithSizeAndComplexity += <f.method, f.size, cc>;
	}
	
	return allFunctionsWithSizeAndComplexity;
}

private int computeComplexity(Declaration method){
	
	// Posted by Rascal Core Developer
	// https://stackoverflow.com/questions/40064886/obtaining-cyclomatic-complexity/40069656#40069656
	
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