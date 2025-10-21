import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/refueling_usecases.dart' as refueling_usecases;
import 'refueling_event.dart';
import 'refueling_state.dart';

class RefuelingBloc extends Bloc<RefuelingEvent, RefuelingState> {
  final refueling_usecases.GetRefuelingEntries _getRefuelingEntries;
  final refueling_usecases.GetRefuelingEntriesByVehicle
  _getRefuelingEntriesByVehicle;
  final refueling_usecases.GetRefuelingEntriesByDateRange
  _getRefuelingEntriesByDateRange;
  final refueling_usecases.GetRecentRefuelingEntries _getRecentRefuelingEntries;
  final refueling_usecases.AddRefuelingEntry _addRefuelingEntry;
  final refueling_usecases.UpdateRefuelingEntry _updateRefuelingEntry;
  final refueling_usecases.DeleteRefuelingEntry _deleteRefuelingEntry;
  final refueling_usecases.GetRefuelingEntry _getRefuelingEntry;
  final refueling_usecases.GetRefuelingSummary _getRefuelingSummary;
  final refueling_usecases.GetRefuelingStatistics _getRefuelingStatistics;
  final refueling_usecases.CalculateFuelEfficiency _calculateFuelEfficiency;

  RefuelingBloc({
    required refueling_usecases.GetRefuelingEntries getRefuelingEntries,
    required refueling_usecases.GetRefuelingEntriesByVehicle
    getRefuelingEntriesByVehicle,
    required refueling_usecases.GetRefuelingEntriesByDateRange
    getRefuelingEntriesByDateRange,
    required refueling_usecases.GetRecentRefuelingEntries
    getRecentRefuelingEntries,
    required refueling_usecases.AddRefuelingEntry addRefuelingEntry,
    required refueling_usecases.UpdateRefuelingEntry updateRefuelingEntry,
    required refueling_usecases.DeleteRefuelingEntry deleteRefuelingEntry,
    required refueling_usecases.GetRefuelingEntry getRefuelingEntry,
    required refueling_usecases.GetRefuelingSummary getRefuelingSummary,
    required refueling_usecases.GetRefuelingStatistics getRefuelingStatistics,
    required refueling_usecases.CalculateFuelEfficiency calculateFuelEfficiency,
  }) : _getRefuelingEntries = getRefuelingEntries,
       _getRefuelingEntriesByVehicle = getRefuelingEntriesByVehicle,
       _getRefuelingEntriesByDateRange = getRefuelingEntriesByDateRange,
       _getRecentRefuelingEntries = getRecentRefuelingEntries,
       _addRefuelingEntry = addRefuelingEntry,
       _updateRefuelingEntry = updateRefuelingEntry,
       _deleteRefuelingEntry = deleteRefuelingEntry,
       _getRefuelingEntry = getRefuelingEntry,
       _getRefuelingSummary = getRefuelingSummary,
       _getRefuelingStatistics = getRefuelingStatistics,
       _calculateFuelEfficiency = calculateFuelEfficiency,
       super(RefuelingInitial()) {
    on<LoadRefuelingEntries>(_onLoadRefuelingEntries);
    on<LoadRefuelingEntriesByVehicle>(_onLoadRefuelingEntriesByVehicle);
    on<LoadRefuelingEntriesByDateRange>(_onLoadRefuelingEntriesByDateRange);
    on<LoadRecentRefuelingEntries>(_onLoadRecentRefuelingEntries);
    on<AddRefuelingEntry>(_onAddRefuelingEntry);
    on<UpdateRefuelingEntry>(_onUpdateRefuelingEntry);
    on<DeleteRefuelingEntry>(_onDeleteRefuelingEntry);
    on<LoadRefuelingEntryDetail>(_onLoadRefuelingEntryDetail);
    on<LoadRefuelingSummary>(_onLoadRefuelingSummary);
    on<LoadRefuelingStatistics>(_onLoadRefuelingStatistics);
    on<CalculateFuelEfficiency>(_onCalculateFuelEfficiency);
    on<RefreshRefuelingData>(_onRefreshRefuelingData);
    on<ClearRefuelingFilters>(_onClearRefuelingFilters);
  }

  Future<void> _onLoadRefuelingEntries(
    LoadRefuelingEntries event,
    Emitter<RefuelingState> emit,
  ) async {
    emit(RefuelingLoading());
    try {
      final entries = await _getRefuelingEntries();
      if (entries.isEmpty) {
        emit(RefuelingEmpty());
      } else {
        emit(RefuelingEntriesLoaded(entries: entries));
      }
    } catch (e) {
      emit(RefuelingError(message: e.toString()));
    }
  }

  Future<void> _onLoadRefuelingEntriesByVehicle(
    LoadRefuelingEntriesByVehicle event,
    Emitter<RefuelingState> emit,
  ) async {
    emit(RefuelingLoading());
    try {
      final entries = await _getRefuelingEntriesByVehicle(event.vehicleId);
      if (entries.isEmpty) {
        emit(
          RefuelingEmpty(
            message: 'No refueling entries found for this vehicle',
            vehicleId: event.vehicleId,
          ),
        );
      } else {
        emit(
          RefuelingEntriesLoaded(entries: entries, vehicleId: event.vehicleId),
        );
      }
    } catch (e) {
      emit(RefuelingError(message: e.toString()));
    }
  }

  Future<void> _onLoadRefuelingEntriesByDateRange(
    LoadRefuelingEntriesByDateRange event,
    Emitter<RefuelingState> emit,
  ) async {
    emit(RefuelingLoading());
    try {
      final entries = await _getRefuelingEntriesByDateRange(
        vehicleId: event.vehicleId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      if (entries.isEmpty) {
        emit(
          RefuelingEmpty(
            message: 'No refueling entries found in this date range',
            vehicleId: event.vehicleId,
          ),
        );
      } else {
        emit(
          RefuelingEntriesFiltered(
            entries: entries,
            vehicleId: event.vehicleId,
            startDate: event.startDate,
            endDate: event.endDate,
          ),
        );
      }
    } catch (e) {
      emit(RefuelingError(message: e.toString()));
    }
  }

  Future<void> _onLoadRecentRefuelingEntries(
    LoadRecentRefuelingEntries event,
    Emitter<RefuelingState> emit,
  ) async {
    emit(RefuelingLoading());
    try {
      final entries = await _getRecentRefuelingEntries(
        vehicleId: event.vehicleId,
        limit: event.limit,
      );
      if (entries.isEmpty) {
        emit(
          RefuelingEmpty(
            message: 'No recent refueling entries found',
            vehicleId: event.vehicleId,
          ),
        );
      } else {
        emit(
          RefuelingEntriesLoaded(
            entries: entries,
            vehicleId: event.vehicleId,
            message: 'Recent refueling entries loaded',
          ),
        );
      }
    } catch (e) {
      emit(RefuelingError(message: e.toString()));
    }
  }

  Future<void> _onAddRefuelingEntry(
    AddRefuelingEntry event,
    Emitter<RefuelingState> emit,
  ) async {
    emit(RefuelingOperationInProgress(operation: 'Adding refueling entry'));
    try {
      await _addRefuelingEntry(event.entry);
      emit(
        RefuelingOperationSuccess(
          operation: 'Add',
          message: 'Refueling entry added successfully',
          entry: event.entry,
        ),
      );
    } catch (e) {
      emit(RefuelingError(message: e.toString(), operation: 'Add'));
    }
  }

  Future<void> _onUpdateRefuelingEntry(
    UpdateRefuelingEntry event,
    Emitter<RefuelingState> emit,
  ) async {
    emit(
      RefuelingOperationInProgress(
        operation: 'Updating refueling entry',
        entryId: event.entry.id,
      ),
    );
    try {
      await _updateRefuelingEntry(event.entry);
      emit(
        RefuelingOperationSuccess(
          operation: 'Update',
          message: 'Refueling entry updated successfully',
          entry: event.entry,
        ),
      );
    } catch (e) {
      emit(RefuelingError(message: e.toString(), operation: 'Update'));
    }
  }

  Future<void> _onDeleteRefuelingEntry(
    DeleteRefuelingEntry event,
    Emitter<RefuelingState> emit,
  ) async {
    emit(
      RefuelingOperationInProgress(
        operation: 'Deleting refueling entry',
        entryId: event.entryId,
      ),
    );
    try {
      await _deleteRefuelingEntry(event.entryId);
      emit(
        RefuelingOperationSuccess(
          operation: 'Delete',
          message: 'Refueling entry deleted successfully',
        ),
      );
    } catch (e) {
      emit(RefuelingError(message: e.toString(), operation: 'Delete'));
    }
  }

  Future<void> _onLoadRefuelingEntryDetail(
    LoadRefuelingEntryDetail event,
    Emitter<RefuelingState> emit,
  ) async {
    emit(RefuelingLoading());
    try {
      final entry = await _getRefuelingEntry(event.entryId);
      if (entry == null) {
        emit(RefuelingError(message: 'Refueling entry not found'));
      } else {
        emit(RefuelingEntryDetailLoaded(entry));
      }
    } catch (e) {
      emit(RefuelingError(message: e.toString()));
    }
  }

  Future<void> _onLoadRefuelingSummary(
    LoadRefuelingSummary event,
    Emitter<RefuelingState> emit,
  ) async {
    emit(RefuelingLoading());
    try {
      final summary = await _getRefuelingSummary(event.vehicleId);
      emit(RefuelingSummaryLoaded(summary));
    } catch (e) {
      emit(RefuelingError(message: e.toString()));
    }
  }

  Future<void> _onLoadRefuelingStatistics(
    LoadRefuelingStatistics event,
    Emitter<RefuelingState> emit,
  ) async {
    emit(RefuelingLoading());
    try {
      final statistics = await _getRefuelingStatistics(
        vehicleId: event.vehicleId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(RefuelingStatisticsLoaded(statistics));
    } catch (e) {
      emit(RefuelingError(message: e.toString()));
    }
  }

  Future<void> _onCalculateFuelEfficiency(
    CalculateFuelEfficiency event,
    Emitter<RefuelingState> emit,
  ) async {
    emit(RefuelingLoading());
    try {
      final efficiency = await _calculateFuelEfficiency(
        vehicleId: event.vehicleId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(
        FuelEfficiencyCalculated(
          efficiency: efficiency,
          vehicleId: event.vehicleId,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );
    } catch (e) {
      emit(RefuelingError(message: e.toString()));
    }
  }

  Future<void> _onRefreshRefuelingData(
    RefreshRefuelingData event,
    Emitter<RefuelingState> emit,
  ) async {
    // Reload the current data based on the current state
    final currentState = state;
    if (currentState is RefuelingEntriesLoaded) {
      if (currentState.vehicleId != null) {
        add(LoadRefuelingEntriesByVehicle(currentState.vehicleId!));
      } else {
        add(LoadRefuelingEntries());
      }
    }
  }

  Future<void> _onClearRefuelingFilters(
    ClearRefuelingFilters event,
    Emitter<RefuelingState> emit,
  ) async {
    add(LoadRefuelingEntries());
  }
}
