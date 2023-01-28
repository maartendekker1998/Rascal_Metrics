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
import util::Math;
import Relation;
import Metrics::Duplication;
import DataTypes::LocationDetails;
import Visualisation::Dashboard;

private DuplicationData duplicationData;

private alias DuplicationDetail = tuple[Figure body, int totalRelations, bool hasRelationToItself];

private DuplicationDetail createDetailOverlayBox(str file)
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
		str srcFile = takeFirstFrom(range(invert(duplicate[0])))[0];
		int destLine = takeFirstFrom(domain(invert(duplicate[1])))[0];
		str destFile = takeFirstFrom(range(invert(duplicate[1])))[0];
		if (srcFile == destFile) hasRelationToItself = true;
		duplicates+=<<srcLine, srcFile>,<destLine, destFile>, duplicate[2]>;
		destFiles+={destFile};
		totalCodeSize+=1;
		if (destFile notin(codeLinesPerDestFile)) codeLinesPerDestFile+=(destFile:[]);
		list[int] codeLines = codeLinesPerDestFile[destFile];
		codeLinesPerDestFile[destFile] = codeLines+=destLine;
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
	Figure src = box(text("<totalCodeSize>"),size(50), fillColor("green"),renderPopup(file));
	list[Figure] destinations = createDuplicationDestinationBoxes(destFiles, codeLinesPerDestFile, file);
	Figure duplicationTree = box(tree(src,destinations, gap(20)), valign(0.5),fillColor("darkgray"));
	Figure detailHeader = box(text("<file>",valign(0.5)),fillColor("gray"),vshrink(0.1));
	Figure detailBody = grid([[detailHeader],[duplicationTree]]);
	return <box(detailBody,shadow(true)),size(destFiles),hasRelationToItself>;
}

private list[Figure] createDuplicationDestinationBoxes(set[str] destFiles, map[str,list[int]] codeLinesPerDestFile, str file)
{
	list[Figure] destinations = [];
	for (destFile <- destFiles)
	{
		destinations+=box(text("<size(codeLinesPerDestFile[destFile])>"),size(50),fillColor("red"),renderPopup(destFile),detailedBoxClick("<file>-<destFile>"));
	}
	return destinations;
}

private void createCodeView(map[rel[str,str],rel[int,int,str]] code)
{
	str color = "white";
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
				Figure linesText = text("<chunk[0]> -\> <chunk[1]>",top(),halign(0.2));
				Figure codeText = text("<chunk[2]>",top(),left());
				table+=
		    	[[
		    		box(vSize,vresizable(false),hsize(10),hresizable(false),lineColor(color)),
			        box(linesText,vSize,vresizable(false),hsize(75),hresizable(false),lineColor(color)),
			        box(codeText,vSize,vresizable(false),lineColor(color)),
			        box(vSize,vresizable(false),hsize(10),hresizable(false),lineColor(color))
		        ]];
			}
		}
		Figure body = vcat([box(text(boxText),lineColor(color),vsize(25),vresizable(false),top()),grid(table,gap(0),vresizable(false),top())],onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage(getFirstFrom(destFile)[0]);return true;}));
		Figure tableGrid = grid([metricsHeader, [scrollable(body)]]);
		pages+=("sub-<getFirstFrom(destFile)[0]>-<getFirstFrom(destFile)[1]>":tableGrid);
	}
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
		/*Figure relationToItselfBox = hcat([space(),box(fillColor("lightgray")),space(),box(fillColor("lightgray")),
						 space(),box(fillColor("lightgray")),space(),box(fillColor("lightgray")),
						 space(),box(fillColor("lightgray")),space(),box(fillColor("lightgray")),
						 space(),box(fillColor("lightgray")),space(),box(fillColor("lightgray")),
						 space(),box(fillColor("lightgray")),space(),box(fillColor("lightgray")),
						 space(),box(fillColor("lightgray")),space()
						 ]);*/
		//int length = size(toString(size(duplicationData.duplication[file])));
		//int i = (length == 1 ? 3 : (length == 2 ? 8 : (length == 3 ? 20 : 30)));
		//Figure relationToItselfBox = hcat([ellipse(fillColor("purple"),resizable(false),size(i,i),top()),space()]);
		Figure relationToItselfBox = grid([
			[ellipse(fillColor("purple")),space(),space()],
			[space(),space(),space()],
			[space(),space(),space()]]);
		
		detailPages+=(file:box(details.body, shrink(0.5,0.9), onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("duplication");return true;})));
		Figure src = (details.hasRelationToItself) ?
			box(relationToItselfBox,fillColor(getColorByLineAmount(details)), renderPopup(file,size(duplicationData.duplication[file])))
			: box(fillColor(getColorByLineAmount(details)), renderPopup(file,size(duplicationData.duplication[file])));
		Figure srcWithoutPopup = (details.hasRelationToItself) ? 
			box(relationToItselfBox,fillColor(getColorByLineAmount(details)))
			: box(fillColor(getColorByLineAmount(details)));
		graph+=box(src, duplicationBoxClick(file),area(size(duplicationData.duplication[file])));
		graphWithoutPopup+=box(srcWithoutPopup, duplicationBoxClick(file),area(size(duplicationData.duplication[file])));
	}
	for (detailPage <- detailPages) pages+=(detailPage:overlay([grid([metricsHeader, [treemap(graphWithoutPopup)]]), detailPages[detailPage]]));
	return grid([metricsHeader, [treemap(graph)]]);
}

private Color getColorByLineAmount(DuplicationDetail details)
{
	int totalRelations = details.totalRelations;
	bool hasRelationToItself = details.hasRelationToItself;
	if (totalRelations == 1) return rgb(0x00,0xFF,0x00);//Green
	if (totalRelations > 1 && totalRelations <= 3) return rgb(0xFF,0xA5,0x00);//Orange
	return rgb(0xFF,0x00,0x00);//Red
}

private void handleDetailedBoxClick(str destFile) = switchPage("sub-<destFile>");

private void showDuplicationDetails(str file) = switchPage(file);

private FProperty duplicationBoxClick(str file) = onMouseDown(bool(int b,map[KeyModifier,bool]m){showDuplicationDetails(file);return true;});

private FProperty detailedBoxClick(str destFile) = onMouseDown(bool(int b,map[KeyModifier,bool]m){handleDetailedBoxClick(destFile);return true;});

private FProperty renderPopup(str textData,int lines) = mouseOver(box(text("<textData>\n<lines> lines"),fillColor("lightyellow"),grow(1.2),resizable(false)));
private FProperty renderPopup(str textData) = mouseOver(box(text(textData),fillColor("lightyellow"),grow(1.2),resizable(false)));
