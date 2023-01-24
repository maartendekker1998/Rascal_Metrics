module Visualisation::ComplexityVisual

import IO;
import String;
import SIG::SigModel;
import lang::java::m3::AST;
import vis::Render;
import vis::Figure;
import List;
import Map;
import Type;

// Super cool stuff that will not be used becuase of depressing rascal limitations

data FileTree 
          = fp(str uri, int size, int complexity)
		  | dir(map[str uri, list[FileTree] childs] entries, int size, int complexity)
		  ;
		  
FileTree hierarchy = dir((), 0, 0);

public map[str, list[FileTree]] updateFT(map[str uri, list[FileTree] childs] state, str current_path, list[str] path, FileTree actual_file){

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

public void updateFT(list[str] path, FileTree actual_file){

	if (size(path) > 1){
		list[str] remaining_path = tail(path);
		str current_path = head(path);
		hierarchy.entries[head(path)]?[] += [];
		hierarchy.entries += updateFT(hierarchy.entries, current_path, remaining_path, actual_file);
	}
	else{
		hierarchy.entries[head(path)]?[] += [actual_file];
		return;
	}
}

public list[Figure] createVisualisation(list[Figure] figs, FileTree t){

	switch(t){
		
		case fp(_,_,_): {
			return [box( text(t.uri), fillColor(getComplexityColor(t.complexity)) )];	
		}
		
		case dir(_,_,_): {
		
			list[Figure] temp = [];
				
			for (entry <- t.entries)
			{												
				for (c <- t.entries[entry]){
					temp += createVisualisation([], c);
				}
				
				figs += treemap([
							box( 
								vcat(
									[text(entry), treemap(temp)]
									,shrink(0.95)
								),
								fillColor("grey")
							) 
						]);
				
			}
			return figs;
		}
	}
}

public FileTree compute_sizes(FileTree t){
			
	int size = 0;
	
	visit(t){
		
		case \fp(_,int s,int c): {
			size += s;
		}
		
		case \dir(map[str uri, list[FileTree] childs] entries,_,_): {
		
			map[str uri, list[FileTree] childs] tmp_entries = ();
			
			for (entry <- entries){
				
				list[FileTree] tmp_childs = [];
															
				for (c <- entries[entry]){
					c = compute_sizes(c);
					tmp_childs += c;
				}
				
				tmp_entries[entry] = tmp_childs;				
			}
			
			t.entries = tmp_entries;
		}
	}
	
	t.size = size;
	return t;
}

// actual relevant stuff

int SIG_MAX_COMPLEXITY_LOW       = 10;
int SIG_MAX_COMPLEXITY_MODERATE  = 20;
int SIG_MAX_COMPLEXITY_HIGH      = 50;

public str getComplexityColor(int cc){



	if      (cc <= SIG_MAX_COMPLEXITY_LOW)      { return "Green";       }
	else if (cc <= SIG_MAX_COMPLEXITY_MODERATE) { return "Yellow";  }	
	else if (cc <= SIG_MAX_COMPLEXITY_HIGH)     { return "Orange";	   }
	else                                        { return "Red"; }
}

public Figure createComplexityFigure(lrel[Declaration method, int size, int complexity] functions_with_size_and_complexity ){

	list[Figure] temp = [];
	int ts = 0;
	
	for(fp <- functions_with_size_and_complexity){
		temp += [box(text("<fp.complexity>"), fillColor(getComplexityColor(fp.complexity)), area(5*fp.size))];
		ts += fp.size;
	}
	
	return treemap(temp, area(5*ts), fillColor("Grey"));	
}

public void visualize(loc application){

	//hierarchy = dir((), 0, 0);
	//
	//for(x <- functions_with_size_and_complexity){
	//	split_path = split("/", split("project://", x.method.src.uri)[1]);
	//	updateFT(split_path, fp(x.method.name, x.size, x.complexity));
	//}
	//
	//hierarchy = compute_sizes(hierarchy);
	//HierarchyComplexityVisualisation = createVisualisation([], hierarchy);
	
	lrel[Declaration method, int size, int complexity] functions_with_size_and_complexity = getCyclomaticComplexity(getUnitsAndSize(application));
		
	kutplaatje = maakKutPlaatje(functions_with_size_and_complexity);
	render(kutplaatje);
}