module Main

import IO;
import ProjectLoader::Loader;
import SIG::SigModel;
import Metrics::Volume;

loc application = |project://hsqldb/|;

void main()
{
	print(getSigReport(application));
}