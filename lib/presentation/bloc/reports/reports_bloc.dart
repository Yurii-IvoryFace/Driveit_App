import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../domain/usecases/transaction_usecases.dart'
    as transaction_usecases;
import '../../../domain/usecases/refueling_usecases.dart' as refueling_usecases;
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/refueling_entry.dart';
import '../../../core/utils/chart_data_utils.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final transaction_usecases.GetTransactions _getTransactions;
  final transaction_usecases.GetTransactionsByVehicle _getTransactionsByVehicle;
  final transaction_usecases.GetTransactionsByDateRange
  _getTransactionsByDateRange;
  final transaction_usecases.GetTransactionStatistics _getTransactionStatistics;
  final refueling_usecases.GetRefuelingEntries _getRefuelingEntries;
  final refueling_usecases.GetRefuelingEntriesByVehicle
  _getRefuelingEntriesByVehicle;
  final refueling_usecases.GetRefuelingEntriesByDateRange
  _getRefuelingEntriesByDateRange;
  final refueling_usecases.GetRefuelingStatistics _getRefuelingStatistics;

  ReportsBloc({
    required transaction_usecases.GetTransactions getTransactions,
    required transaction_usecases.GetTransactionsByVehicle
    getTransactionsByVehicle,
    required transaction_usecases.GetTransactionsByDateRange
    getTransactionsByDateRange,
    required transaction_usecases.GetTransactionStatistics
    getTransactionStatistics,
    required refueling_usecases.GetRefuelingEntries getRefuelingEntries,
    required refueling_usecases.GetRefuelingEntriesByVehicle
    getRefuelingEntriesByVehicle,
    required refueling_usecases.GetRefuelingEntriesByDateRange
    getRefuelingEntriesByDateRange,
    required refueling_usecases.GetRefuelingStatistics getRefuelingStatistics,
  }) : _getTransactions = getTransactions,
       _getTransactionsByVehicle = getTransactionsByVehicle,
       _getTransactionsByDateRange = getTransactionsByDateRange,
       _getTransactionStatistics = getTransactionStatistics,
       _getRefuelingEntries = getRefuelingEntries,
       _getRefuelingEntriesByVehicle = getRefuelingEntriesByVehicle,
       _getRefuelingEntriesByDateRange = getRefuelingEntriesByDateRange,
       _getRefuelingStatistics = getRefuelingStatistics,
       super(ReportsInitial()) {
    on<LoadOverviewData>(_onLoadOverviewData);
    on<LoadFuelData>(_onLoadFuelData);
    on<LoadCostsData>(_onLoadCostsData);
    on<LoadOdometerData>(_onLoadOdometerData);
    on<LoadOwnershipData>(_onLoadOwnershipData);
    on<RefreshReportsData>(_onRefreshReportsData);
    on<ChangeDateRange>(_onChangeDateRange);
    on<ChangeSelectedVehicle>(_onChangeSelectedVehicle);
  }

  Future<void> _onLoadOverviewData(
    LoadOverviewData event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      // Load transactions and refueling data for overview
      final transactions = await _loadTransactions(
        event.vehicleId,
        event.startDate,
        event.endDate,
      );
      final refuelingEntries = await _loadRefuelingEntries(
        event.vehicleId,
        event.startDate,
        event.endDate,
      );

      // Calculate overview statistics
      final overviewData = _calculateOverviewData(
        transactions,
        refuelingEntries,
      );

      emit(
        OverviewDataLoaded(
          overviewData: overviewData,
          vehicleId: event.vehicleId,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );
    } catch (e) {
      emit(ReportsError(message: e.toString(), operation: 'Load Overview'));
    }
  }

  Future<void> _onLoadFuelData(
    LoadFuelData event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final refuelingEntries = await _loadRefuelingEntries(
        event.vehicleId,
        event.startDate,
        event.endDate,
      );
      final fuelStatistics = await _getRefuelingStatistics(
        vehicleId: event.vehicleId ?? '',
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(
        FuelDataLoaded(
          refuelingEntries: refuelingEntries,
          fuelStatistics: fuelStatistics,
          vehicleId: event.vehicleId,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );
    } catch (e) {
      emit(ReportsError(message: e.toString(), operation: 'Load Fuel Data'));
    }
  }

  Future<void> _onLoadCostsData(
    LoadCostsData event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final transactions = await _loadTransactions(
        event.vehicleId,
        event.startDate,
        event.endDate,
      );
      final costStatistics = await _getTransactionStatistics(
        vehicleId: event.vehicleId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(
        CostsDataLoaded(
          transactions: transactions,
          costStatistics: costStatistics,
          vehicleId: event.vehicleId,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );
    } catch (e) {
      emit(ReportsError(message: e.toString(), operation: 'Load Costs Data'));
    }
  }

  Future<void> _onLoadOdometerData(
    LoadOdometerData event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final odometerEntries = await _loadRefuelingEntries(
        event.vehicleId,
        event.startDate,
        event.endDate,
      );
      final odometerStatistics = _calculateOdometerStatistics(odometerEntries);

      emit(
        OdometerDataLoaded(
          odometerEntries: odometerEntries,
          odometerStatistics: odometerStatistics,
          vehicleId: event.vehicleId,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );
    } catch (e) {
      emit(
        ReportsError(message: e.toString(), operation: 'Load Odometer Data'),
      );
    }
  }

  Future<void> _onLoadOwnershipData(
    LoadOwnershipData event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final transactions = await _loadTransactions(
        event.vehicleId,
        event.startDate,
        event.endDate,
      );
      final refuelingEntries = await _loadRefuelingEntries(
        event.vehicleId,
        event.startDate,
        event.endDate,
      );

      final ownershipData = _calculateOwnershipData(
        transactions,
        refuelingEntries,
      );

      emit(
        OwnershipDataLoaded(
          ownershipData: ownershipData,
          vehicleId: event.vehicleId,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );
    } catch (e) {
      emit(
        ReportsError(message: e.toString(), operation: 'Load Ownership Data'),
      );
    }
  }

  Future<void> _onRefreshReportsData(
    RefreshReportsData event,
    Emitter<ReportsState> emit,
  ) async {
    // Load all data
    add(
      LoadOverviewData(
        vehicleId: event.vehicleId,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );
  }

  Future<void> _onChangeDateRange(
    ChangeDateRange event,
    Emitter<ReportsState> emit,
  ) async {
    // Reload current data with new date range
    final currentState = state;
    if (currentState is OverviewDataLoaded) {
      add(
        LoadOverviewData(
          vehicleId: currentState.vehicleId,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );
    }
  }

  Future<void> _onChangeSelectedVehicle(
    ChangeSelectedVehicle event,
    Emitter<ReportsState> emit,
  ) async {
    // Reload current data with new vehicle
    final currentState = state;
    if (currentState is OverviewDataLoaded) {
      add(
        LoadOverviewData(
          vehicleId: event.vehicleId,
          startDate: currentState.startDate,
          endDate: currentState.endDate,
        ),
      );
    }
  }

  Future<List<Transaction>> _loadTransactions(
    String? vehicleId,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    if (vehicleId != null && startDate != null && endDate != null) {
      return await _getTransactionsByDateRange(startDate, endDate);
    } else if (vehicleId != null) {
      return await _getTransactionsByVehicle(vehicleId);
    } else {
      return await _getTransactions();
    }
  }

  Future<List<RefuelingEntry>> _loadRefuelingEntries(
    String? vehicleId,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    if (vehicleId != null && startDate != null && endDate != null) {
      return await _getRefuelingEntriesByDateRange(
        vehicleId: vehicleId,
        startDate: startDate,
        endDate: endDate,
      );
    } else if (vehicleId != null) {
      return await _getRefuelingEntriesByVehicle(vehicleId);
    } else {
      return await _getRefuelingEntries();
    }
  }

  Map<String, dynamic> _calculateOverviewData(
    List<Transaction> transactions,
    List<RefuelingEntry> refuelingEntries,
  ) {
    final totalCost = transactions.fold(0.0, (sum, t) => sum + (t.amount ?? 0));
    final totalRefuelings = refuelingEntries.length;
    final totalVolume = refuelingEntries.fold(
      0.0,
      (sum, r) => sum + r.volumeLiters,
    );
    final averageEfficiency = ChartDataUtils.calculateAverageFuelConsumption(
      refuelingEntries,
    );

    return {
      'totalCost': totalCost,
      'totalTransactions': transactions.length,
      'totalRefuelings': totalRefuelings,
      'totalVolume': totalVolume,
      'averageEfficiency': averageEfficiency,
      'costTrend': ChartDataUtils.getCostTrendSpots(transactions),
      'fuelConsumption': ChartDataUtils.getFuelConsumptionSpots(
        refuelingEntries,
      ),
    };
  }

  Map<String, dynamic> _calculateOdometerStatistics(
    List<RefuelingEntry> entries,
  ) {
    if (entries.isEmpty) {
      return {
        'totalDistance': 0.0,
        'averageDistance': 0.0,
        'odometerTrend': <FlSpot>[],
      };
    }

    final sortedEntries = List<RefuelingEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final totalDistance =
        sortedEntries.last.odometerKm - sortedEntries.first.odometerKm;
    final averageDistance = totalDistance / sortedEntries.length;

    return {
      'totalDistance': totalDistance.toDouble(),
      'averageDistance': averageDistance,
      'odometerTrend': ChartDataUtils.getOdometerTrend(entries),
    };
  }

  Map<String, dynamic> _calculateOwnershipData(
    List<Transaction> transactions,
    List<RefuelingEntry> refuelingEntries,
  ) {
    final totalCost = transactions.fold(0.0, (sum, t) => sum + (t.amount ?? 0));
    final totalRefuelingCost = refuelingEntries.fold(
      0.0,
      (sum, r) => sum + r.totalAmount,
    );
    final totalDistance = refuelingEntries.isNotEmpty
        ? refuelingEntries.last.odometerKm - refuelingEntries.first.odometerKm
        : 0;

    return {
      'totalCost': totalCost,
      'totalRefuelingCost': totalRefuelingCost,
      'totalDistance': totalDistance.toDouble(),
      'costPerKm': totalDistance > 0 ? totalCost / totalDistance : 0.0,
      'refuelingCostPerKm': totalDistance > 0
          ? totalRefuelingCost / totalDistance
          : 0.0,
    };
  }
}
