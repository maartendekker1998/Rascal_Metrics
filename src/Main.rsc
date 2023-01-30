module Main

import IO;
import SIG::SigModel;
import Visualisation::Dashboard;
import DataTypes::LocationDetails;

@doc
{
	Rascal main function takes an argument as a projectname to analyze,
	this project needs to be available in the Eclipse workspace
}
public void main(str arg)
{
	loc application = |project://<arg>/|;
	calculate(application);
}

@doc
{
	Rascal main function is executed if no parameter given will default to calculating smallsql
}
public void main()
{
	println("No argument given, defaulting to smallsql\n");
	loc application = |project://smallsql/|;
	calculate(application);
}

@doc
{
	Calculates the metrics and prints the report to the screen,
	also the rendering of the dashboard is triggered here.
}
private void calculate(loc application)
{
	Metric metric = getSigMetric(application);
	println(metric.report);
	renderDashboard(metric.dashboard);
}