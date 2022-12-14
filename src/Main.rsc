module Main

import Metrics::Duplication;
import Metrics::UnitComplexity;
import Metrics::UnitSize;
import Metrics::Volume;
import JavaLoader::Loader;

import IO;

int main(str arg)
{
	println("Main with arguments");
    return 0;
}

int main()
{
	println("Main empty");
	return 0;
}