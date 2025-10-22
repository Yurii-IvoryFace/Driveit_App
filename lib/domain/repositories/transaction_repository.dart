import '../entities/transaction.dart';
import '../entities/attachment.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions();
  Future<Transaction?> getTransaction(String id);
  Future<void> saveTransaction(Transaction transaction);
  Future<void> addTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  Stream<List<Transaction>> watchTransactions();
  Future<List<Transaction>> getTransactionsByVehicle(String vehicleId);
  Stream<List<Transaction>> watchTransactionsByVehicle(String vehicleId);
  Future<List<Transaction>> getTransactionsByType(TransactionType type);
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<List<Transaction>> getTransactionsWithFilters({
    String? vehicleId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<Transaction>> getRecentTransactions(
    int limit, {
    String? vehicleId,
  });
  Future<List<Transaction>> getTransactionsByOdometerRange({
    required String vehicleId,
    required int minOdometer,
    required int maxOdometer,
  });
  Future<Map<String, dynamic>> getTransactionStatistics({
    String? vehicleId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<Transaction>> getTransactionsByVehicleAndDateRange(
    String vehicleId,
    DateTime start,
    DateTime end,
  );
  Future<List<Transaction>> getRefuelingTransactions(String vehicleId);
  Future<List<Transaction>> getExpenseTransactions(String vehicleId);
  Future<List<Transaction>> getServiceTransactions(String vehicleId);
  Future<TransactionWithAttachments?> getTransactionWithAttachments(String id);
  Future<List<FuelConsumptionData>> getFuelConsumptionStats(String vehicleId);
  Future<List<MonthlyCostData>> getMonthlyCostSummary(
    String vehicleId,
    int year,
  );
}

class TransactionWithAttachments {
  final Transaction transaction;
  final List<Attachment> attachments;

  TransactionWithAttachments({
    required this.transaction,
    required this.attachments,
  });
}

class FuelConsumptionData {
  final DateTime date;
  final double consumption; // L/100km
  final double distance; // km
  final double volume; // L
  final double? pricePerLiter;

  FuelConsumptionData({
    required this.date,
    required this.consumption,
    required this.distance,
    required this.volume,
    this.pricePerLiter,
  });
}

class MonthlyCostData {
  final int month;
  final double totalCost;
  final double fuelCost;
  final double maintenanceCost;
  final double otherCost;

  MonthlyCostData({
    required this.month,
    required this.totalCost,
    required this.fuelCost,
    required this.maintenanceCost,
    required this.otherCost,
  });
}
