import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/refueling_entry.dart';

/// Base class for all reports states
abstract class ReportsState {}

/// Initial state
class ReportsInitial extends ReportsState {}

/// Loading state
class ReportsLoading extends ReportsState {}

/// State when overview data is loaded
class OverviewDataLoaded extends ReportsState {
  final Map<String, dynamic> overviewData;
  final String? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  OverviewDataLoaded({
    required this.overviewData,
    this.vehicleId,
    this.startDate,
    this.endDate,
  });
}

/// State when fuel data is loaded
class FuelDataLoaded extends ReportsState {
  final List<RefuelingEntry> refuelingEntries;
  final Map<String, dynamic> fuelStatistics;
  final String? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  FuelDataLoaded({
    required this.refuelingEntries,
    required this.fuelStatistics,
    this.vehicleId,
    this.startDate,
    this.endDate,
  });
}

/// State when costs data is loaded
class CostsDataLoaded extends ReportsState {
  final List<Transaction> transactions;
  final Map<String, dynamic> costStatistics;
  final String? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  CostsDataLoaded({
    required this.transactions,
    required this.costStatistics,
    this.vehicleId,
    this.startDate,
    this.endDate,
  });
}

/// State when odometer data is loaded
class OdometerDataLoaded extends ReportsState {
  final List<RefuelingEntry> odometerEntries;
  final Map<String, dynamic> odometerStatistics;
  final String? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  OdometerDataLoaded({
    required this.odometerEntries,
    required this.odometerStatistics,
    this.vehicleId,
    this.startDate,
    this.endDate,
  });
}

/// State when ownership data is loaded
class OwnershipDataLoaded extends ReportsState {
  final Map<String, dynamic> ownershipData;
  final String? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  OwnershipDataLoaded({
    required this.ownershipData,
    this.vehicleId,
    this.startDate,
    this.endDate,
  });
}

/// State when all reports data is loaded
class AllReportsDataLoaded extends ReportsState {
  final Map<String, dynamic> overviewData;
  final List<RefuelingEntry> refuelingEntries;
  final Map<String, dynamic> fuelStatistics;
  final List<Transaction> transactions;
  final Map<String, dynamic> costStatistics;
  final List<RefuelingEntry> odometerEntries;
  final Map<String, dynamic> odometerStatistics;
  final Map<String, dynamic> ownershipData;
  final String? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  AllReportsDataLoaded({
    required this.overviewData,
    required this.refuelingEntries,
    required this.fuelStatistics,
    required this.transactions,
    required this.costStatistics,
    required this.odometerEntries,
    required this.odometerStatistics,
    required this.ownershipData,
    this.vehicleId,
    this.startDate,
    this.endDate,
  });
}

/// Error state
class ReportsError extends ReportsState {
  final String message;
  final String? operation;

  ReportsError({required this.message, this.operation});
}

/// Empty state (no data available)
class ReportsEmpty extends ReportsState {
  final String message;
  final String? vehicleId;

  ReportsEmpty({this.message = 'No data available', this.vehicleId});
}
