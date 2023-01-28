module SIG::SigRanking

import String;
import util::Math;
import lang::java::m3::AST;

int SIG_JAVA_KLOC_PLUS_PLUS = 66;
int SIG_JAVA_KLOC_PLUS = 246;
int SIG_JAVA_KLOC_O = 665;
int SIG_JAVA_KLOC_MIN = 1310;

str SIG_LOW_COMPLEXITY_KEY       = "simple";
str SIG_MODERATE_COMPLEXITY_KEY  = "moderate";
str SIG_HIGH_COMPLEXITY_KEY      = "high";
str SIG_VERY_HIGH_COMPLEXITY_KEY = "very high";

int SIG_MAX_COMPLEXITY_LOW       = 10;
int SIG_MAX_COMPLEXITY_MODERATE  = 20;
int SIG_MAX_COMPLEXITY_HIGH      = 50;

alias Rank = tuple[str stringRepresentation, int numericRepresentation];

Rank plusplus = <"++",  2>;
Rank plus     = <"+" ,  1>;
Rank neutral  = <"o" ,  0>;
Rank min      = <"-" , -1>;
Rank minmin   = <"--", -2>;

//	The percentage of lines of code residing in units with more than 15 lines of code should not exceed 44.0%.
//	percentage in units with more than 30 lines of code should not exceed 20.1%.
//	The percentage in units with more than 60 lines should not exceed 6.3%.

public Rank getSIGVolumeRank(int linesOfCode){
	
	num kloc = toReal(linesOfCode)/1000;

	if (kloc < SIG_JAVA_KLOC_PLUS_PLUS){
		return plusplus;
	}
	else if(kloc >= SIG_JAVA_KLOC_PLUS_PLUS && kloc < SIG_JAVA_KLOC_PLUS){
		return plus;
	}
	else if (kloc >= SIG_JAVA_KLOC_PLUS && kloc < SIG_JAVA_KLOC_O){
		return neutral;
	}
	else if (kloc >= SIG_JAVA_KLOC_O && kloc < SIG_JAVA_KLOC_MIN){
		return min;
	}
	else{
		return minmin;
	}
}

public str getSIGComplexityRisk(int cc){

	if      (cc <= SIG_MAX_COMPLEXITY_LOW)      { return SIG_LOW_COMPLEXITY_KEY;       }
	else if (cc <= SIG_MAX_COMPLEXITY_MODERATE) { return SIG_MODERATE_COMPLEXITY_KEY;  }	
	else if (cc <= SIG_MAX_COMPLEXITY_HIGH)     { return SIG_HIGH_COMPLEXITY_KEY;	   }
	else                                        { return SIG_VERY_HIGH_COMPLEXITY_KEY; }
}

public map[str key, real percentage] computeSIGUnitComplexityRiskCategories(lrel[Declaration method, int size, int complexity] allFunctionsWithSizeAndComplexity){

	map[str key, real percentage] risks = ();
	int totalVolume = 0;
	risks+=(SIG_LOW_COMPLEXITY_KEY:0.0);
	risks+=(SIG_MODERATE_COMPLEXITY_KEY:0.0);
	risks+=(SIG_HIGH_COMPLEXITY_KEY:0.0);
	risks+=(SIG_VERY_HIGH_COMPLEXITY_KEY:0.0);

	for (<method,size,complexity> <- allFunctionsWithSizeAndComplexity){
		totalVolume += size;
		str key = getSIGComplexityRisk(complexity);
		risks[key] += toReal(size);
	}
	
	risks+=(SIG_LOW_COMPLEXITY_KEY:       roundTwoDigits ( risks[SIG_LOW_COMPLEXITY_KEY]       / totalVolume*100));
	risks+=(SIG_MODERATE_COMPLEXITY_KEY:  roundTwoDigits ( risks[SIG_MODERATE_COMPLEXITY_KEY]  / totalVolume*100));
	risks+=(SIG_HIGH_COMPLEXITY_KEY:      roundTwoDigits ( risks[SIG_HIGH_COMPLEXITY_KEY]      / totalVolume*100));
	risks+=(SIG_VERY_HIGH_COMPLEXITY_KEY: roundTwoDigits ( risks[SIG_VERY_HIGH_COMPLEXITY_KEY] / totalVolume*100));
	
	return risks;
}

public Rank getSIGDuplicationRank(int percentage){

	if    (percentage < 3)	return plusplus;
	elseif(percentage < 5)  return plus;
	elseif(percentage < 10) return neutral;
	elseif(percentage < 20) return min;
	else            		return minmin;	
}

public map[str,real] computeSIGUnitSizeRank(lrel[Declaration method, int size] allFunctionsAndSizes)
{
	map[str,real] metric = ();
	int totalVolume = 0;
	metric+=("simple":0.0);
	metric+=("moderate":0.0);
	metric+=("high":0.0);
	metric+=("very high":0.0);
	for (<method,size> <- allFunctionsAndSizes)
	{
	    totalVolume += size;
		str key = (size<15)?"simple":(size<30)?"moderate":(size<60)?"high":"very high";
		metric[key]+=toReal(size);
	}
	metric+=("simple":roundTwoDigits(metric["simple"]/totalVolume*100));
	metric+=("moderate":roundTwoDigits(metric["moderate"]/totalVolume*100));
	metric+=("high":roundTwoDigits(metric["high"]/totalVolume*100));
	metric+=("very high":roundTwoDigits(metric["very high"]/totalVolume*100));
	return metric;
}

public Rank getSIGUnitSizeRank(map[str,real] unitSize)
{
	if      (unitSize["moderate"]<=25 && unitSize["high"] == 0  && unitSize["very high"] == 0) return plusplus;
	else if (unitSize["moderate"]<=30 && unitSize["high"] <= 5  && unitSize["very high"] == 0) return plus;
	else if (unitSize["moderate"]<=40 && unitSize["high"] <= 10 && unitSize["very high"] == 0) return neutral;
	else if (unitSize["moderate"]<=50 && unitSize["high"] <= 15 && unitSize["very high"] <= 5) return min;
	else                                                                                       return minmin;
}

private real roundTwoDigits(real n)
{
	if (endsWith(toString(n),".")) return n;
	return toReal(substring(toString(n),0,findFirst(toString(n),".")+2));
}


// ISO 9126 categorisation helper function

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
	else   println("We got a problem");
}








