module JavaLoader::Loader

import util::Resources;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;

import IO;

import SIG::SigModel;

M3 model = createM3FromEclipseProject(|project://JabberPoint/|);

public void initialize()
{
	calculate();
}

public void load()
{
	getJavaFiles();
}

public void getJavaFiles()
{
	Resource jabber = getProject(|project://JabberPoint/|);
    println({a | /file(a) <- jabber, a.extension == "java"});
}