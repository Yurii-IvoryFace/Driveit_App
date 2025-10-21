import '../../../domain/entities/transaction.dart';

/// Base class for all transaction events
abstract class TransactionEvent {}

/// Event to load all transactions
class LoadTransactions extends TransactionEvent {}

/// Event to load transactions by vehicle
class LoadTransactionsByVehicle extends TransactionEvent {
  final String vehicleId;

  LoadTransactionsByVehicle(this.vehicleId);
}

/// Event to load transactions by type
class LoadTransactionsByType extends TransactionEvent {
  final TransactionType type;

  LoadTransactionsByType(this.type);
}

/// Event to load transactions by date range
class LoadTransactionsByDateRange extends TransactionEvent {
  final DateTime startDate;
  final DateTime endDate;

  LoadTransactionsByDateRange(this.startDate, this.endDate);
}

/// Event to load transactions with filters
class LoadTransactionsWithFilters extends TransactionEvent {
  final String? vehicleId;
  final TransactionType? type;
  final DateTime? startDate;
  final DateTime? endDate;

  LoadTransactionsWithFilters({
    this.vehicleId,
    this.type,
    this.startDate,
    this.endDate,
  });
}

/// Event to add a new transaction
class AddTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  AddTransactionEvent(this.transaction);
}

/// Event to update an existing transaction
class UpdateTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  UpdateTransactionEvent(this.transaction);
}

/// Event to delete a transaction
class DeleteTransactionEvent extends TransactionEvent {
  final String transactionId;

  DeleteTransactionEvent(this.transactionId);
}

/// Event to load a single transaction
class LoadTransactionEvent extends TransactionEvent {
  final String transactionId;

  LoadTransactionEvent(this.transactionId);
}

/// Event to load transaction statistics
class LoadTransactionStatisticsEvent extends TransactionEvent {
  final String? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  LoadTransactionStatisticsEvent({
    this.vehicleId,
    this.startDate,
    this.endDate,
  });
}

/// Event to load recent transactions
class LoadRecentTransactionsEvent extends TransactionEvent {
  final int limit;

  LoadRecentTransactionsEvent({this.limit = 10});
}

/// Event to load transactions by odometer range
class LoadTransactionsByOdometerRangeEvent extends TransactionEvent {
  final String vehicleId;
  final int minOdometer;
  final int maxOdometer;

  LoadTransactionsByOdometerRangeEvent({
    required this.vehicleId,
    required this.minOdometer,
    required this.maxOdometer,
  });
}

/// Event to refresh transactions
class RefreshTransactions extends TransactionEvent {}

/// Event to clear transaction filters
class ClearTransactionFilters extends TransactionEvent {}
