import '../datasources/local/app_database.dart';
import '../datasources/local/daos/transaction_dao.dart';
import '../../domain/entities/transaction.dart' as domain;
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/entities/attachment.dart' as domain_attachment;

class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase _database;
  late final TransactionDao _transactionDao;

  TransactionRepositoryImpl(this._database) {
    _transactionDao = _database.transactionDao;
  }

  @override
  Future<List<domain.Transaction>> getTransactions() async {
    final transactions = await _transactionDao.getAll();
    return transactions.map(_mapToEntity).toList();
  }

  @override
  Future<domain.Transaction?> getTransaction(String id) async {
    final transaction = await _transactionDao.getById(id);
    return transaction != null ? _mapToEntity(transaction) : null;
  }

  @override
  Future<void> saveTransaction(domain.Transaction transaction) async {
    final transactionData = _mapToData(transaction);
    await _transactionDao.insert(transactionData);
  }

  @override
  Future<void> addTransaction(domain.Transaction transaction) async {
    final transactionData = _mapToData(transaction);
    await _transactionDao.insert(transactionData);
  }

  @override
  Future<void> updateTransaction(domain.Transaction transaction) async {
    final transactionData = _mapToData(transaction);
    await _transactionDao.updateTransaction(transactionData);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _transactionDao.deleteTransaction(id);
  }

  @override
  Stream<List<domain.Transaction>> watchTransactions() async* {
    await for (final transactions in _transactionDao.watchAll()) {
      yield transactions.map(_mapToEntity).toList();
    }
  }

  @override
  Future<List<domain.Transaction>> getTransactionsByVehicle(
    String vehicleId,
  ) async {
    final transactions = await _transactionDao.getByVehicleId(vehicleId);
    return transactions.map(_mapToEntity).toList();
  }

  @override
  Stream<List<domain.Transaction>> watchTransactionsByVehicle(
    String vehicleId,
  ) async* {
    await for (final transactions in _transactionDao.watchByVehicleId(
      vehicleId,
    )) {
      yield transactions.map(_mapToEntity).toList();
    }
  }

  @override
  Future<List<domain.Transaction>> getTransactionsByType(
    domain.TransactionType type,
  ) async {
    final transactions = await _transactionDao.getByType(type.name);
    return transactions.map(_mapToEntity).toList();
  }

  @override
  Future<List<domain.Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final transactions = await _transactionDao.getByDateRange(start, end);
    return transactions.map(_mapToEntity).toList();
  }

  @override
  Future<List<domain.Transaction>> getTransactionsByVehicleAndDateRange(
    String vehicleId,
    DateTime start,
    DateTime end,
  ) async {
    final transactions = await _transactionDao.getByVehicleAndDateRange(
      vehicleId,
      start,
      end,
    );
    return transactions.map(_mapToEntity).toList();
  }

  @override
  Future<List<domain.Transaction>> getRefuelingTransactions(
    String vehicleId,
  ) async {
    final transactions = await _transactionDao.getRefuelingTransactions(
      vehicleId,
    );
    return transactions.map(_mapToEntity).toList();
  }

  @override
  Future<List<domain.Transaction>> getExpenseTransactions(
    String vehicleId,
  ) async {
    final transactions = await _transactionDao.getExpenseTransactions(
      vehicleId,
    );
    return transactions.map(_mapToEntity).toList();
  }

  @override
  Future<List<domain.Transaction>> getServiceTransactions(
    String vehicleId,
  ) async {
    final transactions = await _transactionDao.getServiceTransactions(
      vehicleId,
    );
    return transactions.map(_mapToEntity).toList();
  }

  @override
  Future<TransactionWithAttachments?> getTransactionWithAttachments(
    String id,
  ) async {
    final result = await _transactionDao.getWithAttachments(id);
    if (result == null) return null;

    return TransactionWithAttachments(
      transaction: _mapToEntity(result['transaction'] as Transaction),
      attachments: (result['attachments'] as List<Attachment>)
          .map(_mapAttachmentToEntity)
          .toList(),
    );
  }

  @override
  Future<List<FuelConsumptionData>> getFuelConsumptionStats(
    String vehicleId,
  ) async {
    final data = await _transactionDao.getFuelConsumptionStats(vehicleId);
    return data
        .map(
          (d) => FuelConsumptionData(
            date: d['date'] as DateTime,
            consumption: d['consumption'] as double,
            distance: d['distance'] as double,
            volume: d['volume'] as double,
            pricePerLiter: d['pricePerLiter'] as double?,
          ),
        )
        .toList();
  }

  @override
  Future<List<MonthlyCostData>> getMonthlyCostSummary(
    String vehicleId,
    int year,
  ) async {
    final data = await _transactionDao.getMonthlyCostSummary(vehicleId, year);
    return data
        .map(
          (d) => MonthlyCostData(
            month: d['month'] as int,
            totalCost: d['totalCost'] as double,
            fuelCost: d['fuelCost'] as double,
            maintenanceCost: d['maintenanceCost'] as double,
            otherCost: d['otherCost'] as double,
          ),
        )
        .toList();
  }

  // Mapping methods
  domain.Transaction _mapToEntity(Transaction data) {
    return domain.Transaction(
      id: data.id,
      vehicleId: data.vehicleId,
      type: _mapTransactionType(data.type),
      date: data.date,
      amount: data.amount,
      currency: data.currency,
      odometerKm: data.odometerKm,
      volumeLiters: data.volumeLiters,
      pricePerLiter: data.pricePerLiter,
      fuelType: data.fuelType,
      isFullTank: data.isFullTank,
      serviceType: data.serviceType,
      serviceProvider: data.serviceProvider,
      notes: data.notes,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  Transaction _mapToData(domain.Transaction entity) {
    return Transaction(
      id: entity.id,
      vehicleId: entity.vehicleId,
      type: entity.type.name,
      date: entity.date,
      amount: entity.amount,
      currency: entity.currency,
      odometerKm: entity.odometerKm,
      volumeLiters: entity.volumeLiters,
      pricePerLiter: entity.pricePerLiter,
      fuelType: entity.fuelType,
      isFullTank: entity.isFullTank,
      serviceType: entity.serviceType,
      serviceProvider: entity.serviceProvider,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  Future<List<domain.Transaction>> getTransactionsWithFilters({
    String? vehicleId,
    domain.TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // For now, implement basic filtering
    // TODO: Implement proper filtering in DAO
    final allTransactions = await getTransactions();
    return allTransactions.where((transaction) {
      if (vehicleId != null && transaction.vehicleId != vehicleId) return false;
      if (type != null && transaction.type != type) return false;
      if (startDate != null && transaction.date.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && transaction.date.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  @override
  Future<List<domain.Transaction>> getRecentTransactions(
    int limit, {
    String? vehicleId,
  }) async {
    final transactions = vehicleId != null
        ? await getTransactionsByVehicle(vehicleId)
        : await getTransactions();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions.take(limit).toList();
  }

  @override
  Future<List<domain.Transaction>> getTransactionsByOdometerRange({
    required String vehicleId,
    required int minOdometer,
    required int maxOdometer,
  }) async {
    final transactions = await getTransactionsByVehicle(vehicleId);
    return transactions.where((transaction) {
      if (transaction.odometerKm == null) return false;
      return transaction.odometerKm! >= minOdometer &&
          transaction.odometerKm! <= maxOdometer;
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> getTransactionStatistics({
    String? vehicleId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final transactions = await getTransactionsWithFilters(
      vehicleId: vehicleId,
      startDate: startDate,
      endDate: endDate,
    );

    double totalAmount = 0;
    int transactionCount = transactions.length;
    Map<domain.TransactionType, int> typeCounts = {};
    Map<domain.TransactionType, double> typeAmounts = {};

    // Calculate total distance from odometer readings
    double totalDistance = 0.0;
    List<int> odometerReadings = [];

    for (final transaction in transactions) {
      if (transaction.amount != null) {
        totalAmount += transaction.amount!;
        typeCounts[transaction.type] = (typeCounts[transaction.type] ?? 0) + 1;
        typeAmounts[transaction.type] =
            (typeAmounts[transaction.type] ?? 0) + transaction.amount!;
      }

      if (transaction.odometerKm != null) {
        odometerReadings.add(transaction.odometerKm!);
      }
    }

    // Calculate total distance
    if (odometerReadings.isNotEmpty) {
      odometerReadings.sort();
      totalDistance = (odometerReadings.last - odometerReadings.first)
          .toDouble();
    }

    // Calculate fuel efficiency from refueling transactions
    double averageFuelEfficiency = 0.0;
    final refuelingTransactions = transactions
        .where(
          (t) =>
              t.type == domain.TransactionType.refueling &&
              t.odometerKm != null,
        )
        .toList();

    if (refuelingTransactions.length >= 2) {
      refuelingTransactions.sort((a, b) => a.date.compareTo(b.date));

      double totalEfficiency = 0.0;
      int efficiencyCount = 0;

      for (int i = 0; i < refuelingTransactions.length - 1; i++) {
        final current = refuelingTransactions[i];
        final next = refuelingTransactions[i + 1];

        if (current.odometerKm != null &&
            next.odometerKm != null &&
            current.volumeLiters != null &&
            next.odometerKm! > current.odometerKm!) {
          final distance = next.odometerKm! - current.odometerKm!;
          final fuelUsed = current.volumeLiters!;

          if (distance > 0 && fuelUsed > 0) {
            final efficiency = (fuelUsed / distance) * 100;
            totalEfficiency += efficiency;
            efficiencyCount++;
          }
        }
      }

      if (efficiencyCount > 0) {
        averageFuelEfficiency = totalEfficiency / efficiencyCount;
      }
    }

    return {
      'totalAmount': totalAmount,
      'transactionCount': transactionCount,
      'totalDistance': totalDistance,
      'averageFuelEfficiency': averageFuelEfficiency,
      'typeCounts': typeCounts.map((k, v) => MapEntry(k.name, v)),
      'typeAmounts': typeAmounts.map((k, v) => MapEntry(k.name, v)),
      'averageAmount': transactionCount > 0
          ? totalAmount / transactionCount
          : 0,
    };
  }

  domain.TransactionType _mapTransactionType(String type) {
    switch (type) {
      case 'refueling':
        return domain.TransactionType.refueling;
      case 'maintenance':
        return domain.TransactionType.maintenance;
      case 'insurance':
        return domain.TransactionType.insurance;
      case 'parking':
        return domain.TransactionType.parking;
      case 'toll':
        return domain.TransactionType.toll;
      case 'carWash':
        return domain.TransactionType.carWash;
      case 'other':
        return domain.TransactionType.other;
      default:
        return domain.TransactionType.other;
    }
  }

  domain_attachment.Attachment _mapAttachmentToEntity(Attachment data) {
    return domain_attachment.Attachment(
      id: data.id,
      transactionId: data.transactionId,
      vehicleId: data.vehicleId,
      type: data.type,
      name: data.name,
      filePath: data.filePath,
      fileSizeBytes: data.fileSizeBytes,
      mimeType: data.mimeType,
      createdAt: data.createdAt,
    );
  }
}
