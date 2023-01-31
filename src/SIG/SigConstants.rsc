module SIG::SigConstants

import DataTypes::Rank;

//Complexity identifiers
public str SIG_SIMPLE    = "simple";
public str SIG_MODERATE  = "moderate";
public str SIG_HIGH      = "high";
public str SIG_VERY_HIGH = "very high";

// Sig Ranks
public Rank plusplus = <"++",  2>;
public Rank plus     = <"+" ,  1>;
public Rank neutral  = <"o" ,  0>;
public Rank min      = <"-" , -1>;
public Rank minmin   = <"--", -2>;

//SIG Total Volume ranking values
public int SIG_JAVA_KLOC_PLUS_PLUS = 66;
public int SIG_JAVA_KLOC_PLUS      = 246;
public int SIG_JAVA_KLOC_O         = 665;
public int SIG_JAVA_KLOC_MIN       = 1310;

//SIG Unit Complexity values
public int SIG_MAX_SIZE_LOW      = 15;
public int SIG_MAX_SIZE_MODERATE = 30;
public int SIG_MAX_SIZE_HIGH     = 60;

//SIG Unit Complexity values
public int SIG_MAX_COMPLEXITY_LOW       = 10;
public int SIG_MAX_COMPLEXITY_MODERATE  = 20;
public int SIG_MAX_COMPLEXITY_HIGH      = 50;


//SIG Total Duplication percentage ranking values
public int SIG_DUPLICATION_PERCENTAGE_PLUS_PLUS = 3;
public int SIG_DUPLICATION_PERCENTAGE_PLUS      = 5;
public int SIG_DUPLICATION_PERCENTAGE_O         = 10;
public int SIG_DUPLICATION_PERCENTAGE_MIN       = 20;

//SIG Thresholds for power law distribution of unit size
public map[str,int] MAX_UNIT_SIZE_THRESHOLDS_PLUS_PLUS = (SIG_MODERATE : 25, SIG_HIGH : 0 , SIG_VERY_HIGH : 0);
public map[str,int] MAX_UNIT_SIZE_THRESHOLDS_PLUS      = (SIG_MODERATE : 30, SIG_HIGH : 5 , SIG_VERY_HIGH : 0);
public map[str,int] MAX_UNIT_SIZE_THRESHOLDS_O         = (SIG_MODERATE : 40, SIG_HIGH : 10, SIG_VERY_HIGH : 0);
public map[str,int] MAX_UNIT_SIZE_THRESHOLDS_MIN       = (SIG_MODERATE : 50, SIG_HIGH : 15, SIG_VERY_HIGH : 5);

//SIG Thresholds for power law distribution of unit complexity
public map[str,int] MAX_UNIT_COMPLEXITY_THRESHOLDS_PLUS_PLUS = (SIG_MODERATE : 25, SIG_HIGH : 0 , SIG_VERY_HIGH : 0);
public map[str,int] MAX_UNIT_COMPLEXITY_THRESHOLDS_PLUS      = (SIG_MODERATE : 30, SIG_HIGH : 5 , SIG_VERY_HIGH : 0);
public map[str,int] MAX_UNIT_COMPLEXITY_THRESHOLDS_O         = (SIG_MODERATE : 40, SIG_HIGH : 10, SIG_VERY_HIGH : 0);
public map[str,int] MAX_UNIT_COMPLEXITY_THRESHOLDS_MIN       = (SIG_MODERATE : 50, SIG_HIGH : 15, SIG_VERY_HIGH : 5);