import '../../../domain/entities/transaction.dart';

/// Base class for all transaction states
abstract class TransactionState {}

/// Initial state
class TransactionInitial extends TransactionState {}

/// Loading state
class TransactionLoading extends TransactionState {}

/// State when transactions are loaded successfully
class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final Map<String, dynamic>? statistics;
  final String? message;

  TransactionLoaded({
    required this.transactions,
    this.statistics,
    this.message,
  });
}

/// State when a single transaction is loaded
class TransactionDetailLoaded extends TransactionState {
  final Transaction transaction;

  TransactionDetailLoaded(this.transaction);
}

/// State when transaction statistics are loaded
class TransactionStatisticsLoaded extends TransactionState {
  final Map<String, dynamic> statistics;

  TransactionStatisticsLoaded(this.statistics);
}

/// State when recent transactions are loaded
class RecentTransactionsLoaded extends TransactionState {
  final List<Transaction> transactions;

  RecentTransactionsLoaded(this.transactions);
}

/// State when transactions are filtered
class TransactionFiltered extends TransactionState {
  final List<Transaction> transactions;
  final String? vehicleId;
  final TransactionType? type;
  final DateTime? startDate;
  final DateTime? endDate;

  TransactionFiltered({
    required this.transactions,
    this.vehicleId,
    this.type,
    this.startDate,
    this.endDate,
  });
}

/// State when transaction operation is in progress
class TransactionOperationInProgress extends TransactionState {
  final String operation;
  final String? transactionId;

  TransactionOperationInProgress({required this.operation, this.transactionId});
}

/// State when transaction operation is successful
class TransactionOperationSuccess extends TransactionState {
  final String operation;
  final String message;
  final Transaction? transaction;

  TransactionOperationSuccess({
    required this.operation,
    required this.message,
    this.transaction,
  });
}

/// Error state
class TransactionError extends TransactionState {
  final String message;
  final String? operation;

  TransactionError({required this.message, this.operation});
}

/// Empty state (no transactions found)
class TransactionEmpty extends TransactionState {
  final String message;

  TransactionEmpty({this.message = 'No transactions found'});
}
