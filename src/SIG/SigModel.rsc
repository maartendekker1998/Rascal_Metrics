module SIG::SigModel

import IO;
import List;
import SIG::SigRanking;
import Metrics::Volume;
import Metrics::UnitComplexity;
import Metrics::Duplication;
import Metrics::UnitSize;
import lang::java::m3::AST;

// This function will trigger all the metrics and compose the report
public str getSigReport(loc application){

	// Duplication
	int duplicationPercent = calculateDuplication(application);
	
	// Volume
	int volume = calculateSIGVolume(application);
	
	// UnitSize
	lrel[Declaration method, int size] allFunctionsAndSizes = getUnitsAndSize(application);
	map[str,real] unitSize = computeSIGUnitSizeRank(allFunctionsAndSizes);
	
	// Complexity
	map[str,real] unitComplexity = computeSIGUnitComplexityRiskCategories(getCyclomaticComplexity(allFunctionsAndSizes));

  	str report = "";
	
	report += "lines of code: <volume>" + "\n";
	
	report += "number of units: <size(allFunctionsAndSizes)>" + "\n";
	
	report += "unit size: \n";
	report += "  * simple: <unitSize["simple"]>%\n";
	report += "  * moderate: <unitSize["moderate"]>%\n";
	report += "  * high: <unitSize["high"]>%\n";
	report += "  * very high: <unitSize["very high"]>%\n";
	
	report += "unit complexity: \n";
	report += "  * simple: <unitComplexity["simple"]>%\n";
	report += "  * moderate: <unitComplexity["moderate"]>%\n";
	report += "  * high: <unitComplexity["high"]>%\n";
	report += "  * very high: <unitComplexity["very high"]>%\n";
	
	report += "duplication: <duplicationPercent>%\n\n";
	
	report += "volume score: <getSIGVolumeRank(volume)>" + "\n";
	report += "unit size score: <getSIGUnitSizeRank(unitSize)>\n";
	report += "unit complexity score: <getSIGUnitSizeRank(unitComplexity)>\n";
	report += "duplication score: <computeSIGDuplicationRank(duplicationPercent)>\n\n";
	
	report += "analysability score: \n";
	report += "changability score: \n";
	report += "testability score: \n\n";
	
	report += "overall maintainability score: \n";

	return report;
}

// this function will invoke metric calculation for Volume and apply the SIG score
int calculateSIGVolume(loc application){
	// get the LOC value
	return calculateVolume(application);
}
	
// calculate SIG score
// compute the SIG rank for the Volume Metric
str getSIGVolumeRank(int volume){
	return computeSIGVolumeRank(volume);
}

lrel[Declaration method, int size] getUnitsAndSize(loc application){
	return calculateUnitsAndSize(application);
}

lrel[Declaration, int, int] getCyclomaticComplexity(allFunctionsAndSizes){
	return getComplexity(allFunctionsAndSizes);
	
}