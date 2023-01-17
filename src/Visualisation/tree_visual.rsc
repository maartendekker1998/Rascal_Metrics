module Visualisation::tree_visual

import IO;
import SIG::SigModel;
import lang::java::m3::AST;
import vis::Render;
import vis::Figure;
import List;
import Map;

import Type;


data FileTree 
          = file(str uri, int size, int complexity)
		  | dir(map[str uri, list[FileTree] childs] entries, int size, int complexity)
		  ;
		  
FileTree h = dir((), 1, 1);


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
			state[current_path] += [dir((head(path):[]), 1, 1)];
			state = updateFT(state, current_path, path, actual_file);
			println("jajoh");
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
		h.entries[head(path)]?[] += [];
		h.entries += updateFT(h.entries, current_path, remaining_path, actual_file);
	}
	else{
		h.entries[head(path)]?[] += [actual_file];
		return;
	}
}
		

public void visualize(loc application){

	h = dir((), 1, 1);
	
	updateFT(["src", "test", "lib"], file("file3.java", 3, 11));
	updateFT(["src", "test"], file("file4.java", 4, 2));
	
	println(h.entries);
	
	lrel[Declaration method, int size, int complexity] functions_with_size_and_complexity = getCyclomaticComplexity(getUnitsAndSize(application));
	
	// maybe reduce to just a list of files first
	// populate some kind of datatype with the folder structure (maybe use the directory names as keys in lookup tables)?
	
	for(x <- functions_with_size_and_complexity){
	
		//println(x.method.src.uri);
	
		if(isDirectory(x.method.src.top.parent))
		{
			y = x.method.src.top.parent.uri;

		}
		
	}
	
	row2 = [ box(ellipse(fillColor("Yellow")),fillColor("Green")),
         box(fillColor("Purple")),
         box(text("blablabalbalba"),fillColor("Orange"))
       ];
       
    row3 = [box(fillColor("Blue"))];
    
       
	row1 = [ 
	
		 box(text("bla\njada"),fillColor("Red")),
		 grid([row2, row3])       
       ];
       

	//render(grid([row1]));
}