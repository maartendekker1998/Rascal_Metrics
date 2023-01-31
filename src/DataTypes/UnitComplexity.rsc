module DataTypes::UnitComplexity

import lang::java::m3::AST;

public alias UnitComplexity = tuple[lrel[Declaration, int, int] functionsWithSizeAndComplexity,map[str,real] complexity];
