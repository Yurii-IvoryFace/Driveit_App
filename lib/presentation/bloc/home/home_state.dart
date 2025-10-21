import '../../../domain/entities/vehicle.dart';
import '../../../domain/entities/transaction.dart';

/// Base class for all home states
abstract class HomeState {}

/// Initial state
class HomeInitial extends HomeState {}

/// Loading state
class HomeLoading extends HomeState {}

/// State when home data is loaded successfully
class HomeLoaded extends HomeState {
  final Vehicle? primaryVehicle;
  final List<Transaction> recentTransactions;
  final Map<String, dynamic>? vehicleStats;
  final List<Transaction> upcomingMaintenance;
  final Map<String, dynamic>? fuelStats;
  final Map<String, dynamic>? monthlyCosts;

  HomeLoaded({
    this.primaryVehicle,
    this.recentTransactions = const [],
    this.vehicleStats,
    this.upcomingMaintenance = const [],
    this.fuelStats,
    this.monthlyCosts,
  });
}

/// State when no primary vehicle is set
class HomeNoPrimaryVehicle extends HomeState {
  final List<Transaction> recentTransactions;

  HomeNoPrimaryVehicle({this.recentTransactions = const []});
}

/// State when home data is refreshing
class HomeRefreshing extends HomeState {
  final Vehicle? primaryVehicle;
  final List<Transaction> recentTransactions;
  final Map<String, dynamic>? vehicleStats;
  final List<Transaction> upcomingMaintenance;
  final Map<String, dynamic>? fuelStats;
  final Map<String, dynamic>? monthlyCosts;

  HomeRefreshing({
    this.primaryVehicle,
    this.recentTransactions = const [],
    this.vehicleStats,
    this.upcomingMaintenance = const [],
    this.fuelStats,
    this.monthlyCosts,
  });
}

/// Error state
class HomeError extends HomeState {
  final String message;
  final Vehicle? primaryVehicle;
  final List<Transaction> recentTransactions;

  HomeError({
    required this.message,
    this.primaryVehicle,
    this.recentTransactions = const [],
  });
}

/// Empty state (no data available)
class HomeEmpty extends HomeState {
  final String message;

  HomeEmpty({this.message = 'No data available'});
}
