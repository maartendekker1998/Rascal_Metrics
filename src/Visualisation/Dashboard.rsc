module Visualisation::Dashboard

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
str currentPage;
public list[Figure] metricsHeader;

public void renderDashboard(DuplicationData duplication, lrel[Declaration, int, int] complexity)
{
	currentPage = "dashboard";
	Color headerColor = rgb(0x2E,0x34,0x40);//Nord 0
	Color headerText = rgb(0xD8,0xDE,0xE9);//Nord 4
   	list[Figure] dashboardHeader =
   	[
   		box(text("Visualisation: Bart Janssen & Maarten Dekker",fontColor(headerText)),fillColor(headerColor),lineColor(headerColor),vshrink(0.1),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("dashboard");return true;}))
	];
	metricsHeader =
   	[
   		box(text("Back to dashboard",halign(0.02),fontColor(headerText)),fillColor(headerColor),lineColor(headerColor),vshrink(0.1),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("dashboard");return true;}))
	];
	//list[Figure] metricRowTop =
	//[
	//	box(text("Unit complexity"),fillColor("Gold"),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("unit complexity");return true;}))
	//];
 //   list[Figure] metricRowBottom =
 //   [
 //   	box(text("Duplication <duplication.percent>%"),fillColor("Red"),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("duplication");return true;}))
	//];
   
   	Figure dashboardPage = createDashboard(dashboardHeader);
	Figure duplicationPage = createDuplication(duplication);
	Figure unitComplexityPage = createUnitComplexity(complexity);

   	pages+=("dashboard":dashboardPage,"duplication":duplicationPage,"unit complexity":unitComplexityPage);
   	  	
   	render(computeFigure(Figure()
   	{
   		return pages[currentPage];
	}));
}
private Figure createDashboard(list[Figure] dashboardHeader)
{
	Color headerColor = rgb(0x2E,0x34,0x40);//Nord 0
	Color contentTextColor = rgb(0xD8,0xDE,0xE9);//Nord 4
	Color bodyColor = rgb(0x3B,0x42,0x52);//Nord 1
	Color tile = rgb(0x43,0x4C,0x5E);//Nord 2
	
	Figure unitComplexity = box(fillColor(tile),shadow(true),shrink(0.8));
	Figure unitSize = box(fillColor(tile),shadow(true),shrink(0.8));
	Figure lineOfCode = box(fillColor(tile),shadow(true),shrink(0.7));
	Figure duplication = box(fillColor(tile),shadow(true),shrink(0.7));
	Figure unitTests = box(fillColor(tile),shadow(true),shrink(0.7));
	Figure metricScores = box(fillColor(tile),shadow(true),shrink(0.8));
	Figure totalScore = box(fillColor(tile),shadow(true),shrink(0.8));
	
	Figure row1 = grid([[box(text("Smallsql",fontSize(40),fontColor(contentTextColor)),lineColor(bodyColor),fillColor(bodyColor),resizable(false))]]);
	Figure column1 = grid([
		[box(unitComplexity,lineColor(bodyColor),fillColor(bodyColor),unitComplexityClick)],
		[box(unitSize,lineColor(bodyColor),fillColor(bodyColor))]]);
	Figure column2 = grid([
		[box(lineOfCode,lineColor(bodyColor),fillColor(bodyColor))],
		[box(duplication,lineColor(bodyColor),fillColor(bodyColor),duplicationClick)],
		[box(unitTests,lineColor(bodyColor),fillColor(bodyColor))]]);
	Figure column3 = grid([
		[box(metricScores,lineColor(bodyColor),fillColor(bodyColor))],
		[box(totalScore,lineColor(bodyColor),fillColor(bodyColor))]]);
	Figure row2 = grid([[column1,column2,column3]]);
	Figure row3 = grid([[box(text("Execution time: 00:00:01",top(),fontColor(contentTextColor)),lineColor(bodyColor),fillColor(bodyColor),vgrow(2.5),resizable(false))]],halign(0.04));
	Figure rows = vcat([row1,row2,row3]);
	
	Figure mainBox = box(rows,lineColor(bodyColor),fillColor(bodyColor));
	list[Figure] dashboard =
	[
		grid([dashboardHeader,[mainBox]])
	];
	return grid([dashboard]);
}

public void switchPage(str pageToSwitchTo)
{
	currentPage = pageToSwitchTo;
}

private Figure createDuplication(DuplicationData duplicationData)
{
	return createDuplicationFigure(duplicationData);
}

private Figure createUnitComplexity(complexity)
{
	return createComplexityFigure(complexity);
}

private FProperty unitComplexityClick = onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("unit complexity");return true;});

private FProperty duplicationClick = onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("duplication");return true;});
