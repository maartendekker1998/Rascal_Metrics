module Main

import IO;
import ProjectLoader::Loader;
import SIG::SigModel;

loc application = |project://Jabberpoint/|;

int main(str arg)
{
	println("Main with arguments");
    return 0;
}

int main()
{

	getSigReport(application);
		
	return 0;
}