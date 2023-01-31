module Visualisation::MetricVisualisation::ComplexityVisual

import IO;
import SIG::SigModel;
import lang::java::m3::AST;
import vis::Render;
import vis::KeySym;
import vis::Figure;
import Visualisation::Dashboard;
import Visualisation::Theme::Color;

private int SIG_MAX_COMPLEXITY_LOW       = 10;
private int SIG_MAX_COMPLEXITY_MODERATE  = 20;
private int SIG_MAX_COMPLEXITY_HIGH      = 50;

private Color detailHeaderColor = nord1;
private Color detailBodyColor = nord9;
private Color contentTextColor = nord4;

@doc
{
	This gets the color of a box based on its complexity
}
private Color getComplexityColor(int cc){
	if      (cc <= SIG_MAX_COMPLEXITY_LOW)      return green;
	else if (cc <= SIG_MAX_COMPLEXITY_MODERATE) return yellow;
	else if (cc <= SIG_MAX_COMPLEXITY_HIGH)     return orange;
	else                                        return red;
}

@doc
{
	This function creates the ovewview of the unit complexity page
}
public Figure createComplexityFigure(lrel[Declaration method, int size, int complexity] functionsWithSizeAndComplexity){

	list[Figure] temp = [];
	int ts = 0;
	map[str, Figure] detailPages = ();
	for(fp <- functionsWithSizeAndComplexity){
		ts += fp.size;
		str hash = md5Hash(fp);
		Figure detailHeader = box(text("<fp.method.name>()",valign(0.5),fontColor(contentTextColor)),fillColor(detailHeaderColor),vshrink(0.1));
		Figure detailBody = box(text("Location: <fp.method.src.uri>\nComplexity: <fp.complexity>\nSize: <fp.size>"),fillColor(detailBodyColor));
		Figure overBox = grid([[detailHeader],[detailBody]]);
		detailPages+=("complex-<hash>":box(overBox, shrink(0.8,0.5),detailedViewClick(),shadow(true)));
		temp+=box(unitBoxClick("complex-<hash>"),fillColor(getComplexityColor(fp.complexity)),area(5*fp.size));
	}
	for (detailPage <- detailPages)
	{
		pages+=(detailPage:overlay([grid([metricsHeader, [treemap(temp)]]), detailPages[detailPage]]));
	}
	return grid([metricsHeader, [treemap(temp)]]);
}

@doc
{
	This function handles the click event of a single unit box.
}
private FProperty unitBoxClick(str hash) = onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage(hash);return true;});

@doc
{
	This function handles the click event for returning to the unit complexity overview from a detail view.
}
private FProperty detailedViewClick() = onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("unit complexity");return true;});
