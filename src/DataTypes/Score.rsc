module DataTypes::Score

import DataTypes::Rank;

public alias MetricScore = tuple[Rank volumeRank, Rank unitSizeRank, Rank unitComplexityRank, Rank duplicationRank];
public alias OveralScore = tuple[Rank analyzebilityRank, Rank changeabilityRank, Rank testabilityRank, Rank overallRank];
