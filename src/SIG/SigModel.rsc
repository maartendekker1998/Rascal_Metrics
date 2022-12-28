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

	calculateSIGDuplicates(application);
	
	int volume = calculateSIGVolume(application);

	// this variable will be used to compute both the analysis for UnitSize and Cyclomatic Complexity
	lrel[Declaration method, int size] allFunctionsAndSizes = getUnitsAndSize(application);
	
	getCyclomaticComplexity(allFunctionsAndSizes);

	str report = "";
	
	report += "lines of code: <volume>" + "\n";
	report += "number of units: <size(allFunctionsAndSizes)>" + "\n";
	report += "volume score: <getSIGVolumeRank(volume)>" + "\n";

	return report;
}

void calculateSIGDuplicates(loc application){
	int percent = calculateDuplication(application);
	println("duplicate code: <percent>%");
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