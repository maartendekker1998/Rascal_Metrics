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
	Color headerColor = rgb(0x2E,0x34,0x40);
   	list[Figure] dashboardHeader =
   	[
   		box(fillColor(headerColor),lineColor(headerColor),vshrink(0.1),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("dashboard");return true;}))
	];
	metricsHeader =
   	[
   		box(text("Back to dashboard",halign(0.02),fontColor(rgb(0xff,0xff,0xff))),fillColor(headerColor),lineColor(headerColor),vshrink(0.1),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("dashboard");return true;}))
	];
	list[Figure] metricRowTop =
	[
		box(text("Unit complexity"),fillColor("Gold"),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("unit complexity");return true;}))
	];
    list[Figure] metricRowBottom =
    [
    	box(text("Duplication <duplication.percent>%"),fillColor("Red"),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("duplication");return true;}))
	];
   
   	Figure dashboardPage = grid([dashboardHeader,metricRowTop,metricRowBottom]);
	Figure duplicationPage = createDuplication(duplication);
	Figure unitComplexityPage = createUnitComplexity(complexity);

   	pages+=("dashboard":dashboardPage,"duplication":duplicationPage,"unit complexity":unitComplexityPage);
   	  	
   	render(computeFigure(Figure()
   	{
   		return pages[currentPage];
	}));
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


