/// Base class for all home events
abstract class HomeEvent {}

/// Event to load home data
class LoadHomeData extends HomeEvent {}

/// Event to refresh home data
class RefreshHomeData extends HomeEvent {}

/// Event to load primary vehicle
class LoadPrimaryVehicle extends HomeEvent {}

/// Event to load recent transactions
class LoadRecentTransactions extends HomeEvent {
  final int limit;

  LoadRecentTransactions({this.limit = 5});
}

/// Event to load vehicle statistics
class LoadVehicleStatistics extends HomeEvent {
  final String vehicleId;

  LoadVehicleStatistics(this.vehicleId);
}

/// Event to load upcoming maintenance
class LoadUpcomingMaintenance extends HomeEvent {
  final String vehicleId;

  LoadUpcomingMaintenance(this.vehicleId);
}

/// Event to load fuel consumption stats
class LoadFuelConsumptionStats extends HomeEvent {
  final String vehicleId;

  LoadFuelConsumptionStats(this.vehicleId);
}

/// Event to load monthly costs
class LoadMonthlyCosts extends HomeEvent {
  final String vehicleId;
  final int year;
  final int month;

  LoadMonthlyCosts({
    required this.vehicleId,
    required this.year,
    required this.month,
  });
}
