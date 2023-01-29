module SIG::SigModel

import IO;
import List;
import SIG::SigRanking;
import Metrics::Volume;
import Metrics::UnitComplexity;
import Metrics::Duplication;
import Metrics::UnitSize;
import Metrics::UnitTestCoverage;
import lang::java::m3::AST;
import DataTypes::LocationDetails;
import String;
import util::Benchmark;
import util::Math;

private str formatDate(int x) = size(toString(x)) == 1 ? "0<x>" : "<x>";

// This function will trigger all the metrics and compose the report
public Metric getSigMetric(loc application){

	int startTime = realTime();
	// Duplication
	DuplicationData duplication = getDuplicationPercent(calculateDuplication(application));
	
	// Volume
	int volume = calculateVolume(application);
	
	// UnitSize
	lrel[Declaration method, int size] allFunctionsAndSizes = getUnitsAndSize(application);
	map[str,real] unitSize = computeSIGUnitSizeRank(allFunctionsAndSizes);
	
	// Unit tests
	map[str,int] assertions = calculateUnitTestCoverage(application, allFunctionsAndSizes);	

	// Complexity
	lrel[Declaration, int, int] functionsWithSizeAndComplexity = getCyclomaticComplexity(allFunctionsAndSizes);
	map[str,real] unitComplexity = computeSIGUnitComplexityRiskCategories(functionsWithSizeAndComplexity);
	UnitComplexity complexity = <functionsWithSizeAndComplexity,unitComplexity>;

	str report = "<application.authority>\n";
	report += "----\n\n";
	report += "lines of code:   <volume>\n";
	report += "number of units: <size(allFunctionsAndSizes)>\n\n";
	
	report += "unit size: \n";
	report += "  * simple:    <unitSize["simple"   ]>%\n";
	report += "  * moderate:  <unitSize["moderate" ]>%\n";
	report += "  * high:      <unitSize["high"     ]>%\n";
	report += "  * very high: <unitSize["very high"]>%\n\n";
	
	report += "unit complexity: \n";

	report += "  * simple:    <unitComplexity["simple"   ]>%\n";
	report += "  * moderate:  <unitComplexity["moderate" ]>%\n";
	report += "  * high:      <unitComplexity["high"     ]>%\n";
	report += "  * very high: <unitComplexity["very high"]>%\n\n";
	report += "unit testing:\n";
	report += "  * asserts:   <assertions["assert"]>\n";
	report += "  * fails:     <assertions["fail"]>\n";
	report += "  * unittests: <assertions["tests"]>\n\n";
	report += "duplication: <duplication.percent>%\n\n";
	
	Rank volumeRank         = getSIGVolumeRank(volume);
	Rank unitSizeRank       = getSIGUnitSizeRank(unitSize);
	Rank unitComplexityRank = getSIGUnitSizeRank(unitComplexity);
	Rank duplicationRank    = getSIGDuplicationRank(duplication.percent);
	MetricScore metricScore = <volumeRank,unitSizeRank,unitComplexityRank,duplicationRank>;
	
	report += "volume score: <volumeRank.stringRepresentation>" + "\n";
	report += "unit size score: <unitSizeRank.stringRepresentation>\n";
	report += "unit complexity score: <unitComplexityRank.stringRepresentation>\n";
	report += "duplication score: <duplicationRank.stringRepresentation>\n\n";
	
	list[Rank] analyzabilityArguments = [volumeRank, duplicationRank, unitSizeRank];
	list[Rank] changeabilityArguments = [unitComplexityRank, duplicationRank];
	list[Rank] testabilityArguments   = [unitComplexityRank, unitSizeRank];
	
	Rank analyzebilityRank = calculateWeigedAverage(analyzabilityArguments);
	Rank changeabilityRank = calculateWeigedAverage(changeabilityArguments);
	Rank testabilityRank   = calculateWeigedAverage(testabilityArguments);
	
	report += "analysability score: <analyzebilityRank.stringRepresentation>\n";
	report += "changability score: <changeabilityRank.stringRepresentation>\n";
	report += "testability score: <testabilityRank.stringRepresentation>\n\n";
	
	list[Rank] overallArguments = [analyzebilityRank, changeabilityRank, testabilityRank];
	Rank overallRank = calculateWeigedAverage(overallArguments);
	OveralScore overalScore = <analyzebilityRank,changeabilityRank,testabilityRank,overallRank>;
	
	report += "overall maintainability score: <overallRank.stringRepresentation>";
	
	int endTime = ((realTime()-startTime)/1000);
	int hours = endTime / 3600;
	int minutes = (endTime % 3600) /60;
	int seconds = endTime % 60;
	str executionTime = "Execution time: <formatDate(hours)>:<formatDate(minutes)>:<formatDate(seconds)>";
	DashboardData dashboardData = <application.authority,duplication,complexity,unitSize,volume,size(allFunctionsAndSizes),assertions,metricScore,overalScore,executionTime>;

	return <report,dashboardData>;
}

lrel[Declaration method, int size] getUnitsAndSize(loc application){
	return calculateUnitsAndSize(application);
}

lrel[Declaration, int, int] getCyclomaticComplexity(allFunctionsAndSizes){
	return getComplexity(allFunctionsAndSizes);
}