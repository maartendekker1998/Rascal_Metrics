module Vizualisation::Dashboard

import IO;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import Set;
import List;
import Relation;
import Metrics::Duplication;

map[str,Figure] pages = ();
map[Figure, str] duplicationFigure = ();
str currentPage;

list[Figure] metricsHeader;

private DuplicationData duplicationData;

public void renderDashboard(DuplicationData duplication)
{
	duplicationData = duplication;
	currentPage = "dashboard";
	Color headerColor = rgb(0x2E,0x34,0x40);
   	list[Figure] dashboardHeader =
   	[
   		box(fillColor(headerColor),lineColor(headerColor),vshrink(0.1),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("dashboard");return true;})),
   		box(fillColor(headerColor),lineColor(headerColor),vshrink(0.1),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("dashboard");return true;}))
	];
	metricsHeader =
   	[
   		box(text("Back to dashboard",halign(0.02),fontColor(rgb(0xff,0xff,0xff))),fillColor(headerColor),lineColor(headerColor),vshrink(0.1),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("dashboard");return true;}))
	];
	list[Figure] metricRowTop =
	[
		box(text("Unit size"),fillColor("Silver"),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("unit size");return true;})),
		box(text("Unit complexity"),fillColor("Gold"),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("unit complexity");return true;}))
	];
    list[Figure] metricRowBottom =
    [
    	box(text("Duplication <duplicationData.percent>%"),fillColor("Red"),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("duplication");return true;})),
     	box(text("Lines of code"),fillColor("Blue"),onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("lines of code");return true;}))
   	];
   
   	Figure dashboardPage = grid([dashboardHeader,metricRowTop,metricRowBottom]);
	Figure duplicationPage = createDuplication();
	Figure unitSizePage = createUnitSize();
	Figure unitComplexityPage = createUnitComplexity();
	Figure linesOfCodePage = createLinesOfCode();

   	pages+=("dashboard":dashboardPage,"duplication":duplicationPage,"unit size":unitSizePage,"unit complexity":unitComplexityPage,"lines of code":linesOfCodePage);
   	  	
   	render(computeFigure(Figure()
   	{
   		return pages[currentPage];
	}));
}

private void switchPage(str pageToSwitchTo)
{
	currentPage = pageToSwitchTo;
}

alias Pair = tuple[int line, str file];
alias Dup = tuple[Pair src, Pair dest, str code];

private Figure createDetailOverlayBox(str file)
{
	int totalCodeSize = 0;
	set[str] destFiles = {};
	map[str,list[int]] codeLinesPerDestFile = ();
	Duplication duplication = duplicationData.duplication;
	str title = "<file>";
	list[Dup] duplicates = [];
	for (duplicate <- duplication[file])
	{
		int srcLine = takeFirstFrom(domain(invert(duplicate[0])))[0];
		str srcFile = takeFirstFrom(range(invert(duplicate[0])))[0];
		int destLine = takeFirstFrom(domain(invert(duplicate[1])))[0];
		str destFile = takeFirstFrom(range(invert(duplicate[1])))[0];
		duplicates+=<<srcLine, srcFile>,<destLine, destFile>, duplicate[2]>;
		destFiles+={destFile};
		totalCodeSize+=1;
		if (destFile notin(codeLinesPerDestFile)) codeLinesPerDestFile+=(destFile:[]);
		list[int] codeLines = codeLinesPerDestFile[destFile];
		codeLinesPerDestFile[destFile] = codeLines+=destLine;
	}
	map[str,rel[int,str]] codeM = ();
	list[Dup] sortedDuplicates = sort([<s,d,c> | <s,d,c> <- duplicates]);
	for (x <- sortedDuplicates)
	{
		if (x.dest.file notin(codeM)) codeM+=(x.dest.file:{});
		rel[int,str] l = codeM[x.dest.file];
		codeM[x.dest.file] = l+=<x.dest.line,x.code>;
	}
	for (x <- codeM)
		println(x);
	Figure src = box(text("<totalCodeSize>"),size(50), fillColor("green"),renderPopup(file));
	list[Figure] destinations = [];
	for (destFile <- destFiles)
	{
		destinations+=box(text("<size(codeLinesPerDestFile[destFile])>"),size(50),fillColor("red"),renderPopup(destFile)/*,onMouseDown(bool(int b,map[KeyModifier,bool]m){println(destFile);return true;})*/);
	}
	
	//for (x <- sortedDuplicates)
	//	println("<x.src> <x.dest> <x.code>");
	Figure duplicationTree = box(tree(src,destinations, gap(20)), valign(0.5),fillColor("darkgray"));
	Figure detailHeader = box(text(title,valign(0.5)),fillColor("gray"),vshrink(0.1));
	Figure detailBody = grid([[detailHeader],[duplicationTree]]);
	return box(detailBody,shadow(true));
}

private Figure createDuplication()
{
	Duplication duplication = duplicationData.duplication;
	list[Figure] graph = [];
	list[Figure] graphWithoutPopup = [];
	map[str, Figure] detailPages = ();
	for(file <- duplication)
	{
		Figure details = createDetailOverlayBox(file);
		detailPages+=(file:box(details, shrink(0.5,0.9), onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("duplication");return true;})));

		Figure src = box(text("<size(duplication[file])>"),renderPopup(file));
		Figure srcWithoutPopup = box(text("<size(duplication[file])>"));
		duplicationFigure+=(src:file);
		graph+=box(src, onMouseDown(bool(int b,map[KeyModifier,bool]m){spawnDetails(src);return true;}));
		graphWithoutPopup+=box(srcWithoutPopup, onMouseDown(bool(int b,map[KeyModifier,bool]m){spawnDetails(src);return true;}));
	}
	for (detailPage <- detailPages)
	{
		pages+=(detailPage:overlay([grid([metricsHeader, [treemap(graphWithoutPopup)]]), detailPages[detailPage]]));
	}
	return grid([metricsHeader, [treemap(graph)]]);
}

private void spawnDetails(Figure src)
{
	str file = duplicationFigure[src];
	switchPage(file);
}

private Figure createUnitSize()
{
	l = [];
	for (x <- [0..500])
	{
		l+=box();
	}
	return grid([metricsHeader, [treemap(l)]]);
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








