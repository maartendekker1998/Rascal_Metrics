module SIG::SigRanking

import util::Math;
import Helpers::Math;
import lang::java::m3::AST;
import DataTypes::LocationDetails;
import DataTypes::Rank;
import SIG::SigConstants;
import SIG::SigCategorisation;

@doc
{
	Gets the volume rank based on the lines of code respecting the SIG metrics
	The percentage of lines of code residing in units with more than 15 lines of code should not exceed 44.0%.
	percentage in units with more than 30 lines of code should not exceed 20.1%.
	The percentage in units with more than 60 lines should not exceed 6.3%.
}
public Rank getSIGVolumeRank(int linesOfCode){
	
	num kloc = toReal(linesOfCode)/1000;

	if      (kloc <  SIG_JAVA_KLOC_PLUS_PLUS)                                return plusplus;
	else if (kloc >= SIG_JAVA_KLOC_PLUS_PLUS && kloc < SIG_JAVA_KLOC_PLUS)   return plus;
	else if (kloc >= SIG_JAVA_KLOC_PLUS && kloc < SIG_JAVA_KLOC_O)           return neutral;
	else if (kloc >= SIG_JAVA_KLOC_O && kloc < SIG_JAVA_KLOC_MIN)            return min;
	else                                                                     return minmin;
}

@doc
{
	Gets the duplication rank based on the percentage.
}
public Rank getSIGDuplicationRank(real percentage){

	if     (percentage < SIG_DUPLICATION_PERCENTAGE_PLUS_PLUS)	return plusplus;
	elseif (percentage < SIG_DUPLICATION_PERCENTAGE_PLUS)       return plus;
	elseif (percentage < SIG_DUPLICATION_PERCENTAGE_O)          return neutral;
	elseif (percentage < SIG_DUPLICATION_PERCENTAGE_MIN)        return min;
	else            		                                    return minmin;	
}

@doc
{
	Obtains the SIG unit size rank
}
public Rank getSIGUnitSizeRank(map[str,real] unitSize)
{
	if      (unitSize[SIG_MODERATE]  <= MAX_UNIT_SIZE_THRESHOLDS_PLUS_PLUS[SIG_MODERATE]  && 
			 unitSize[SIG_HIGH]      == MAX_UNIT_SIZE_THRESHOLDS_PLUS_PLUS[SIG_HIGH]      &&
			 unitSize[SIG_VERY_HIGH] == MAX_UNIT_SIZE_THRESHOLDS_PLUS_PLUS[SIG_VERY_HIGH])
			 return plusplus;
			 
	else if (unitSize[SIG_MODERATE]  <= MAX_UNIT_SIZE_THRESHOLDS_PLUS[SIG_MODERATE]  && 
		     unitSize[SIG_HIGH]      == MAX_UNIT_SIZE_THRESHOLDS_PLUS[SIG_HIGH]      &&
		     unitSize[SIG_VERY_HIGH] == MAX_UNIT_SIZE_THRESHOLDS_PLUS[SIG_VERY_HIGH])
		 return plus;
		 
 	else if (unitSize[SIG_MODERATE]  <= MAX_UNIT_SIZE_THRESHOLDS_O[SIG_MODERATE]  && 
     		 unitSize[SIG_HIGH]      == MAX_UNIT_SIZE_THRESHOLDS_O[SIG_HIGH]      &&
    		 unitSize[SIG_VERY_HIGH] == MAX_UNIT_SIZE_THRESHOLDS_O[SIG_VERY_HIGH])
 		 return neutral;
 		 
 	else if (unitSize[SIG_MODERATE]  <= MAX_UNIT_SIZE_THRESHOLDS_MIN[SIG_MODERATE]  && 
     		 unitSize[SIG_HIGH]      <= MAX_UNIT_SIZE_THRESHOLDS_MIN[SIG_HIGH]      &&
    		 unitSize[SIG_VERY_HIGH] <= MAX_UNIT_SIZE_THRESHOLDS_MIN[SIG_VERY_HIGH])
 		 return min;
	
	else return minmin;
}

@doc
{
	Obtains the SIG unit complexity rank
}
public Rank getSIGUnitComplexityRank(map[str,real] unitComplexity)
{
	if      (unitComplexity[SIG_MODERATE]  <= MAX_UNIT_COMPLEXITY_THRESHOLDS_PLUS_PLUS[SIG_MODERATE]  && 
			 unitComplexity[SIG_HIGH]      == MAX_UNIT_COMPLEXITY_THRESHOLDS_PLUS_PLUS[SIG_HIGH]      &&
			 unitComplexity[SIG_VERY_HIGH] == MAX_UNIT_COMPLEXITY_THRESHOLDS_PLUS_PLUS[SIG_VERY_HIGH])
			 return plusplus;
			 
	else if (unitComplexity[SIG_MODERATE]  <= MAX_UNIT_COMPLEXITY_THRESHOLDS_PLUS[SIG_MODERATE]  && 
		     unitComplexity[SIG_HIGH]      == MAX_UNIT_COMPLEXITY_THRESHOLDS_PLUS[SIG_HIGH]      &&
		     unitComplexity[SIG_VERY_HIGH] == MAX_UNIT_COMPLEXITY_THRESHOLDS_PLUS[SIG_VERY_HIGH])
		 return plus;
		 
 	else if (unitComplexity[SIG_MODERATE]  <= MAX_UNIT_COMPLEXITY_THRESHOLDS_O[SIG_MODERATE]  && 
     		 unitComplexity[SIG_HIGH]      == MAX_UNIT_COMPLEXITY_THRESHOLDS_O[SIG_HIGH]      &&
    		 unitComplexity[SIG_VERY_HIGH] == MAX_UNIT_COMPLEXITY_THRESHOLDS_O[SIG_VERY_HIGH])
 		 return neutral;
 		 
 	else if (unitComplexity[SIG_MODERATE]  <= MAX_UNIT_COMPLEXITY_THRESHOLDS_MIN[SIG_MODERATE]  && 
     		 unitComplexity[SIG_HIGH]      <= MAX_UNIT_COMPLEXITY_THRESHOLDS_MIN[SIG_HIGH]      &&
    		 unitComplexity[SIG_VERY_HIGH] <= MAX_UNIT_COMPLEXITY_THRESHOLDS_MIN[SIG_VERY_HIGH])
 		 return min;
	
	else return minmin;
}

@doc
{
	Calculates a rank for the analyzebility, changeability and testability
	ISO 9126 categorisation helper function
}
public Rank calculateWeigedAverage(ranks){

	int rankCount = 0;
	int totalRank = 0;

	for(r <- ranks){
		rankCount += 1;
		totalRank += r.numericRepresentation;
	}
	
	int result = totalRank / rankCount;
	
	if     (result == 2 ) return plusplus;
	elseif (result == 1 ) return plus; 
	elseif (result == 0 ) return neutral;
	elseif (result == -1) return min;
	elseif (result == -2) return minmin;
}








