module Visualisation::Dashboard

import vis::Figure;
import vis::Render;
import vis::KeySym;
import Visualisation::ComplexityVisual;
import Visualisation::DuplicationVisual;
import DataTypes::LocationDetails;
import DataTypes::Color;

public map[str,Figure] pages = ();
public list[Figure] metricsHeader;
private str currentPage;
private map[str, bool] pageIsSelected = ();

private Color headerColor = nord0;
private Color bodyColor = nord1;
private Color tileColor = nord2;
private Color contentTextColor = nord4;
private Color headerTextColor = nord4;
private Color tileSelectedColor = nord9;

@doc
{
	This function creates the pages and is respoisible for rendering the dashboard.
}
public void renderDashboard(DashboardData dashboardData)
{
	currentPage = "dashboard";
	pageIsSelected+=("duplication":false,"unit complexity":false);
	metricsHeader =
   	[
   		box(text("Back to dashboard",halign(0.02),fontColor(headerTextColor)),fillColor(headerColor),lineColor(headerColor),vshrink(0.1),headerClick)
	];
   
   	Figure dashboardPage = createDashboard(dashboardData);
	Figure duplicationPage = createDuplication(dashboardData.duplication);
	Figure unitComplexityPage = createUnitComplexity(dashboardData.unitComplexity);

   	pages+=("dashboard":dashboardPage,"duplication":duplicationPage,"unit complexity":unitComplexityPage);
   	  	
   	render(computeFigure(Figure()
   	{
   		return pages[currentPage];
	}));
}

@doc
{
	This function creates the visual of the dashboard itself.
}
private Figure createDashboard(DashboardData dashboardData)
{
	DuplicationData duplicaitonData = dashboardData.duplication;
	UnitComplexity unitComplexityData = dashboardData.unitComplexity;
	map[str,real] unitSizeData = dashboardData.unitSize;
	map[str,int] unitTestData = dashboardData.unitTests;
	int linesOfCode = dashboardData.linesOfCode;
	int totalFunctions = dashboardData.totalFunctions;
	MetricScore metricScore = dashboardData.metricScore;
	OveralScore overalScore = dashboardData.overalScore;
	
	str headerText = "Visualisation: Bart Janssen & Maarten Dekker";
	
	Figure unitComplexity = computeFigure(Figure()
   	{
   		return box(createUnitComplexityBox(unitComplexityData,pageIsSelected["unit complexity"]),fillColor(pageIsSelected["unit complexity"] ? tileSelectedColor:tileColor),shadow(true),shrink(0.8),enterTile("unit complexity"), leaveTile("unit complexity"));
	});
	Figure duplication = computeFigure(Figure()
   	{
   		return box(createDuplicationBox(duplicaitonData,pageIsSelected["duplication"]),fillColor(pageIsSelected["duplication"] ? tileSelectedColor:tileColor),shadow(true),shrink(0.7),enterTile("duplication"), leaveTile("duplication"));
	});
	Figure unitSize = box(createUnitSizeBox(unitSizeData),fillColor(tileColor),shadow(true),shrink(0.8));
	Figure lineOfCodeAndFunctions = box(createLineOfCodeAndFunctionBox(linesOfCode, totalFunctions),fillColor(tileColor),shadow(true),shrink(0.7));
	Figure unitTests = box(createUnitTestBox(unitTestData),fillColor(tileColor),shadow(true),shrink(0.7));
	Figure metricScores = box(createMetricBox(metricScore),fillColor(tileColor),shadow(true),shrink(0.8));
	Figure totalScore = box(createOverallBox(overalScore),fillColor(tileColor),shadow(true),shrink(0.8));
	
	Figure row1 = grid([[box(text(dashboardData.name,fontSize(40),fontColor(contentTextColor)),lineColor(bodyColor),fillColor(bodyColor),resizable(false))]]);
		Figure column1 = grid([
			[box(unitComplexity,lineColor(bodyColor),fillColor(bodyColor),unitComplexityClick)],
			[box(unitSize,lineColor(bodyColor),fillColor(bodyColor))]]);
		Figure column2 = grid([
			[box(lineOfCodeAndFunctions,lineColor(bodyColor),fillColor(bodyColor))],
			[box(duplication,lineColor(bodyColor),fillColor(bodyColor),duplicationClick)],
			[box(unitTests,lineColor(bodyColor),fillColor(bodyColor))]]);
		Figure column3 = grid([
			[box(metricScores,lineColor(bodyColor),fillColor(bodyColor))],
			[box(totalScore,lineColor(bodyColor),fillColor(bodyColor))]]);
	Figure row2 = grid([[column1,column2,column3]]);
	Figure row3 = grid([[box(text(dashboardData.executionTime,top(),fontColor(contentTextColor)),lineColor(bodyColor),fillColor(bodyColor),vgrow(2.5),resizable(false))]],halign(0.04));
	Figure rows = vcat([row1,row2,row3]);
	
	Figure dashboardHeader = box(text(headerText,fontColor(headerTextColor)),fillColor(headerColor),lineColor(headerColor),vshrink(0.1));
	Figure mainBox = box(rows,lineColor(bodyColor),fillColor(bodyColor));
	Figure dashboard = grid([[dashboardHeader],[mainBox]]);
	return grid([[dashboard]]);
}

@doc
{
	This function creates the metric box with its data calculated from the metrics.
}
private Figure createMetricBox(MetricScore metricScore)
{
	int offset = 20;
	Figure metricSubBox = box(text("Score",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure metricVolume = box(text("  Volume:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure metricVolumeNumber = box(text("<metricScore.volumeRank.stringRepresentation>",fontBold(true),fontSize(getFontSizeFromScore(metricScore.volumeRank)),fontColor(getColorBySIGScore(metricScore.volumeRank)),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());
	Figure metricUnitSize = box(text("  Unit size:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure metricUnitSizeNumber = box(text("<metricScore.unitSizeRank.stringRepresentation>",fontBold(true),fontSize(getFontSizeFromScore(metricScore.unitSizeRank)),fontColor(getColorBySIGScore(metricScore.unitSizeRank)),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());
	Figure metricComplexity = box(text("  Complexity:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure metricComplexityNumber = box(text("<metricScore.unitComplexityRank.stringRepresentation>",fontBold(true),fontSize(getFontSizeFromScore(metricScore.unitComplexityRank)),fontColor(getColorBySIGScore(metricScore.unitComplexityRank)),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());
	Figure metricDuplication = box(text("  Duplication:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure metricDuplicationNumber = box(text("<metricScore.duplicationRank.stringRepresentation>",fontBold(true),fontSize(getFontSizeFromScore(metricScore.duplicationRank)),fontColor(getColorBySIGScore(metricScore.duplicationRank)),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());

	return grid([
		[space(size(offset,offset),resizable(false)),space(vsize(offset),resizable(false)),space(vsize(offset),resizable(false))],
		[space(size(offset,offset),resizable(false)),metricSubBox,space(size(offset,offset),resizable(false))],
		[space(size(offset,offset),resizable(false)),metricVolume,metricVolumeNumber],
		[space(size(offset,offset),resizable(false)),metricUnitSize,metricUnitSizeNumber],
		[space(size(offset,offset),resizable(false)),metricComplexity,metricComplexityNumber],
		[space(size(offset,offset),resizable(false)),metricDuplication,metricDuplicationNumber],
		[space(hsize(offset),resizable(false)),space(),space()]
		]);
}

@doc
{
	This function creates the overal score box with its data calculated from the metrics.
}
private Figure createOverallBox(OveralScore overalScore)
{
	int offset = 20;
	Figure metricSubBox = box(text("Score",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure metricAnalyze = box(text("  Analysability:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure metricAnalyzeNumber = box(text("<overalScore.analyzebilityRank.stringRepresentation>",fontBold(true),fontSize(getFontSizeFromScore(overalScore.analyzebilityRank)),fontColor(getColorBySIGScore(overalScore.analyzebilityRank)),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());
	Figure metricChangability = box(text("  Changeability:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure metricChangabilityNumber = box(text("<overalScore.changeabilityRank.stringRepresentation>",fontBold(true),fontSize(getFontSizeFromScore(overalScore.changeabilityRank)),fontColor(getColorBySIGScore(overalScore.changeabilityRank)),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());
	Figure metricTestability = box(text("  Testability:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure metricTestabilityNumber = box(text("<overalScore.testabilityRank.stringRepresentation>",fontBold(true),fontSize(getFontSizeFromScore(overalScore.testabilityRank)),fontColor(getColorBySIGScore(overalScore.testabilityRank)),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());
	Figure metricOverall = box(text("  Overall:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure metricOverallNumber = box(text("<overalScore.overallRank.stringRepresentation>",fontBold(true),fontSize(getFontSizeFromScore(overalScore.overallRank)),fontColor(getColorBySIGScore(overalScore.overallRank)),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());

	return grid([
		[space(size(offset,offset),resizable(false)),space(vsize(offset),resizable(false)),space(vsize(offset),resizable(false))],
		[space(size(offset,offset),resizable(false)),metricSubBox,space(size(offset,offset),resizable(false))],
		[space(size(offset,offset),resizable(false)),metricAnalyze,metricAnalyzeNumber],
		[space(size(offset,offset),resizable(false)),metricChangability,metricChangabilityNumber],
		[space(size(offset,offset),resizable(false)),metricTestability,metricTestabilityNumber],
		[space(hsize(offset),resizable(false)),space(),space()],
		[space(size(offset,offset),resizable(false)),metricOverall,metricOverallNumber],
		[space(hsize(offset),resizable(false)),space(),space()]
		]);
}

@doc
{
	This function creates the unit complexity box with its data calculated from the metrics.
	This box is clickable to show more details about unit complexity
}
private Figure createUnitComplexityBox(UnitComplexity unitComplexityData, bool selectable)
{
	int offset = 20;
	Color currentColor = selectable ? tileSelectedColor:tileColor;
	Figure unitComplexitySubBox = box(text("Unit complexity",fontColor(contentTextColor),left()),lineColor(currentColor),fillColor(currentColor),vresizable(false),left());
	Figure unitComplexitySimple = box(text("  Simple:",fontColor(contentTextColor),left()),lineColor(currentColor),fillColor(currentColor),vresizable(false),left());
	Figure unitComplexitySimpleNumber = box(text("<unitComplexityData.complexity["simple"]>%",fontColor(getColorByUnitComplexityPercent(unitComplexityData.complexity,"simple")),left()),lineColor(currentColor),fillColor(currentColor),resizable(false),hsize(100),left());
	Figure unitComplexityModerate = box(text("  Moderate:",fontColor(contentTextColor),left()),lineColor(currentColor),fillColor(currentColor),vresizable(false),left());
	Figure unitComplexityModerateNumber = box(text("<unitComplexityData.complexity["moderate"]>%",fontColor(getColorByUnitComplexityPercent(unitComplexityData.complexity,"moderate")),left()),lineColor(currentColor),fillColor(currentColor),resizable(false),hsize(100),left());
	Figure unitComplexityHigh = box(text("  High:",fontColor(contentTextColor),left()),lineColor(currentColor),fillColor(currentColor),vresizable(false),left());
	Figure unitComplexityHighNumber = box(text("<unitComplexityData.complexity["high"]>%",fontColor(getColorByUnitComplexityPercent(unitComplexityData.complexity,"high")),left()),lineColor(currentColor),fillColor(currentColor),resizable(false),hsize(100),left());
	Figure unitComplexityVeryHigh = box(text("  Very high:",fontColor(contentTextColor),left()),lineColor(currentColor),fillColor(currentColor),vresizable(false),left());
	Figure unitComplexityVeryHighNumber = box(text("<unitComplexityData.complexity["very high"]>%",fontColor(getColorByUnitComplexityPercent(unitComplexityData.complexity,"very high")),left()),lineColor(currentColor),fillColor(currentColor),resizable(false),hsize(100),left());

	return grid([
		[space(size(offset,offset),resizable(false)),space(vsize(offset),resizable(false)),space(vsize(offset),resizable(false))],
		[space(size(offset,offset),resizable(false)),unitComplexitySubBox,space(size(offset,offset),resizable(false))],
		[space(size(offset,offset),resizable(false)),unitComplexitySimple,unitComplexitySimpleNumber],
		[space(size(offset,offset),resizable(false)),unitComplexityModerate,unitComplexityModerateNumber],
		[space(size(offset,offset),resizable(false)),unitComplexityHigh,unitComplexityHighNumber],
		[space(size(offset,offset),resizable(false)),unitComplexityVeryHigh,unitComplexityVeryHighNumber],
		[space(hsize(offset),resizable(false)),space(),space()]
		]);
}

@doc
{
	This function creates the unit size box with its data calculated from the metrics.
}
private Figure createUnitSizeBox(map[str,real] unitSizeData)
{
	int offset = 20;
	Figure unitSizeSubBox = box(text("Unit size",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure unitSizeSimple = box(text("  Simple:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure unitSizeSimpleNumber = box(text("<unitSizeData["simple"]>%",fontColor(getColorByUnitSizePercent(unitSizeData,"simple")),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());
	Figure unitSizeModerate = box(text("  Moderate:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure unitSizeModerateNumber = box(text("<unitSizeData["moderate"]>%",fontColor(getColorByUnitSizePercent(unitSizeData,"moderate")),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());
	Figure unitSizeHigh = box(text("  High:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure unitSizeHighNumber = box(text("<unitSizeData["high"]>%",fontColor(getColorByUnitSizePercent(unitSizeData,"high")),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());
	Figure unitSizeVeryHigh = box(text("  Very high:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure unitSizeVeryHighNumber = box(text("<unitSizeData["very high"]>%",fontColor(getColorByUnitSizePercent(unitSizeData,"very high")),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());

	return grid([
		[space(size(offset,offset),resizable(false)),space(vsize(offset),resizable(false)),space(vsize(offset),resizable(false))],
		[space(size(offset,offset),resizable(false)),unitSizeSubBox,space(size(offset,offset),resizable(false))],
		[space(size(offset,offset),resizable(false)),unitSizeSimple,unitSizeSimpleNumber],
		[space(size(offset,offset),resizable(false)),unitSizeModerate,unitSizeModerateNumber],
		[space(size(offset,offset),resizable(false)),unitSizeHigh,unitSizeHighNumber],
		[space(size(offset,offset),resizable(false)),unitSizeVeryHigh,unitSizeVeryHighNumber],
		[space(hsize(offset),resizable(false)),space(),space()]
		]);
}

@doc
{
	This function creates the lines of code box with its data calculated from the metrics.
}
private Figure createLineOfCodeAndFunctionBox(int linesOfCode, int totalFunctions)
{
	int offset = 20;
	Figure lineOfCodeSubBox = box(text("Loc:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure lineOfCodeNumber = box(text("<linesOfCode>",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());
	Figure functions = box(text("Functions:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure functionsNumber = box(text("<totalFunctions>",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());
	
	return grid([
		[space(size(offset,offset),resizable(false)),space(vsize(offset),resizable(false)),space(vsize(offset),resizable(false))],
		[space(size(offset,offset),resizable(false)),lineOfCodeSubBox,lineOfCodeNumber],
		[space(size(offset,offset),resizable(false)),functions,functionsNumber],
		[space(hsize(offset),resizable(false)),space(),space()]
		]);
}

@doc
{
	This function creates the duplication box with its data calculated from the metrics.
	This box is clickable to show more details about duplication
}
private Figure createDuplicationBox(DuplicationData duplicaitonData, bool selectable)
{
	int offset = 20;
	Color currentColor = selectable ? tileSelectedColor:tileColor;
	Figure duplicationSubBox = box(text("Duplication",fontColor(contentTextColor),left()),lineColor(currentColor),fillColor(currentColor),vresizable(false),left());
	Figure duplicationNumber = box(text("<duplicaitonData.percent>%",fontColor(getColorByDuplicationPercent(duplicaitonData.percent)),left()),lineColor(currentColor),fillColor(currentColor),resizable(false),hsize(100),left());
	
	return grid([
		[space(size(offset,offset),resizable(false)),space(vsize(offset),resizable(false)),space(vsize(offset),resizable(false))],
		[space(size(offset,offset),resizable(false)),duplicationSubBox,duplicationNumber],
		[space(hsize(offset),resizable(false)),space(),space()]
		]);
}

@doc
{
	This function creates the unit test box with its data calculated from the metrics.
}
private Figure createUnitTestBox(map[str,int] unitTestData)
{
	int offset = 20;
	Figure unitTestSubBox = box(text("Unit tests",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure unitTestFunctions = box(text("  Functions:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure unitTestFunctionsNumber = box(text("<unitTestData["tests"]>",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());
	Figure unitTestAsserts = box(text("  Asserts:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure unitTestAssertsNumber = box(text("<unitTestData["assert"]>",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());
	Figure unitTestFails = box(text("  Fails:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure unitTestsFailsNumber = box(text("<unitTestData["fail"]>",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());

	Figure unitTestsGrid = grid([
		[space(size(offset,offset),resizable(false)),space(vsize(offset),resizable(false)),space(vsize(offset),resizable(false))],
		[space(size(offset,offset),resizable(false)),unitTestSubBox,space(size(offset,offset),resizable(false))],
		[space(size(offset,offset),resizable(false)),unitTestFunctions,unitTestFunctionsNumber],
		[space(size(offset,offset),resizable(false)),unitTestAsserts,unitTestAssertsNumber],
		[space(size(offset,offset),resizable(false)),unitTestFails,unitTestsFailsNumber],
		[space(hsize(offset),resizable(false)),space(),space()]
		]);
	return unitTestsGrid;
}

@doc
{
	This function returns a color to show on the dashboard
	based on its completity level. The color scheme is mostly
	adopted from the SIG metric thresholds. Since the thresholds
	does not always fit exacly with a color scheme, the other
	colors are derived from them.
}
private Color getColorByUnitComplexityPercent(map[str,real] complexity, str level)
{
	if (level == "simple") return complexity[level] <= 60 ? red :
								 (complexity[level] <= 75 ? orange : 
								 (complexity[level] <= 90 ? yellow : green));
	if (level == "moderate") return complexity[level] <= 20 ? green :
								   (complexity[level] <= 40 ? yellow : 
								   (complexity[level] <= 60 ? orange : red));
	if (level == "high") return complexity[level] <= 1 ? green :
							   (complexity[level] <= 7 ? yellow : 
							   (complexity[level] <= 20 ? orange : red));
	if (level == "very high") return complexity[level] <= 0 ? green :
									(complexity[level] <= 0 ? yellow : 
									(complexity[level] <= 1 ? orange : red));
	return red;
}

@doc
{
	This function returns a color to show on the dashboard
	based on its unit size level. The color scheme is mostly
	adopted from the SIG metric thresholds. Since the thresholds
	does not always fit exacly with a color scheme, the other
	colors are derived from them.
}
private Color getColorByUnitSizePercent(map[str,real] unitSizeData, str level)
{
	if (level == "simple") return unitSizeData[level] <= 44 ? red :
								 (unitSizeData[level] <= 62 ? orange : 
								 (unitSizeData[level] <= 80 ? yellow : green));
	if (level == "moderate") return unitSizeData[level] <= 20 ? green :
								   (unitSizeData[level] <= 32 ? yellow : 
								   (unitSizeData[level] <= 44 ? orange : red));
	if (level == "high") return unitSizeData[level] <= 6 ? green :
							   (unitSizeData[level] <= 12 ? yellow : 
							   (unitSizeData[level] <= 20 ? orange : red));
	if (level == "very high") return unitSizeData[level] <= 3 ? green :
									(unitSizeData[level] <= 5 ? yellow : 
									(unitSizeData[level] <= 6 ? orange : red));
	return red;
}

@doc
{
	This function returns a font size based on the score,
	Rascal seems to make a difference of '+' and '-' while 
	using the same font size.
}
private int getFontSizeFromScore(Rank SIGScore)
{
	int score = SIGScore.numericRepresentation;
	return score < 0 ? 16 : 11;
}

@doc
{
	This function returns a color to show on the dashboard
	based on its score.
}
private Color getColorBySIGScore(Rank SIGScore)
{
	int score = SIGScore.numericRepresentation;
	return score == 2 ? green : (score == 1 ? green : (score == 0 ? orange : red));
}

@doc
{
	This function returns a color to show on the dashboard
	based on its duplication level.
}
private Color getColorByDuplicationPercent(real percent)
{
	return (percent <= 3 ? green :
		   (percent <= 5 ? yellow :
		   (percent <= 10 ? orange : 
		   (percent <= 20 ? red : purple))));
}

@doc
{
	This function sets the current page to a new page triggering
	the dashboard to switch pages.
}
public void switchPage(str pageToSwitchTo)
{
	currentPage = pageToSwitchTo;
}

@doc
{
	This function calls the duplication visual to create the page for duplication.
}
private Figure createDuplication(DuplicationData duplicationData) = createDuplicationFigure(duplicationData);

@doc
{
	This function calls the unit complexity visual to create the page for unit complexity.
}
private Figure createUnitComplexity(UnitComplexity complexity) = createComplexityFigure(complexity.functionsWithSizeAndComplexity);

@doc
{
	This function allows a pane to highlight when the mouse enteres the box.
}
private FProperty enterTile(str page) = onMouseEnter(void(){pageIsSelected[page] = true;});

@doc
{
	This function allows a pane to revert highlight when the mouse enteres the box.
}
private FProperty leaveTile(str page) = onMouseExit(void(){pageIsSelected[page] = false;});

@doc
{
	This function handles the click event of the header.
}
private FProperty headerClick = onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("dashboard");return true;});

@doc
{
	This function handles the click event of the unit complexity box.
}
private FProperty unitComplexityClick = onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("unit complexity");return true;});

@doc
{
	This function handles the click event of the duplication box.
}
private FProperty duplicationClick = onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("duplication");return true;});
