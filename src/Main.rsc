module Main

import IO;
import ProjectLoader::Loader;
import SIG::SigModel;
import Metrics::Volume;

loc application = |project://JabberPoint/|;

void main(str arg)
{
	println("Main with arguments");
    return 0;
}

void main()
{
	print(getSigReport(application));
}