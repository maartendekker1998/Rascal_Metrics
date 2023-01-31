module DataTypes::DashboardData

import DataTypes::UnitComplexity;
import DataTypes::DuplicationDetails;
import DataTypes::Score;

public alias DashboardData = tuple
[
	str name,
	DuplicationData duplication, 
	UnitComplexity unitComplexity,
	map[str,real] unitSize,
	int linesOfCode,
	int totalFunctions,
	map[str,int] unitTests,
	MetricScore metricScore,
	OveralScore overalScore,
	str executionTime
];