module Visualisation::Dashboard

import IO;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import Visualisation::ComplexityVisual;
import lang::java::m3::AST;
import Set;
import List;
import Relation;
import Metrics::Duplication;

map[str,Figure] pages = ();
str currentPage;
list[Figure] metricsHeader;
private DuplicationData duplicationData;

public void renderDashboard(DuplicationData duplication, lrel[Declaration, int, int] complexity)
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
	Figure unitComplexityPage = createUnitComplexity(complexity);
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
	list[Dup] sortedDuplicates = sort([<s,d,c> | <s,d,c> <- duplicates]);
	map[rel[str,str],rel[int,int,str]] code = ();
	for (x <- sortedDuplicates)
	{
		if ({<x.src.file,x.dest.file>} notin(code)) code+=({<x.src.file,x.dest.file>}:{});
		rel[int,int,str] linesWithCode = code[{<x.src.file,x.dest.file>}];
		code[{<x.src.file,x.dest.file>}] = linesWithCode+=<x.src.line,x.dest.line,x.code>;
	}
	createCodeView(code);
	Figure src = box(text("<totalCodeSize>"),size(50), fillColor("green"),renderPopup(file));
	list[Figure] destinations = [];
	for (destFile <- destFiles)
	{
		destinations+=box(text("<size(codeLinesPerDestFile[destFile])>"),size(50),fillColor("red"),renderPopup(destFile),detailedBoxClick("<file>-<destFile>"));
	}
	Figure duplicationTree = box(tree(src,destinations, gap(20)), valign(0.5),fillColor("darkgray"));
	Figure detailHeader = box(text(title,valign(0.5)),fillColor("gray"),vshrink(0.1));
	Figure detailBody = grid([[detailHeader],[duplicationTree]]);
	return box(detailBody,shadow(true));
}

private void createCodeView(map[rel[str,str],rel[int,int,str]] code)
{
	for (destFile <- code)
	{
		list[list[Figure]] table = [];
		str boxText = "<getFirstFrom(destFile)[0]> -\> <getFirstFrom(destFile)[1]>\n\n";
		for (i <- sort([<s,d,c> | <s,d,c> <- code[destFile]]))
		{
			table+=
	    	[[
	    		box(hresizable(false),hsize(10),lineColor("white")),
		        box(text("<i[0]> -\> <i[1]>",top(),halign(0.2)),hresizable(false),hsize(75),vresizable(false),vsize(25),lineColor("white")),
		        box(text("<i[2]>",top(),left()),vresizable(false),vsize(25),lineColor("white"))
	        ]];
		}
		Figure body = vcat([box(text(boxText),vsize(25),vresizable(false),top()),grid(table,gap(0),vresizable(false),top())]);
		Figure tableGrid = grid([metricsHeader, [body]],onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage(getFirstFrom(destFile)[0]);return true;}));
		pages+=("sub-<getFirstFrom(destFile)[0]>-<getFirstFrom(destFile)[1]>":tableGrid);
	}
}

private void handleDetailedBoxClick(str destFile) = switchPage("sub-<destFile>");

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
		graph+=box(src, duplicationBoxClick(file));
		graphWithoutPopup+=box(srcWithoutPopup, duplicationBoxClick(file));
	}
	for (detailPage <- detailPages)
	{
		pages+=(detailPage:overlay([grid([metricsHeader, [treemap(graphWithoutPopup)]]), detailPages[detailPage]]));
	}
	return grid([metricsHeader, [treemap(graph)]]);
}

private FProperty duplicationBoxClick(str file) = onMouseDown(bool(int b,map[KeyModifier,bool]m){spawnDetails(file);return true;});

private FProperty detailedBoxClick(str destFile)= onMouseDown(bool(int b,map[KeyModifier,bool]m){handleDetailedBoxClick(destFile);return true;});

private void spawnDetails(str file) = switchPage(file);

private Figure createUnitSize()
{
	l = [];
	for (x <- [0..500])
	{
		l+=box();
	}
	return grid([metricsHeader, [treemap(l)]]);
}

private Figure createUnitComplexity(complexity)
{
	return grid([metricsHeader, [createComplexityFigure(complexity)]]);
}

private Figure createLinesOfCode()
{
	linesOfCode = ellipse(text("Lines of code"),fillColor("LightBLue"));
	return grid([metricsHeader,[linesOfCode]]);
}

private FProperty renderPopup(str textData) = mouseOver(box(text(textData),fillColor("lightyellow"),grow(1.2),resizable(false)));