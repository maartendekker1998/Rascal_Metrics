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
	for (<definition, comments> <- model.documentation)
	{
		if (definition.scheme=="java+method" || definition.scheme=="java+constructor")
		{
			list[str] lines = readFileLines(definition);
			map[str,int] methodLines = ((definition.path notin(linesPerMethod)) ? () : linesPerMethod[definition.path]);
			methodLines+=(substring(definition.file, 0, findFirst(definition.file, "(")): size(lines)+(comments.begin.line - (comments.end.line+1)));
			linesPerMethod+=(definition.path:methodLines);
		}
	}
	return linesPerMethod;
}