module Main

import IO;
import ProjectLoader::Loader;
import SIG::SigModel;
import Metrics::Volume;
import String;
import Type;
import util::Benchmark;
import util::Math;

loc application = |project://hsqldb/|;

void main(str arg)
{
	println("Main with arguments");
    return 0;
}

private str formatDate(int x) = size(toString(x)) == 1 ? "0<x>" : "<x>";

void main()
{
	int startTime = realTime();
	print(getSigReport(application));
	int endTime = ((realTime()-startTime)/1000);
	int hours = endTime / 3600;
	int minutes = (endTime % 3600) /60;
	int seconds = endTime % 60;
	println("Execution time: <formatDate(hours)>:<formatDate(minutes)>:<formatDate(seconds)>");
}
