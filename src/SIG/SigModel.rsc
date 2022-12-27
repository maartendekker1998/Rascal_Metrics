module SIG::SigModel

import IO;
import String;
import Metrics::Volume;
import Metrics::UnitComplexity;
import Metrics::Duplication;
import Metrics::UnitSize;

// This function will trigger all the metrics and compose the report
public str getSigReport(loc application){

	calculateSIGUnitSize(application);
	
	//calculateSIGVolume(application);
	
	return "report placeholder";
}

public void calculate()
{
	//get volume
	//get unit complexity
	//get duplicate
	//get unit size
}

// this function will invoke metric calculation for Volume and apply the SIG score
void calculateSIGVolume(loc application){

	// get the LOC value
	int volume = calculateVolume(application);
	
	// calculate SIG score
}

void calculateSIGUnitSize(loc application)
{
	map[str,map[str,int]] unitSizes = calculateUnitSize(application);
	//for (x <- unitSizes)
	//{
	//	if (contains(x, "SwingWindowHandler"))
	//	println("<x> - <unitSizes[x]>");
	//}
}


