module Visualisation::ComplexityVisual

import IO;
import String;
import SIG::SigModel;
import lang::java::m3::AST;
import vis::Render;
import vis::KeySym;
import vis::Figure;
import List;
import Map;
import Type;
import Visualisation::Dashboard;

int SIG_MAX_COMPLEXITY_LOW       = 10;
int SIG_MAX_COMPLEXITY_MODERATE  = 20;
int SIG_MAX_COMPLEXITY_HIGH      = 50;

private data FileTree 
          = fp(str uri, int size, int complexity)
		  | dir(map[str uri, list[FileTree] childs] entries, int size, int complexity)
		  ;
		  
private map[str, list[FileTree]] updateFT(map[str uri, list[FileTree] childs] state, str current_path, list[str] path, FileTree actual_file){

	if (size(path) > 0){
				
		map[str uri, list[FileTree] childs] temp = ();
		
		for(entry <- state[current_path]){

			if(head(path) in entry.entries.uri)
			{
				i = indexOf(state[current_path], entry);
				temp = (head(path):entry.entries[head(path)]);
				nested_state = updateFT(temp, head(path), tail(path), actual_file);
				state[current_path][i].entries += nested_state;
			}
		}
		
		if (isEmpty(temp)){
			state[current_path] += [dir((head(path):[]), 0, 0)];
			state = updateFT(state, current_path, path, actual_file);
		}
		
		return state;
	}
	else{
		state[current_path]?[] += [actual_file];
		return state;
	}
}

private str getComplexityColor(int cc){
	if      (cc <= SIG_MAX_COMPLEXITY_LOW)      { return "Green";       }
	else if (cc <= SIG_MAX_COMPLEXITY_MODERATE) { return "Yellow";  }	
	else if (cc <= SIG_MAX_COMPLEXITY_HIGH)     { return "Orange";	   }
	else                                        { return "Red"; }
}

public Figure createComplexityFigure(lrel[Declaration method, int size, int complexity] functions_with_size_and_complexity ){

	list[Figure] temp = [];
	int ts = 0;
	map[str, Figure] detailPages = ();
	for(fp <- functions_with_size_and_complexity){
		ts += fp.size;
		str hash = md5Hash(fp);
		Figure detailHeader = box(text("<fp.method.name>()",valign(0.5)),fillColor("gray"),vshrink(0.1));
		Figure detailBody = box(text("Location: <fp.method.src.uri>\nComplexity: <fp.complexity>\nSize: <fp.size>"),fillColor("darkgray"));
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

private FProperty unitBoxClick(str hash) = onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage(hash);return true;});

private FProperty detailedViewClick() = onMouseDown(bool(int b,map[KeyModifier,bool]m){switchPage("unit complexity");return true;});
