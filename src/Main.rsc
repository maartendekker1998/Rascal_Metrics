module Main

import IO;
import SIG::SigModel;
import Visualisation::Dashboard;
import DataTypes::LocationDetails;

public void main(str arg)
{
	loc application = |project://<arg>/|;
	Metric metric = getSigMetric(application);
	println(metric.report);
	renderDashboard(metric.dashboard);
}

public void main()
{
	println("No argument given, defaulting to smallsql\n");
	loc application = |project://smallsql/|;
	Metric metric = getSigMetric(application);
	println(metric.report);
	renderDashboard(metric.dashboard);
}