module Visualisation::DuplicationVisual

import vis::Figure;
import vis::Render;
import vis::KeySym;
import Visualisation::ComplexityVisual;
import Visualisation::DuplicationVisual;
import lang::java::m3::AST;
import Set;
import List;
import String;
import Relation;
import Metrics::Duplication;
import DataTypes::LocationDetails;
import Visualisation::Dashboard;
import DataTypes::Color;

private alias DuplicationDetail = tuple[Figure body, int totalRelations, bool hasRelationToItself];

private DuplicationData duplicationData;
private Color detailHeaderColor = nord1;
private Color detailBodyColor = nord9;
private Color contentTextColor = nord4;

@doc
{
	This function creates the detail overlay box of a duplication box.
}
private DuplicationDetail createDetailOverlayBox(loc file)
{
	int totalCodeSize = 0;
	set[str] destFiles = {};
	map[str,list[int]] codeLinesPerDestFile = ();
	Duplication duplication = duplicationData.duplication;
	list[DuplicationItem] duplicates = [];
	bool hasRelationToItself = false;
	for (duplicate <- duplication[file])
	{
		int srcLine = takeFirstFrom(domain(invert(duplicate[0])))[0];
		loc srcFile = takeFirstFrom(range(invert(duplicate[0])))[0];
		int destLine = takeFirstFrom(domain(invert(duplicate[1])))[0];
		loc destFile = takeFirstFrom(range(invert(duplicate[1])))[0];
		str src = replaceFirst(srcFile.uri, "<srcFile.scheme>://","");
		str dest = replaceFirst(destFile.uri, "<destFile.scheme>://","");
		if (src == dest) hasRelationToItself = true;
		duplicates+=<<srcLine, srcFile.file>,<destLine, destFile.file>, duplicate[2]>;
		destFiles+={destFile.file};
		totalCodeSize+=1;
		if (destFile.file notin(codeLinesPerDestFile)) codeLinesPerDestFile+=(destFile.file:[]);
		list[int] codeLines = codeLinesPerDestFile[destFile.file];
		codeLinesPerDestFile[destFile.file] = codeLines+=destLine;
	}
	list[DuplicationItem] sortedDuplicates = sort([<s,d,c> | <s,d,c> <- duplicates]);
	map[rel[str,str],rel[int,int,str]] code = ();
	for (x <- sortedDuplicates)
	{
		if ({<x.src.file,x.dest.file>} notin(code)) code+=({<x.src.file,x.dest.file>}:{});
		rel[int,int,str] linesWithCode = code[{<x.src.file,x.dest.file>}];
		code[{<x.src.file,x.dest.file>}] = linesWithCode+=<x.src.line,x.dest.line,x.code>;
	}
	createCodeView(code);
	Figure src = box(text("<totalCodeSize>"),size(50), fillColor(green),renderPopup(file.file));
	list[Figure] destinations = createDuplicationDestinationBoxes(destFiles, codeLinesPerDestFile, file.file);
	Figure duplicationTree = box(tree(src,destinations, gap(20)), valign(0.5),fillColor(detailBodyColor));
	Figure detailHeader = box(text("<file.file>",valign(0.5),fontColor(contentTextColor)),fillColor(detailHeaderColor),vshrink(0.1));
	Figure detailBody = grid([[detailHeader],[duplicationTree]]);
	return <box(detailBody,shadow(true)),size(destFiles),hasRelationToItself>;
}

@doc
{
	This function creates the boxes where a duplication is found to in the detail overlay.
}
private list[Figure] createDuplicationDestinationBoxes(set[str] destFiles, map[str,list[int]] codeLinesPerDestFile, str file)
{
	list[Figure] destinations = [];
	for (destFile <- destFiles)
	{
		destinations+=box(text("<size(codeLinesPerDestFile[destFile])>"),size(50),fillColor(red),renderPopup(destFile),detailedBoxClick("<file>-<destFile>"));
	}
	return destinations;
}

@doc
{
	This function creates the actual code that is found duplicate beloning to the file clicked.
}
private void createCodeView(map[rel[str,str],rel[int,int,str]] code)
{
	Color codeBackground = nord2;
	Color codeColor = nord4;
	for (destFile <- code)
	{
		list[list[Figure]] table = [];
		str boxText = "<getFirstFrom(destFile)[0]> -\> <getFirstFrom(destFile)[1]>\n\n";
		map[tuple[int,int],tuple[int,int,str]] linesCodeMap = (<s,d>:<s,d,c> | <s,d,c> <- sort([<s,d,c> | <s,d,c> <- code[destFile]]));
		lrel[int,int,str] chunks = [];
		set[tuple[int,int]] removed = {};
		for (sortedCode <- sort([<s,d> | <s,d> <- linesCodeMap]))
		{
			if (sortedCode in(removed)) continue;
			int nextLine = 0;
			while (<sortedCode[0]+nextLine,sortedCode[1]+nextLine> in(linesCodeMap))
			{
				tuple[int,int,str] chunk = linesCodeMap[<sortedCode[0]+nextLine,sortedCode[1]+nextLine>];
				removed+=<sortedCode[0]+nextLine,sortedCode[1]+nextLine>;
				nextLine+=1;
				FProperty vSize = vsize((<chunk[0]+1,chunk[1]+1> notin(linesCodeMap)) ? 60 : 25);
				Figure linesText = text("<chunk[0]> -\> <chunk[1]>",top(),halign(0.2),fontColor(codeColor));
				Figure codeText = text("<chunk[2]>",top(),left(),fontColor(codeColor));
				table+=
		    	[[
		    		box(vSize,vresizable(false),hsize(10),hresizable(false),fillColor(codeBackground),lineColor(codeBackground)),
			        box(linesText,vSize,vresizable(false),hsize(75),hresizable(false),fillColor(codeBackground),lineColor(codeBackground)),
			        box(codeText,vSize,vresizable(false),fillColor(codeBackground),lineColor(codeBackground)),
			        box(vSize,vresizable(false),hsize(10),hresizable(false),fillColor(codeBackground),lineColor(codeBackground))
		        ]];
			}
		}
		Figure body = vcat([box(text(boxText,fontColor(codeColor)),fillColor(codeBackground),lineColor(codeBackground),vsize(25),vresizable(false),top()),box(grid(table,gap(0),vresizable(false),top()),fillColor(codeBackground))],onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage(getFirstFrom(destFile)[0]);return true;}));
		Figure tableGrid = grid([metricsHeader, [scrollable(body)]]);
		pages+=("sub-<getFirstFrom(destFile)[0]>-<getFirstFrom(destFile)[1]>":tableGrid);
	}
}

@doc
{
	This function creates the duplication overview page. A small 
	ellipse in the left upper corner can show, meaning the file has
	also duplication to itself.
}
public Figure createDuplicationFigure(DuplicationData duplication)
{
	duplicationData = duplication;
	list[Figure] graph = [];
	list[Figure] graphWithoutPopup = [];
	map[str, Figure] detailPages = ();
	for(file <- duplicationData.duplication)
	{
		DuplicationDetail details = createDetailOverlayBox(file);
		Figure relationToItselfBox = grid([
			[ellipse(fillColor(lightBlue),aspectRatio(1.0),left(),top(),shadow(true),shadowPos(5,5)),space(),space()],
			[space(),space(),space()],
			[space(),space(),space()]]);
		
		detailPages+=(file.file:box(details.body, shrink(0.5,0.9), detailPageClick()));
		Figure src = (details.hasRelationToItself) ?
			box(relationToItselfBox,fillColor(getColorByRelationAmount(details)), renderPopup(file.file,size(duplicationData.duplication[file])))
			: box(fillColor(getColorByRelationAmount(details)), renderPopup(file.file,size(duplicationData.duplication[file])));
		Figure srcWithoutPopup = (details.hasRelationToItself) ? 
			box(relationToItselfBox,fillColor(getColorByRelationAmount(details)))
			: box(fillColor(getColorByRelationAmount(details)));
		graph+=box(src, duplicationBoxClick(file.file),area(size(duplicationData.duplication[file])));
		graphWithoutPopup+=box(srcWithoutPopup, duplicationBoxClick(file.file),area(size(duplicationData.duplication[file])));
	}
	for (detailPage <- detailPages) pages+=(detailPage:overlay([grid([metricsHeader, [treemap(graphWithoutPopup)]]), detailPages[detailPage]]));
	return grid([metricsHeader, [treemap(graph)]]);
}

@doc
{
	This function creates the color of a duplication box in the duplication overview
}
private Color getColorByRelationAmount(DuplicationDetail details)
{
	int totalRelations = details.totalRelations;
	bool hasRelationToItself = details.hasRelationToItself;
	if (totalRelations == 1) return green;
	if (totalRelations > 1 && totalRelations <= 3) return orange;
	return red;
}

@doc
{
	This function handles the click event of a duplicated file box in 
	the detailed overview, it will switch to the code view.
}
private void handleDetailedBoxClick(str destFile) = switchPage("sub-<destFile>");

@doc
{
	This function handles the click event of a duplication box in the 
	overview page, this will switch to its detailed page.
}
private void showDuplicationDetails(str file) = switchPage(file);

@doc
{
	This function handles the click event to return to the dashboard overview.
}
private FProperty detailPageClick() = onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("duplication");return true;});

@doc
{
	This function handles the click event to show the duplication details.
}
private FProperty duplicationBoxClick(str file) = onMouseDown(bool(int b,map[KeyModifier,bool]m){showDuplicationDetails(file);return true;});

@doc
{
	This function handles the click event to show the code view details.
}
private FProperty detailedBoxClick(str destFile) = onMouseDown(bool(int b,map[KeyModifier,bool]m){handleDetailedBoxClick(destFile);return true;});

@doc
{
	This function renders alittle popup showing the filename with the total lines when hovering over a box.
}
private FProperty renderPopup(str textData,int lines) = mouseOver(box(text("<textData>\n<lines> lines"),fillColor(lightYellow),grow(1.2),resizable(false)));

@doc
{
	This function renders alittle popup showing the filename when hovering over a box.
}
private FProperty renderPopup(str textData) = mouseOver(box(text(textData),fillColor(lightYellow),grow(1.2),resizable(false)));
