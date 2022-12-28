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

	int duplicationPercent = calculateDuplication(application);
	
	int volume = calculateSIGVolume(application);
	
	// this variable will be used to compute both the analysis for UnitSize and Cyclomatic Complexity
	lrel[Declaration method, int size] allFunctionsAndSizes = getUnitsAndSize(application);
	map[str,real] unitSize = computeSIGUnitSizeRank(allFunctionsAndSizes);
	
	getCyclomaticComplexity(allFunctionsAndSizes);

  str report = "";
	
	report += "lines of code: <volume>" + "\n";
	report += "number of units: <size(allFunctionsAndSizes)>" + "\n";
	report += "unit size: \n";
	report += "  * simple: <unitSize["simple"]>%\n";
	report += "  * moderate: <unitSize["moderate"]>%\n";
	report += "  * high: <unitSize["high"]>%\n";
	report += "  * very high: <unitSize["very high"]>%\n";
	report += "unit complexity: \n";
	report += "  * simple: <0>%\n";
	report += "  * moderate: <0>%\n";
	report += "  * high: <0>%\n";
	report += "  * very high: <0>%\n";
	report += "duplication: <duplicationPercent>%\n\n";
	
	report += "volume score: <getSIGVolumeRank(volume)>" + "\n";
	report += "unit size score: <getSIGUnitSizeRank(unitSize)>\n";
	report += "unit complexity score: \n";
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

void getCyclomaticComplexity(allFunctionsAndSizes){
	getComplexity(allFunctionsAndSizes);
	return;
}