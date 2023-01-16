module Vizualisation::Dashboard

import IO;
import vis::Figure;
import vis::Render;
import vis::KeySym;

map[str,Figure] pages = ();
str currentPage;

list[Figure] metricsHeader;

public void renderDashboard()
{
	currentPage = "dashboard";
	Color headerColor = rgb(234,221,202);
   	list[Figure] dashboardHeader =
   	[
   		box(fillColor(headerColor),lineColor(headerColor),vshrink(0.1),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("dashboard");return true;})),
   		box(fillColor(headerColor),lineColor(headerColor),vshrink(0.1),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("dashboard");return true;}))
	];
	metricsHeader =
   	[
   		box(text("Back to dashboard",halign(0.02)),fillColor(headerColor),lineColor(headerColor),vshrink(0.1),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("dashboard");return true;}))
	];
	list[Figure] metricRowTop =
	[
		box(text("Unit size"),fillColor("Silver"),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("unit size");return true;})),
		box(text("Unit complexity"),fillColor("Gold"),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("unit complexity");return true;}))
	];
    list[Figure] metricRowBottom =
    [
    	box(text("Duplication"),fillColor("Red"),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("duplication");return true;})),
     	box(text("Lines of code"),fillColor("Blue"),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("lines of code");return true;}))
   	];
   
   	Figure dashboard = grid([dashboardHeader,metricRowTop,metricRowBottom]);
	Figure duplication = createDuplication();
	Figure unitSize = createUnitSize();
	Figure unitComplexity = createUnitComplexity();
	Figure linesOfCode = createLinesOfCode();

   	pages+=("dashboard":dashboard,"duplication":duplication,"unit size":unitSize,"unit complexity":unitComplexity,"lines of code":linesOfCode);
   	  	
   	render(computeFigure(Figure()
   	{
   		return pages[currentPage];
	}));
}

private void switchPage(str pageToSwitchTo)
{
	currentPage = pageToSwitchTo;
}

private Figure createDuplication()
{
	Figure src = box(text("SourceFile.java", textAngle(270)), fillColor(rgb(225,225,225)), renderPopup("SourceFile.java"));
	list[Figure] destinations = [];
	for (x <- [1..5]) // get from actual duplication data
	{
		destinations+=box(text("File<x>.java", textAngle(270)), fillColor(rgb(125,125,125)), renderPopup("File<x>.java"));
	}
	Figure duplicate = tree(src,destinations,left(),gap(20));
	return grid([metricsHeader,[space()],[duplicate]]);
}

private Figure createUnitSize()
{
	unitSize = box(text("Unit size"),fillColor("LightGreen"));
	return grid([metricsHeader,[unitSize]]);
}

private Figure createUnitComplexity()
{
	unitComplexity = box(text("Unit comlexity"),fillColor("LightGreen"));
	return grid([metricsHeader,[unitComplexity]]);
}

private Figure createLinesOfCode()
{
	linesOfCode = ellipse(text("Lines of code"),fillColor("LightBLue"));
	return grid([metricsHeader,[linesOfCode]]);
}

private FProperty renderPopup(str textData) = mouseOver(box(text(textData),fillColor("lightyellow"),grow(1.2),resizable(false)));








