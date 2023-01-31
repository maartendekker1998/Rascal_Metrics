module SIG::SigReport

import List;
import SIG::SigRanking;
import SIG::SigCategorisation;
import SIG::SigConstants;
import Metrics::Volume;
import Metrics::UnitComplexity;
import Metrics::Duplication;
import Metrics::UnitSize;
import Metrics::UnitTestCoverage;
import lang::java::m3::AST;
import DataTypes::LocationDetails;
import DataTypes::DuplicationDetails;
import DataTypes::UnitComplexity;
import DataTypes::Rank;
import DataTypes::Metric;
import DataTypes::Score;
import DataTypes::DashboardData;
import String;
import util::Benchmark;
import util::Math;

private str formatDate(int x) = size(toString(x)) == 1 ? "0<x>" : "<x>";

@doc
{
	This function will trigger all the metrics and compose the report,
	it also collects the dashboard data for the visualisation.
}
public Metric getSigReport(loc application){

	int startTime = realTime();
	
	// First we calculate all the metrics
	
	// Duplication
	DuplicationData duplication = getDuplicationPercentage(calculateDuplication(application));
	
	// Volume
	int volume = calculateVolume(application);
	
	// UnitSize
	lrel[Declaration method, int size] allFunctionsAndSizes = calculateUnitsAndSize(application);
	map[str,real] unitSize = getSIGUnitSizeRiskCategories(allFunctionsAndSizes);
	
	// Unit tests
	map[str,int] assertions = calculateUnitTests(application, allFunctionsAndSizes);	

	// Complexity
	lrel[Declaration, int, int] functionsWithSizeAndComplexity = getComplexity(allFunctionsAndSizes);
	map[str,real] unitComplexity = getSIGUnitComplexityRiskCategories(functionsWithSizeAndComplexity);
	UnitComplexity complexity = <functionsWithSizeAndComplexity,unitComplexity>;
	
	// Print the results of the metrics

	str report = "<application.authority>\n";
	
	report += "----\n\n";
	report += "lines of code:   <volume>\n";
	report += "number of units: <size(allFunctionsAndSizes)>\n\n";
	
	report += "unit size: \n";
	
	report += "  * simple    : <unitSize[SIG_SIMPLE   ]>%\n";
	report += "  * moderate  : <unitSize[SIG_MODERATE ]>%\n";
	report += "  * high      : <unitSize[SIG_HIGH     ]>%\n";
	report += "  * very high : <unitSize[SIG_VERY_HIGH]>%\n\n";
	
	report += "unit complexity: \n";

	report += "  * simple    : <unitComplexity[SIG_SIMPLE   ]>%\n";
	report += "  * moderate  : <unitComplexity[SIG_MODERATE ]>%\n";
	report += "  * high      : <unitComplexity[SIG_HIGH     ]>%\n";
	report += "  * very high : <unitComplexity[SIG_VERY_HIGH]>%\n\n";
	
	report += "unit testing:\n";
	
	report += "  * asserts   : <assertions["assert"]>\n";
	report += "  * fails     : <assertions["fail"]>\n";
	report += "  * unittests : <assertions["tests"]>\n\n";
	
	report += "duplication: <duplication.percent>%\n\n";
	
	//Get the ranks
	Rank volumeRank         = getSIGVolumeRank(volume);
	Rank unitSizeRank       = getSIGUnitSizeRank(unitSize);
	Rank unitComplexityRank = getSIGUnitComplexityRank(unitComplexity);
	Rank duplicationRank    = getSIGDuplicationRank(duplication.percent);
	
	//Print the ranks
	report += "volume score          : <volumeRank.stringRepresentation>\n";
	report += "unit size score       : <unitSizeRank.stringRepresentation>\n";
	report += "unit complexity score : <unitComplexityRank.stringRepresentation>\n";
	report += "duplication score     : <duplicationRank.stringRepresentation>\n\n";
	
	// Compute the averaged ranks per category
	
	list[Rank] analyzabilityArguments = [volumeRank, duplicationRank, unitSizeRank];
	list[Rank] changeabilityArguments = [unitComplexityRank, duplicationRank];
	list[Rank] testabilityArguments   = [unitComplexityRank, unitSizeRank];
	
	Rank analyzebilityRank = calculateWeigedAverage(analyzabilityArguments);
	Rank changeabilityRank = calculateWeigedAverage(changeabilityArguments);
	Rank testabilityRank   = calculateWeigedAverage(testabilityArguments);
	
	// Print the averaged ranks
	
	report += "analysability score   : <analyzebilityRank.stringRepresentation>\n";
	report += "changeability score   : <changeabilityRank.stringRepresentation>\n";
	report += "testability score     : <testabilityRank.stringRepresentation>\n\n";
	
	// Compute and print the final rank
	
	list[Rank] overallArguments = [analyzebilityRank, changeabilityRank, testabilityRank];
	Rank overallRank = calculateWeigedAverage(overallArguments);
	report += "overall maintainability score: <overallRank.stringRepresentation>";
	
	int endTime = ((realTime()-startTime)/1000);
	int hours = endTime / 3600;
	int minutes = (endTime % 3600) /60;
	int seconds = endTime % 60;
	str executionTime = "Execution time: <formatDate(hours)>:<formatDate(minutes)>:<formatDate(seconds)>";
	
	//Prepare the data neccesary for the visualisations
	MetricScore metricScore = <volumeRank,unitSizeRank,unitComplexityRank,duplicationRank>;
	OveralScore overalScore = <analyzebilityRank,changeabilityRank,testabilityRank,overallRank>;	
	DashboardData dashboardData = <application.authority,duplication,complexity,unitSize,volume,size(allFunctionsAndSizes),assertions,metricScore,overalScore,executionTime>;

	return <report,dashboardData>;
}