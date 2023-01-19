module Visualisation::tree_visual

import IO;
import String;
import SIG::SigModel;
import lang::java::m3::AST;
import vis::Render;
import vis::Figure;
import List;
import Map;
import Type;

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
			return [box(text(t.uri),fillColor("Orange"))];
		}
		
		case dir(_,_,_): {
		
			list[list[Figure]] temp = [];
				
			for (entry <- t.entries)
			{	
				figs += box(text(entry),fillColor("Red"));				
				for (c <- t.entries[entry])
				{
					temp += [createVisualisation([], c)];
				}
				figs += grid(temp);		
			}
			return figs;
		}
	}
}

public void visualize(loc application){

	hierarchy = dir((), 1, 1);
	
	lrel[Declaration method, int size, int complexity] functions_with_size_and_complexity = getCyclomaticComplexity(getUnitsAndSize(application));
	
	for(x <- functions_with_size_and_complexity){
		split_path = split("/", split("project://", x.method.src.uri)[1]);
		updateFT(split_path, fp(x.method.name, x.size, x.complexity));
	}
	
	HierarchyComplexityVisualisation = createVisualisation([],hierarchy);
	
	render(grid([HierarchyComplexityVisualisation]));
}