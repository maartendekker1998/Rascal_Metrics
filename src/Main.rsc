module Main

import IO;
import SIG::SigModel;
import Visualisation::Dashboard;
import DataTypes::LocationDetails;

private loc application = |project://JabberPoint/|;

public void main()
{
	Metric metric = getSigMetric(application);
	println(metric.report);
	renderDashboard(metric.dashboard);
}