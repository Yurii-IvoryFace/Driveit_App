import 'package:equatable/equatable.dart';

import '../../../domain/entities/refueling_entry.dart';

/// Base class for all refueling events
abstract class RefuelingEvent extends Equatable {
  const RefuelingEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all refueling entries
class LoadRefuelingEntries extends RefuelingEvent {}

/// Event to load refueling entries for a specific vehicle
class LoadRefuelingEntriesByVehicle extends RefuelingEvent {
  final String vehicleId;

  const LoadRefuelingEntriesByVehicle(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

/// Event to load refueling entries by date range
class LoadRefuelingEntriesByDateRange extends RefuelingEvent {
  final String vehicleId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadRefuelingEntriesByDateRange({
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [vehicleId, startDate, endDate];
}

/// Event to load recent refueling entries
class LoadRecentRefuelingEntries extends RefuelingEvent {
  final String vehicleId;
  final int limit;

  const LoadRecentRefuelingEntries({required this.vehicleId, this.limit = 10});

  @override
  List<Object?> get props => [vehicleId, limit];
}

/// Event to add a new refueling entry
class AddRefuelingEntry extends RefuelingEvent {
  final RefuelingEntry entry;

  const AddRefuelingEntry(this.entry);

  @override
  List<Object?> get props => [entry];
}

/// Event to update an existing refueling entry
class UpdateRefuelingEntry extends RefuelingEvent {
  final RefuelingEntry entry;

  const UpdateRefuelingEntry(this.entry);

  @override
  List<Object?> get props => [entry];
}

/// Event to delete a refueling entry
class DeleteRefuelingEntry extends RefuelingEvent {
  final String entryId;

  const DeleteRefuelingEntry(this.entryId);

  @override
  List<Object?> get props => [entryId];
}

/// Event to load a single refueling entry
class LoadRefuelingEntryDetail extends RefuelingEvent {
  final String entryId;

  const LoadRefuelingEntryDetail(this.entryId);

  @override
  List<Object?> get props => [entryId];
}

/// Event to load refueling summary
class LoadRefuelingSummary extends RefuelingEvent {
  final String vehicleId;

  const LoadRefuelingSummary(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

/// Event to load refueling statistics
class LoadRefuelingStatistics extends RefuelingEvent {
  final String vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadRefuelingStatistics({
    required this.vehicleId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [vehicleId, startDate, endDate];
}

/// Event to calculate fuel efficiency
class CalculateFuelEfficiency extends RefuelingEvent {
  final String vehicleId;
  final DateTime startDate;
  final DateTime endDate;

  const CalculateFuelEfficiency({
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [vehicleId, startDate, endDate];
}

/// Event to refresh refueling data
class RefreshRefuelingData extends RefuelingEvent {}

/// Event to clear refueling filters
class ClearRefuelingFilters extends RefuelingEvent {}
