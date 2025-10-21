import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Use case for getting all transactions
class GetTransactions {
  final TransactionRepository _repository;

  GetTransactions(this._repository);

  Future<List<Transaction>> call() async {
    return await _repository.getTransactions();
  }
}

/// Use case for watching transactions stream
class WatchTransactions {
  final TransactionRepository _repository;

  WatchTransactions(this._repository);

  Stream<List<Transaction>> call() {
    return _repository.watchTransactions();
  }
}

/// Use case for getting transactions by vehicle
class GetTransactionsByVehicle {
  final TransactionRepository _repository;

  GetTransactionsByVehicle(this._repository);

  Future<List<Transaction>> call(String vehicleId) async {
    return await _repository.getTransactionsByVehicle(vehicleId);
  }
}

/// Use case for watching transactions by vehicle
class WatchTransactionsByVehicle {
  final TransactionRepository _repository;

  WatchTransactionsByVehicle(this._repository);

  Stream<List<Transaction>> call(String vehicleId) {
    return _repository.watchTransactionsByVehicle(vehicleId);
  }
}

/// Use case for getting transactions by type
class GetTransactionsByType {
  final TransactionRepository _repository;

  GetTransactionsByType(this._repository);

  Future<List<Transaction>> call(TransactionType type) async {
    return await _repository.getTransactionsByType(type);
  }
}

/// Use case for getting transactions by date range
class GetTransactionsByDateRange {
  final TransactionRepository _repository;

  GetTransactionsByDateRange(this._repository);

  Future<List<Transaction>> call(DateTime startDate, DateTime endDate) async {
    return await _repository.getTransactionsByDateRange(startDate, endDate);
  }
}

/// Use case for getting transactions with filters
class GetTransactionsWithFilters {
  final TransactionRepository _repository;

  GetTransactionsWithFilters(this._repository);

  Future<List<Transaction>> call({
    String? vehicleId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getTransactionsWithFilters(
      vehicleId: vehicleId,
      type: type,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

/// Use case for adding a transaction
class AddTransaction {
  final TransactionRepository _repository;

  AddTransaction(this._repository);

  Future<void> call(Transaction transaction) async {
    return await _repository.addTransaction(transaction);
  }
}

/// Use case for updating a transaction
class UpdateTransaction {
  final TransactionRepository _repository;

  UpdateTransaction(this._repository);

  Future<void> call(Transaction transaction) async {
    return await _repository.updateTransaction(transaction);
  }
}

/// Use case for deleting a transaction
class DeleteTransaction {
  final TransactionRepository _repository;

  DeleteTransaction(this._repository);

  Future<void> call(String transactionId) async {
    return await _repository.deleteTransaction(transactionId);
  }
}

/// Use case for getting a single transaction
class GetTransaction {
  final TransactionRepository _repository;

  GetTransaction(this._repository);

  Future<Transaction?> call(String transactionId) async {
    return await _repository.getTransaction(transactionId);
  }
}

/// Use case for getting transaction statistics
class GetTransactionStatistics {
  final TransactionRepository _repository;

  GetTransactionStatistics(this._repository);

  Future<Map<String, dynamic>> call({
    String? vehicleId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getTransactionStatistics(
      vehicleId: vehicleId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

/// Use case for getting recent transactions
class GetRecentTransactions {
  final TransactionRepository _repository;

  GetRecentTransactions(this._repository);

  Future<List<Transaction>> call({int limit = 10}) async {
    return await _repository.getRecentTransactions(limit);
  }
}

/// Use case for getting transactions by odometer range
class GetTransactionsByOdometerRange {
  final TransactionRepository _repository;

  GetTransactionsByOdometerRange(this._repository);

  Future<List<Transaction>> call({
    required String vehicleId,
    required int minOdometer,
    required int maxOdometer,
  }) async {
    return await _repository.getTransactionsByOdometerRange(
      vehicleId: vehicleId,
      minOdometer: minOdometer,
      maxOdometer: maxOdometer,
    );
  }
}
