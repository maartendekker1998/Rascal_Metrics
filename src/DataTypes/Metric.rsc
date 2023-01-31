module DataTypes::Metric

import DataTypes::DashboardData;

public alias Metric = tuple[str report, DashboardData dashboard];