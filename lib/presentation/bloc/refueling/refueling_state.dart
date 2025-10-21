import '../../../domain/entities/refueling_entry.dart';
import '../../../domain/entities/refueling_summary.dart';

/// Base class for all refueling states
abstract class RefuelingState {}

/// Initial state
class RefuelingInitial extends RefuelingState {}

/// Loading state
class RefuelingLoading extends RefuelingState {}

/// State when refueling entries are loaded successfully
class RefuelingEntriesLoaded extends RefuelingState {
  final List<RefuelingEntry> entries;
  final String? vehicleId;
  final String? message;

  RefuelingEntriesLoaded({required this.entries, this.vehicleId, this.message});
}

/// State when a single refueling entry is loaded
class RefuelingEntryDetailLoaded extends RefuelingState {
  final RefuelingEntry entry;

  RefuelingEntryDetailLoaded(this.entry);
}

/// State when refueling summary is loaded
class RefuelingSummaryLoaded extends RefuelingState {
  final RefuelingSummary summary;

  RefuelingSummaryLoaded(this.summary);
}

/// State when refueling statistics are loaded
class RefuelingStatisticsLoaded extends RefuelingState {
  final Map<String, dynamic> statistics;

  RefuelingStatisticsLoaded(this.statistics);
}

/// State when fuel efficiency is calculated
class FuelEfficiencyCalculated extends RefuelingState {
  final double efficiency; // L/100km
  final String vehicleId;
  final DateTime startDate;
  final DateTime endDate;

  FuelEfficiencyCalculated({
    required this.efficiency,
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
  });
}

/// State when refueling entries are filtered
class RefuelingEntriesFiltered extends RefuelingState {
  final List<RefuelingEntry> entries;
  final String? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  RefuelingEntriesFiltered({
    required this.entries,
    this.vehicleId,
    this.startDate,
    this.endDate,
  });
}

/// State when refueling operation is in progress
class RefuelingOperationInProgress extends RefuelingState {
  final String operation;
  final String? entryId;

  RefuelingOperationInProgress({required this.operation, this.entryId});
}

/// State when refueling operation is successful
class RefuelingOperationSuccess extends RefuelingState {
  final String operation;
  final String message;
  final RefuelingEntry? entry;

  RefuelingOperationSuccess({
    required this.operation,
    required this.message,
    this.entry,
  });
}

/// Error state
class RefuelingError extends RefuelingState {
  final String message;
  final String? operation;

  RefuelingError({required this.message, this.operation});
}

/// Empty state (no refueling entries found)
class RefuelingEmpty extends RefuelingState {
  final String message;
  final String? vehicleId;

  RefuelingEmpty({this.message = 'No refueling entries found', this.vehicleId});
}
