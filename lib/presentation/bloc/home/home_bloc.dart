import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/vehicle_usecases.dart' as vehicle_usecases;
import '../../../domain/usecases/transaction_usecases.dart'
    as transaction_usecases;
import '../../../domain/entities/transaction.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final vehicle_usecases.GetPrimaryVehicle _getPrimaryVehicle;
  final transaction_usecases.GetRecentTransactions _getRecentTransactions;
  final transaction_usecases.GetTransactionStatistics _getTransactionStatistics;
  final transaction_usecases.GetTransactionsByType _getTransactionsByType;

  HomeBloc({
    required vehicle_usecases.GetPrimaryVehicle getPrimaryVehicle,
    required transaction_usecases.GetRecentTransactions getRecentTransactions,
    required transaction_usecases.GetTransactionStatistics
    getTransactionStatistics,
    required transaction_usecases.GetTransactionsByType getTransactionsByType,
  }) : _getPrimaryVehicle = getPrimaryVehicle,
       _getRecentTransactions = getRecentTransactions,
       _getTransactionStatistics = getTransactionStatistics,
       _getTransactionsByType = getTransactionsByType,
       super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<LoadPrimaryVehicle>(_onLoadPrimaryVehicle);
    on<LoadRecentTransactions>(_onLoadRecentTransactions);
    on<LoadVehicleStatistics>(_onLoadVehicleStatistics);
    on<LoadUpcomingMaintenance>(_onLoadUpcomingMaintenance);
    on<LoadFuelConsumptionStats>(_onLoadFuelConsumptionStats);
    on<LoadMonthlyCosts>(_onLoadMonthlyCosts);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      // Load primary vehicle
      final primaryVehicle = await _getPrimaryVehicle();

      if (primaryVehicle == null) {
        // Load recent transactions even without primary vehicle
        final recentTransactions = await _getRecentTransactions(limit: 5);
        emit(HomeNoPrimaryVehicle(recentTransactions: recentTransactions));
        return;
      }

      // Load all home data for primary vehicle
      final recentTransactions = await _getRecentTransactions(
        limit: 100, // Show all for infinite scroll
        vehicleId: primaryVehicle.id,
      );
      final vehicleStats = await _getTransactionStatistics(
        vehicleId: primaryVehicle.id,
      );
      final upcomingMaintenance = await _getTransactionsByType(
        TransactionType.maintenance,
      );
      final fuelStats = await _getTransactionStatistics(
        vehicleId: primaryVehicle.id,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      );

      emit(
        HomeLoaded(
          primaryVehicle: primaryVehicle,
          recentTransactions: recentTransactions,
          vehicleStats: vehicleStats,
          upcomingMaintenance: upcomingMaintenance,
          fuelStats: fuelStats,
        ),
      );
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;

    // Emit refreshing state with current data
    if (currentState is HomeLoaded) {
      emit(
        HomeRefreshing(
          primaryVehicle: currentState.primaryVehicle,
          recentTransactions: currentState.recentTransactions,
          vehicleStats: currentState.vehicleStats,
          upcomingMaintenance: currentState.upcomingMaintenance,
          fuelStats: currentState.fuelStats,
          monthlyCosts: currentState.monthlyCosts,
        ),
      );
    } else if (currentState is HomeNoPrimaryVehicle) {
      emit(HomeRefreshing(recentTransactions: currentState.recentTransactions));
    }

    // Reload data
    add(LoadHomeData());
  }

  Future<void> _onLoadPrimaryVehicle(
    LoadPrimaryVehicle event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final primaryVehicle = await _getPrimaryVehicle();
      if (primaryVehicle == null) {
        emit(HomeNoPrimaryVehicle());
      } else {
        // Load additional data for the vehicle
        add(LoadVehicleStatistics(primaryVehicle.id));
      }
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onLoadRecentTransactions(
    LoadRecentTransactions event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // Get primary vehicle for filtering
      final primaryVehicle = await _getPrimaryVehicle();
      final recentTransactions = await _getRecentTransactions(
        limit: event.limit,
        vehicleId: primaryVehicle?.id,
      );

      final currentState = state;
      if (currentState is HomeLoaded) {
        emit(
          HomeLoaded(
            primaryVehicle: currentState.primaryVehicle,
            recentTransactions: recentTransactions,
            vehicleStats: currentState.vehicleStats,
            upcomingMaintenance: currentState.upcomingMaintenance,
            fuelStats: currentState.fuelStats,
            monthlyCosts: currentState.monthlyCosts,
          ),
        );
      } else if (currentState is HomeNoPrimaryVehicle) {
        emit(HomeNoPrimaryVehicle(recentTransactions: recentTransactions));
      }
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onLoadVehicleStatistics(
    LoadVehicleStatistics event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final vehicleStats = await _getTransactionStatistics(
        vehicleId: event.vehicleId,
      );

      final currentState = state;
      if (currentState is HomeLoaded) {
        emit(
          HomeLoaded(
            primaryVehicle: currentState.primaryVehicle,
            recentTransactions: currentState.recentTransactions,
            vehicleStats: vehicleStats,
            upcomingMaintenance: currentState.upcomingMaintenance,
            fuelStats: currentState.fuelStats,
            monthlyCosts: currentState.monthlyCosts,
          ),
        );
      }
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onLoadUpcomingMaintenance(
    LoadUpcomingMaintenance event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final upcomingMaintenance = await _getTransactionsByType(
        TransactionType.maintenance,
      );

      final currentState = state;
      if (currentState is HomeLoaded) {
        emit(
          HomeLoaded(
            primaryVehicle: currentState.primaryVehicle,
            recentTransactions: currentState.recentTransactions,
            vehicleStats: currentState.vehicleStats,
            upcomingMaintenance: upcomingMaintenance,
            fuelStats: currentState.fuelStats,
            monthlyCosts: currentState.monthlyCosts,
          ),
        );
      }
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onLoadFuelConsumptionStats(
    LoadFuelConsumptionStats event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final fuelStats = await _getTransactionStatistics(
        vehicleId: event.vehicleId,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      );

      final currentState = state;
      if (currentState is HomeLoaded) {
        emit(
          HomeLoaded(
            primaryVehicle: currentState.primaryVehicle,
            recentTransactions: currentState.recentTransactions,
            vehicleStats: currentState.vehicleStats,
            upcomingMaintenance: currentState.upcomingMaintenance,
            fuelStats: fuelStats,
            monthlyCosts: currentState.monthlyCosts,
          ),
        );
      }
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onLoadMonthlyCosts(
    LoadMonthlyCosts event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final startDate = DateTime(event.year, event.month, 1);
      final endDate = DateTime(event.year, event.month + 1, 0);

      final monthlyCosts = await _getTransactionStatistics(
        vehicleId: event.vehicleId,
        startDate: startDate,
        endDate: endDate,
      );

      final currentState = state;
      if (currentState is HomeLoaded) {
        emit(
          HomeLoaded(
            primaryVehicle: currentState.primaryVehicle,
            recentTransactions: currentState.recentTransactions,
            vehicleStats: currentState.vehicleStats,
            upcomingMaintenance: currentState.upcomingMaintenance,
            fuelStats: currentState.fuelStats,
            monthlyCosts: monthlyCosts,
          ),
        );
      }
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
