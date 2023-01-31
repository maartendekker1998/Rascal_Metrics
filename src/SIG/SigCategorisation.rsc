module SIG::SigCategorisation

import SIG::SigConstants;
import DataTypes::DuplicationDetails;
import lang::java::m3::AST;
import util::Math;
import Helpers::Math;

@doc
{
	Gets the complexity risks
}
public str getSIGComplexityRisk(int cc){

	if      (cc <= SIG_MAX_COMPLEXITY_LOW)       return SIG_SIMPLE;
	else if (cc <= SIG_MAX_COMPLEXITY_MODERATE)  return SIG_MODERATE;
	else if (cc <= SIG_MAX_COMPLEXITY_HIGH)      return SIG_HIGH;
	else                                         return SIG_VERY_HIGH;
}

@doc
{
	Creates SIG unit complexity risk categories.
}
public map[str key, real percentage] getSIGUnitComplexityRiskCategories(lrel[Declaration method, int size, int complexity] allFunctionsWithSizeAndComplexity){

	map[str key, real percentage] risks = ();
	int totalVolume = 0;
	
	risks += (SIG_SIMPLE    : 0.0);
	risks += (SIG_MODERATE  : 0.0);
	risks += (SIG_HIGH      : 0.0);
	risks += (SIG_VERY_HIGH : 0.0);

	for (<method,size,complexity> <- allFunctionsWithSizeAndComplexity){
		totalVolume += size;
		str key = getSIGComplexityRisk(complexity);
		risks[key] += toReal(size);
	}
	
	risks += (SIG_SIMPLE    : roundTwoDigits ( risks[SIG_SIMPLE]    / totalVolume*100));
	risks += (SIG_MODERATE  : roundTwoDigits ( risks[SIG_MODERATE]  / totalVolume*100));
	risks += (SIG_HIGH      : roundTwoDigits ( risks[SIG_HIGH]      / totalVolume*100));
	risks += (SIG_VERY_HIGH : roundTwoDigits ( risks[SIG_VERY_HIGH] / totalVolume*100));
	
	return risks;
}

@doc
{
	Gets the unit size risks
}
public str getSIGUnitSizeRisk(int size){

	if      (size < SIG_MAX_SIZE_LOW)       return SIG_SIMPLE;
	else if (size < SIG_MAX_SIZE_MODERATE)  return SIG_MODERATE;
	else if (size < SIG_MAX_SIZE_HIGH)      return SIG_HIGH;
	else                                    return SIG_VERY_HIGH;
}

@doc
{
	Creates SIG unit size risk categories
}
public map[str,real] getSIGUnitSizeRiskCategories(lrel[Declaration method, int size] allFunctionsAndSizes)
{
	map[str,real] metric = ();
	int totalVolume = 0;
	
	metric+=(SIG_SIMPLE    : 0.0);
	metric+=(SIG_MODERATE  : 0.0);
	metric+=(SIG_HIGH      : 0.0);
	metric+=(SIG_VERY_HIGH : 0.0);
	
	for (<method,size> <- allFunctionsAndSizes)
	{
	    totalVolume += size;
		str key = getSIGUnitSizeRisk(size);
		metric[key]+=toReal(size);
	}
	
	metric+=(SIG_SIMPLE    : roundTwoDigits(metric[SIG_SIMPLE]    / totalVolume*100));
	metric+=(SIG_MODERATE  : roundTwoDigits(metric[SIG_MODERATE]  / totalVolume*100));
	metric+=(SIG_HIGH      : roundTwoDigits(metric[SIG_HIGH]      / totalVolume*100));
	metric+=(SIG_VERY_HIGH : roundTwoDigits(metric[SIG_VERY_HIGH] / totalVolume*100));
	
	return metric;
}