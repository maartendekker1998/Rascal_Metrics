module Metrics::UnitSize

import IO;
import List;
import String;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;

public map[str,map[str,int]] calculateUnitSize(loc application)
{
	M3 model = createM3FromEclipseProject(application);
	return calculateLines(model);
}

private map[str,map[str,int]] calculateLines(M3 model)
{
	map[str,map[str,int]] linesPerMethod = ();
	for (<d,c> <- model.documentation)
	{
		if (d.scheme=="java+method" || d.scheme=="java+constructor")
		{
			//println("<d.parent.file> <substring(d.file, 0, findFirst(d.file, "("))>");
			//println("<c.begin.line - (c.end.line+1)>");
			map[str,int] methodLines = ();
			methodLines+=(substring(d.file, 0, findFirst(d.file, "(")):c.begin.line - (c.end.line+1));
			linesPerMethod+=(d.path:methodLines);
		}
	}


	
	for (method <- methods(model))
	{
		list[str] lines = readFileLines(method);
		map[str,int] methodLines = ((method.path notin(linesPerMethod)) ? () : linesPerMethod[method.path]);
		methodLines+=(substring(method.file, 0, findFirst(method.file, "(")): size(lines));
		linesPerMethod+=(method.path:methodLines);
	}
	return linesPerMethod;
}