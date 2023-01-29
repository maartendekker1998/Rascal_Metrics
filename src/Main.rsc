module Main

import IO;
import ProjectLoader::Loader;
import SIG::SigModel;
import Metrics::Volume;
import Visualisation::Dashboard;
import DataTypes::LocationDetails;

loc application = |project://smallsql/|;

void main()
{
	Metric metric = getSigMetric(application);
	println(metric.report);
	renderDashboard(metric.dashboard);
}