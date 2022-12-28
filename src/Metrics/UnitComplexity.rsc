module Metrics::UnitComplexity

import IO;
import lang::java::m3::AST;

public void getComplexity(lrel[Declaration method, int size] allFunctionsAndSizes){
	
	for(fns <- allFunctionsAndSizes){
		computeComplexity(fns.method);
	}	
	
	return;
}

int computeComplexity(Declaration method){
	
	//https://stackoverflow.com/questions/40064886/obtaining-cyclomatic-complexity/40069656#40069656
	
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
    
    //println("method <method.name> has complexity <result>");
    
    return result;
}