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
	
	//calculateSIGVolume(application);

  	int volume = getVolume(application);
	
	// this variable will be used to compute both the analysis for UnitSize and Cyclomatic Complexity
	lrel[Declaration method, int size] allFunctionsAndSizes = getUnitsAndSize(application);
	
	calculateSIGUnitSize(allFunctionsAndSizes);

	str report = "";
	
	report += "lines of code: <volume>" + "\n";
	report += "number of units: <size(allFunctionsAndSizes)>" + "\n";
	report += "volume score: <getSIGVolumeRank(volume)>" + "\n";

	
	return report;
}

// invoke metric calculation for Volume and apply the SIG score
int getVolume(loc application){
	return calculateVolume(application);
}

void calculateSIGDuplicates(loc application){
	int percent = calculateDuplication(application);
	println("duplicate code: <percent>%");
}

void calculateSIGUnitSize(lrel[Declaration method, int size] allFunctionsAndSizes)
{
	map[str,map[str,int]] unitSize = calculateUnitSize(allFunctionsAndSizes);
}

// this function will invoke metric calculation for Volume and apply the SIG score
void calculateSIGVolume(loc application){

	// get the LOC value
	int volume = calculateVolume(application);
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
	return;
}