module Main

import IO;
import ProjectLoader::Loader;
import SIG::SigModel;
import Metrics::Volume;
import String;
import Type;





loc application = |project://test/|;

void printMyType(&T a) { println("<typeOf(a)>"); }


void main(str arg)
{
	println("Main with arguments");
    return 0;
}

void main()
{
	print(getSigReport(application));
	
	
}