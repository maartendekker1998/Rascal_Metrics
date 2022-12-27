module SIG::SigRanking

import IO;
import util::Math;

int SIG_JAVA_KLOC_PLUS_PLUS = 66;
int SIG_JAVA_KLOC_PLUS = 246;
int SIG_JAVA_KLOC_O = 665;
int SIG_JAVA_KLOC_MIN = 1310;

str computeSIGVolumeRank(int lines_of_code){
	
	num kloc = toReal(lines_of_code)/1000;

	if (kloc < SIG_JAVA_KLOC_PLUS_PLUS){
		return "++";
	}
	else if(kloc >= SIG_JAVA_KLOC_PLUS_PLUS && kloc < SIG_JAVA_KLOC_PLUS){
		return "+";
	}
	else if (kloc >= SIG_JAVA_KLOC_PLUS && kloc < SIG_JAVA_KLOC_O){
		return "o";
	}
	else if (kloc >= SIG_JAVA_KLOC_O && kloc < SIG_JAVA_KLOC_MIN){
		return "-";
	}
	else{
		return "--";
	}
}