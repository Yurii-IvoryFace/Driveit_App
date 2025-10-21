import 'package:equatable/equatable.dart';

/// Base class for all reports events
abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load overview data
class LoadOverviewData extends ReportsEvent {
  final String? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadOverviewData({this.vehicleId, this.startDate, this.endDate});

  @override
  List<Object?> get props => [vehicleId, startDate, endDate];
}

/// Event to load fuel data
class LoadFuelData extends ReportsEvent {
  final String? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadFuelData({this.vehicleId, this.startDate, this.endDate});

  @override
  List<Object?> get props => [vehicleId, startDate, endDate];
}

/// Event to load costs data
class LoadCostsData extends ReportsEvent {
  final String? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadCostsData({this.vehicleId, this.startDate, this.endDate});

  @override
  List<Object?> get props => [vehicleId, startDate, endDate];
}

/// Event to load odometer data
class LoadOdometerData extends ReportsEvent {
  final String? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadOdometerData({this.vehicleId, this.startDate, this.endDate});

  @override
  List<Object?> get props => [vehicleId, startDate, endDate];
}

/// Event to load ownership data
class LoadOwnershipData extends ReportsEvent {
  final String? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadOwnershipData({this.vehicleId, this.startDate, this.endDate});

  @override
  List<Object?> get props => [vehicleId, startDate, endDate];
}

/// Event to refresh all reports data
class RefreshReportsData extends ReportsEvent {
  final String? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  const RefreshReportsData({this.vehicleId, this.startDate, this.endDate});

  @override
  List<Object?> get props => [vehicleId, startDate, endDate];
}

/// Event to change date range
class ChangeDateRange extends ReportsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const ChangeDateRange({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Event to change selected vehicle
class ChangeSelectedVehicle extends ReportsEvent {
  final String? vehicleId;

  const ChangeSelectedVehicle(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}
