import 'package:flutter_bloc/flutter_bloc.dart';

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

  // Cache for loaded data
  Map<String, dynamic>? _cachedCostsData;
  Map<String, dynamic>? _cachedFuelData;
  DateTime? _lastCacheTime;

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
    // Check cache first
    if (_cachedFuelData != null &&
        _lastCacheTime != null &&
        DateTime.now().difference(_lastCacheTime!).inMinutes < 5) {
      emit(
        FuelDataLoaded(
          refuelingEntries: _cachedFuelData!['refuelingEntries'] ?? [],
          fuelStatistics: _cachedFuelData!['fuelStatistics'] ?? {},
          vehicleId: event.vehicleId,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );
      return;
    }

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

      // Cache the data
      _cachedFuelData = {
        'refuelingEntries': refuelingEntries,
        'fuelStatistics': fuelStatistics,
      };
      _lastCacheTime = DateTime.now();

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
    // Check cache first
    if (_cachedCostsData != null &&
        _lastCacheTime != null &&
        DateTime.now().difference(_lastCacheTime!).inMinutes < 5) {
      emit(
        CostsDataLoaded(
          transactions: _cachedCostsData!['transactions'] ?? [],
          costStatistics: _cachedCostsData!['costStatistics'] ?? {},
          vehicleId: event.vehicleId,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );
      return;
    }

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

      // Cache the data
      _cachedCostsData = {
        'transactions': transactions,
        'costStatistics': costStatistics,
      };
      _lastCacheTime = DateTime.now();

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
      final transactions = await _loadTransactions(
        event.vehicleId,
        event.startDate,
        event.endDate,
      );
      final odometerStatistics = _calculateOdometerStatisticsFromTransactions(
        transactions,
      );

      emit(
        OdometerDataLoaded(
          odometerEntries: transactions,
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
    // Clear cache
    _cachedCostsData = null;
    _cachedFuelData = null;
    _lastCacheTime = null;

    // Load all data for all tabs
    add(
      LoadOverviewData(
        vehicleId: event.vehicleId,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );
    add(
      LoadFuelData(
        vehicleId: event.vehicleId,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );
    add(
      LoadCostsData(
        vehicleId: event.vehicleId,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );
    add(
      LoadOdometerData(
        vehicleId: event.vehicleId,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );
    add(
      LoadOwnershipData(
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
    if (vehicleId != null) {
      // Filter by vehicle, optionally with date range
      final transactions = await _getTransactionsByVehicle(vehicleId);
      if (startDate != null && endDate != null) {
        return transactions
            .where(
              (t) => !t.date.isBefore(startDate) && !t.date.isAfter(endDate),
            )
            .toList();
      }
      return transactions;
    } else if (startDate != null && endDate != null) {
      return await _getTransactionsByDateRange(startDate, endDate);
    } else {
      return await _getTransactions();
    }
  }

  Future<List<RefuelingEntry>> _loadRefuelingEntries(
    String? vehicleId,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    if (vehicleId != null) {
      // Filter by vehicle, optionally with date range
      final refuelingEntries = await _getRefuelingEntriesByVehicle(vehicleId);
      if (startDate != null && endDate != null) {
        return refuelingEntries
            .where(
              (r) => !r.date.isBefore(startDate) && !r.date.isAfter(endDate),
            )
            .toList();
      }
      return refuelingEntries;
    } else if (startDate != null && endDate != null) {
      return await _getRefuelingEntriesByDateRange(
        vehicleId: '',
        startDate: startDate,
        endDate: endDate,
      );
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
      'transactions': transactions,
      'refuelingEntries': refuelingEntries,
    };
  }

  Map<String, dynamic> _calculateOdometerStatisticsFromTransactions(
    List<Transaction> transactions,
  ) {
    // Filter transactions that have odometer readings
    final odometerTransactions = transactions
        .where((t) => t.odometerKm != null)
        .toList();

    if (odometerTransactions.isEmpty) {
      return {
        'totalDistance': 0.0,
        'averageDistance': 0.0,
        'totalRefuelings': 0,
        'entries': [],
      };
    }

    final sortedTransactions = List<Transaction>.from(odometerTransactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    final totalDistance =
        sortedTransactions.last.odometerKm! -
        sortedTransactions.first.odometerKm!;
    final averageDistance = totalDistance / sortedTransactions.length;

    // Count refueling transactions
    final refuelingCount = odometerTransactions
        .where((t) => t.type == TransactionType.refueling)
        .length;

    return {
      'totalDistance': totalDistance.toDouble(),
      'averageDistance': averageDistance.toDouble(),
      'totalRefuelings': refuelingCount,
      'entries': sortedTransactions,
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

    // Calculate total distance from all transactions with odometer readings
    final odometerTransactions = transactions
        .where((t) => t.odometerKm != null)
        .toList();

    double totalDistance = 0.0;
    if (odometerTransactions.isNotEmpty) {
      final sortedTransactions = List<Transaction>.from(odometerTransactions)
        ..sort((a, b) => a.date.compareTo(b.date));

      totalDistance =
          (sortedTransactions.last.odometerKm! -
                  sortedTransactions.first.odometerKm!)
              .toDouble();
    }

    return {
      'totalCost': totalCost,
      'totalRefuelingCost': totalRefuelingCost,
      'totalDistance': totalDistance,
      'costPerKm': totalDistance > 0 ? totalCost / totalDistance : 0.0,
      'refuelingCostPerKm': totalDistance > 0
          ? totalRefuelingCost / totalDistance
          : 0.0,
      'transactions': transactions,
    };
  }
}
