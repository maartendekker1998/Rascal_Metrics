module Visualisation::Dashboard

import IO;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import Visualisation::ComplexityVisual;
import Visualisation::DuplicationVisual;
import lang::java::m3::AST;
import Set;
import List;
import Relation;
import Metrics::Duplication;
import DataTypes::LocationDetails;

public map[str,Figure] pages = ();
private str currentPage;
public list[Figure] metricsHeader;
private map[str, bool] pageIsSelected = ();

private Color headerColor = rgb(0x2E,0x34,0x40);//Nord 0
private Color bodyColor = rgb(0x3B,0x42,0x52);//Nord 1
private Color tileColor = rgb(0x43,0x4C,0x5E);//Nord 2
private Color contentTextColor = rgb(0xD8,0xDE,0xE9);//Nord 4
private Color headerTextColor = rgb(0xD8,0xDE,0xE9);//Nord 4
private Color tileSelectedColor = rgb(0x81,0xA1,0xC1);//Nord 9

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

private Figure createDashboard(DashboardData dashboardData)
{
	DuplicationData duplicaitonData = dashboardData.duplication;
	UnitComplexity unitComplexityData = dashboardData.unitComplexity;
	map[str,real] unitSizeData = dashboardData.unitSize;
	map[str,int] unitTestData = dashboardData.unitTests;
	int linesOfCode = dashboardData.linesOfCode;
	int totalFunctions = dashboardData.totalFunctions;
	
	str headerText = "Visualisation: Bart Janssen & Maarten Dekker";
	
	Figure unitComplexity = 
	computeFigure(Figure()
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
	Figure metricScores = box(fillColor(tileColor),shadow(true),shrink(0.8));
	Figure totalScore = box(fillColor(tileColor),shadow(true),shrink(0.8));
	
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

private Figure createUnitComplexityBox(UnitComplexity unitComplexityData, bool selectable)
{
	int offset = 20;
	Color currentColor = selectable ? tileSelectedColor:tileColor;
	Figure unitComplexitySubBox = box(text("Unit complexity",fontColor(contentTextColor),left()),lineColor(currentColor),fillColor(currentColor),vresizable(false),left());
	Figure unitComplexitySimple = box(text("  Simple:",fontColor(contentTextColor),left()),lineColor(currentColor),fillColor(currentColor),vresizable(false),left());
	Figure unitComplexitySimpleNumber = box(text("<unitComplexityData.complexity["simple"]>%",fontColor(contentTextColor),left()),lineColor(currentColor),fillColor(currentColor),resizable(false),hsize(100),left());
	Figure unitComplexityModerate = box(text("  Moderate:",fontColor(contentTextColor),left()),lineColor(currentColor),fillColor(currentColor),vresizable(false),left());
	Figure unitComplexityModerateNumber = box(text("<unitComplexityData.complexity["moderate"]>%",fontColor(contentTextColor),left()),lineColor(currentColor),fillColor(currentColor),resizable(false),hsize(100),left());
	Figure unitComplexityHigh = box(text("  High:",fontColor(contentTextColor),left()),lineColor(currentColor),fillColor(currentColor),vresizable(false),left());
	Figure unitComplexityHighNumber = box(text("<unitComplexityData.complexity["high"]>%",fontColor(contentTextColor),left()),lineColor(currentColor),fillColor(currentColor),resizable(false),hsize(100),left());
	Figure unitComplexityVeryHigh = box(text("  Very high:",fontColor(contentTextColor),left()),lineColor(currentColor),fillColor(currentColor),vresizable(false),left());
	Figure unitComplexityVeryHighNumber = box(text("<unitComplexityData.complexity["very high"]>%",fontColor(contentTextColor),left()),lineColor(currentColor),fillColor(currentColor),resizable(false),hsize(100),left());

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

private Figure createUnitSizeBox(map[str,real] unitSizeData)
{
	int offset = 20;
	Figure unitSizeSubBox = box(text("Unit size",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure unitSizeSimple = box(text("  Simple:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure unitSizeSimpleNumber = box(text("<unitSizeData["simple"]>%",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());
	Figure unitSizeModerate = box(text("  Moderate:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure unitSizeModerateNumber = box(text("<unitSizeData["moderate"]>%",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());
	Figure unitSizeHigh = box(text("  High:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure unitSizeHighNumber = box(text("<unitSizeData["high"]>%",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());
	Figure unitSizeVeryHigh = box(text("  Very high:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure unitSizeVeryHighNumber = box(text("<unitSizeData["very high"]>%",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());

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

private Figure createLineOfCodeAndFunctionBox(int linesOfCode, int totalFunctions)
{
	int offset = 20;
	Figure lineOfCodeSubBox = box(text("loc:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
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

private Figure createDuplicationBox(DuplicationData duplicaitonData, bool selectable)
{
	int offset = 20;
	Color currentColor = selectable ? tileSelectedColor:tileColor;
	Figure duplicationSubBox = box(text("Duplication",fontColor(contentTextColor),left()),lineColor(currentColor),fillColor(currentColor),vresizable(false),left());
	Figure duplicationNumber = box(text("<duplicaitonData.percent>%",fontColor(contentTextColor),left()),lineColor(currentColor),fillColor(currentColor),resizable(false),hsize(100),left());
	
	return grid([
		[space(size(offset,offset),resizable(false)),space(vsize(offset),resizable(false)),space(vsize(offset),resizable(false))],
		[space(size(offset,offset),resizable(false)),duplicationSubBox,duplicationNumber],
		[space(hsize(offset),resizable(false)),space(),space()]
		]);
}

private Figure createUnitTestBox(map[str,int] unitTestData)
{
	int offset = 20;
	Figure unitTestSubBox = box(text("Unit tests",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure unitTestFunctions = box(text("  Functions:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure unitTestFunctionsNumber = box(text("<unitTestData["tests"]>%",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());
	Figure unitTestAsserts = box(text("  Asserts:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure unitTestAssertsNumber = box(text("<unitTestData["assert"]>%",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());
	Figure unitTestFails = box(text("  Fails:",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),vresizable(false),left());
	Figure unitTestsFailsNumber = box(text("<unitTestData["fail"]>%",fontColor(contentTextColor),left()),lineColor(tileColor),fillColor(tileColor),resizable(false),hsize(100),left());

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

public void switchPage(str pageToSwitchTo)
{
	currentPage = pageToSwitchTo;
}

private Figure createDuplication(DuplicationData duplicationData) = createDuplicationFigure(duplicationData);

private Figure createUnitComplexity(UnitComplexity complexity) = createComplexityFigure(complexity.functionsWithSizeAndComplexity);

private FProperty enterTile(str page) = onMouseEnter(void(){pageIsSelected[page] = true;});

private FProperty leaveTile(str page) = onMouseExit(void(){pageIsSelected[page] = false;});

private FProperty headerClick = onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("dashboard");return true;});

private FProperty unitComplexityClick = onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("unit complexity");return true;});

private FProperty duplicationClick = onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("duplication");return true;});
