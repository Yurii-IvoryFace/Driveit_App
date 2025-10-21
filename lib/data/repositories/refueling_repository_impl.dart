import '../datasources/local/app_database.dart';
import '../datasources/local/daos/transaction_dao.dart';
import '../../domain/entities/refueling_entry.dart';
import '../../domain/entities/refueling_summary.dart';
import '../../domain/entities/fuel_type.dart';
import '../../domain/repositories/refueling_repository.dart';

class RefuelingRepositoryImpl implements RefuelingRepository {
  final AppDatabase _database;
  late final TransactionDao _transactionDao;

  RefuelingRepositoryImpl(this._database) {
    _transactionDao = _database.transactionDao;
  }

  @override
  Future<List<RefuelingEntry>> getRefuelingEntries() async {
    final transactions = await _transactionDao.getRefuelingTransactions('');
    return transactions.map(_mapToRefuelingEntry).toList();
  }

  @override
  Future<RefuelingEntry?> getRefuelingEntry(String id) async {
    final transaction = await _transactionDao.getById(id);
    if (transaction == null || transaction.type != 'refueling') {
      return null;
    }
    return _mapToRefuelingEntry(transaction);
  }

  @override
  Future<void> addRefuelingEntry(RefuelingEntry entry) async {
    final transaction = _mapToTransaction(entry);
    await _transactionDao.insert(transaction);
  }

  @override
  Future<void> updateRefuelingEntry(RefuelingEntry entry) async {
    final transaction = _mapToTransaction(entry);
    await _transactionDao.updateTransaction(transaction);
  }

  @override
  Future<void> deleteRefuelingEntry(String id) async {
    await _transactionDao.deleteTransaction(id);
  }

  @override
  Stream<List<RefuelingEntry>> watchRefuelingEntries() async* {
    await for (final transactions in _transactionDao.watchAll()) {
      final refuelingTransactions = transactions
          .where((t) => t.type == 'refueling')
          .map(_mapToRefuelingEntry)
          .toList();
      yield refuelingTransactions;
    }
  }

  @override
  Future<List<RefuelingEntry>> getRefuelingEntriesByVehicle(
    String vehicleId,
  ) async {
    final transactions = await _transactionDao.getRefuelingTransactions(
      vehicleId,
    );
    return transactions.map(_mapToRefuelingEntry).toList();
  }

  @override
  Stream<List<RefuelingEntry>> watchRefuelingEntriesByVehicle(
    String vehicleId,
  ) async* {
    await for (final transactions in _transactionDao.watchByVehicleId(
      vehicleId,
    )) {
      final refuelingTransactions = transactions
          .where((t) => t.type == 'refueling')
          .map(_mapToRefuelingEntry)
          .toList();
      yield refuelingTransactions;
    }
  }

  @override
  Future<List<RefuelingEntry>> getRefuelingEntriesByDateRange({
    required String vehicleId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final transactions = await _transactionDao.getByVehicleAndDateRange(
      vehicleId,
      startDate,
      endDate,
    );
    return transactions
        .where((t) => t.type == 'refueling')
        .map(_mapToRefuelingEntry)
        .toList();
  }

  @override
  Future<List<RefuelingEntry>> getRecentRefuelingEntries({
    required String vehicleId,
    int limit = 10,
  }) async {
    final transactions = await _transactionDao.getRefuelingTransactions(
      vehicleId,
    );
    return transactions.take(limit).map(_mapToRefuelingEntry).toList();
  }

  @override
  Future<RefuelingSummary> getRefuelingSummary(String vehicleId) async {
    final transactions = await _transactionDao.getRefuelingTransactions(
      vehicleId,
    );

    if (transactions.isEmpty) {
      return RefuelingSummary(
        vehicleId: vehicleId,
        totalRefuelings: 0,
        totalVolumeLiters: 0.0,
        totalAmount: 0.0,
        currency: '₴',
        averagePricePerLiter: 0.0,
        averageVolumePerRefueling: 0.0,
        averageAmountPerRefueling: 0.0,
        fuelEfficiency: 0.0,
        totalDistanceKm: 0.0,
        lastRefuelingDate: null,
        averageEfficiency: 0.0,
      );
    }

    final totalRefuelings = transactions.length;
    final totalVolumeLiters = transactions
        .where((t) => t.volumeLiters != null)
        .fold(0.0, (sum, t) => sum + (t.volumeLiters ?? 0.0));

    final totalAmount = transactions
        .where((t) => t.amount != null)
        .fold(0.0, (sum, t) => sum + (t.amount ?? 0.0));

    final averagePricePerLiter = totalVolumeLiters > 0
        ? totalAmount / totalVolumeLiters
        : 0.0;

    final averageVolumePerRefueling = totalRefuelings > 0
        ? totalVolumeLiters / totalRefuelings
        : 0.0;

    final averageAmountPerRefueling = totalRefuelings > 0
        ? totalAmount / totalRefuelings
        : 0.0;

    final lastRefuelingDate = transactions.isNotEmpty
        ? transactions.first.date
        : null;

    // Calculate fuel efficiency (simplified - would need odometer data)
    final fuelEfficiency = await _calculateFuelEfficiency(vehicleId);
    final totalDistanceKm = await _calculateTotalDistance(vehicleId);

    return RefuelingSummary(
      vehicleId: vehicleId,
      totalRefuelings: totalRefuelings,
      totalVolumeLiters: totalVolumeLiters,
      totalAmount: totalAmount,
      currency: '₴',
      averagePricePerLiter: averagePricePerLiter,
      averageVolumePerRefueling: averageVolumePerRefueling,
      averageAmountPerRefueling: averageAmountPerRefueling,
      fuelEfficiency: fuelEfficiency,
      totalDistanceKm: totalDistanceKm,
      lastRefuelingDate: lastRefuelingDate,
      averageEfficiency: fuelEfficiency,
    );
  }

  @override
  Future<double> calculateFuelEfficiency({
    required String vehicleId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _calculateFuelEfficiency(vehicleId, startDate, endDate);
  }

  @override
  Future<Map<String, dynamic>> getRefuelingStatistics({
    required String vehicleId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final transactions = startDate != null && endDate != null
        ? await getRefuelingEntriesByDateRange(
            vehicleId: vehicleId,
            startDate: startDate,
            endDate: endDate,
          )
        : await getRefuelingEntriesByVehicle(vehicleId);

    if (transactions.isEmpty) {
      return {
        'totalRefuelings': 0,
        'totalVolume': 0.0,
        'totalCost': 0.0,
        'averagePricePerLiter': 0.0,
        'averageVolumePerRefueling': 0.0,
        'fuelEfficiency': 0.0,
        'monthlyBreakdown': <String, dynamic>{},
        'fuelTypeBreakdown': <String, int>{},
      };
    }

    final totalRefuelings = transactions.length;
    final totalVolume = transactions
        .where((e) => e.volumeLiters != null)
        .fold(0.0, (sum, e) => sum + (e.volumeLiters ?? 0.0));

    final totalCost = transactions
        .where((e) => e.totalAmount != null)
        .fold(0.0, (sum, e) => sum + (e.totalAmount ?? 0.0));

    final averagePricePerLiter = totalVolume > 0
        ? totalCost / totalVolume
        : 0.0;

    final averageVolumePerRefueling = totalRefuelings > 0
        ? totalVolume / totalRefuelings
        : 0.0;

    // Monthly breakdown
    final monthlyBreakdown = <String, dynamic>{};
    for (final entry in transactions) {
      final monthKey =
          '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}';
      if (!monthlyBreakdown.containsKey(monthKey)) {
        monthlyBreakdown[monthKey] = {
          'refuelings': 0,
          'volume': 0.0,
          'cost': 0.0,
        };
      }
      monthlyBreakdown[monthKey]['refuelings']++;
      monthlyBreakdown[monthKey]['volume'] += entry.volumeLiters ?? 0.0;
      monthlyBreakdown[monthKey]['cost'] += entry.totalAmount ?? 0.0;
    }

    // Fuel type breakdown
    final fuelTypeBreakdown = <String, int>{};
    for (final entry in transactions) {
      final fuelType = entry.fuelType.name;
      fuelTypeBreakdown[fuelType] = (fuelTypeBreakdown[fuelType] ?? 0) + 1;
    }

    final fuelEfficiency = await _calculateFuelEfficiency(vehicleId);

    return {
      'totalRefuelings': totalRefuelings,
      'totalVolume': totalVolume,
      'totalCost': totalCost,
      'averagePricePerLiter': averagePricePerLiter,
      'averageVolumePerRefueling': averageVolumePerRefueling,
      'fuelEfficiency': fuelEfficiency,
      'monthlyBreakdown': monthlyBreakdown,
      'fuelTypeBreakdown': fuelTypeBreakdown,
    };
  }

  // Helper method to calculate fuel efficiency
  Future<double> _calculateFuelEfficiency(
    String vehicleId, [
    DateTime? startDate,
    DateTime? endDate,
  ]) async {
    // This is a simplified calculation
    // In a real app, you'd need to track odometer readings and calculate
    // distance traveled between refuelings
    final transactions = startDate != null && endDate != null
        ? await getRefuelingEntriesByDateRange(
            vehicleId: vehicleId,
            startDate: startDate,
            endDate: endDate,
          )
        : await getRefuelingEntriesByVehicle(vehicleId);

    if (transactions.length < 2) {
      return 0.0;
    }

    // Sort by date
    final sortedTransactions = List<RefuelingEntry>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    double totalDistance = 0.0;
    double totalFuel = 0.0;

    for (int i = 1; i < sortedTransactions.length; i++) {
      final current = sortedTransactions[i];
      final previous = sortedTransactions[i - 1];

      // This is a simplified calculation - in reality you'd need odometer data
      // For now, we'll estimate based on average daily distance
      final daysBetween = current.date.difference(previous.date).inDays;
      final estimatedDistance = daysBetween * 50.0; // Assume 50km per day

      totalDistance += estimatedDistance;
      totalFuel += current.volumeLiters ?? 0.0;
    }

    return totalFuel > 0 ? totalDistance / totalFuel : 0.0;
  }

  // Mapping methods
  RefuelingEntry _mapToRefuelingEntry(Transaction transaction) {
    return RefuelingEntry(
      id: transaction.id,
      vehicleId: transaction.vehicleId,
      date: transaction.date,
      volumeLiters: transaction.volumeLiters ?? 0.0,
      pricePerLiter: transaction.pricePerLiter ?? 0.0,
      totalAmount: transaction.amount ?? 0.0,
      currency: transaction.currency ?? '₴',
      odometerKm: transaction.odometerKm ?? 0,
      fuelType: _mapToFuelType(transaction.fuelType),
      isFullTank: transaction.isFullTank ?? false,
      notes: transaction.notes,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }

  Transaction _mapToTransaction(RefuelingEntry entry) {
    return Transaction(
      id: entry.id,
      vehicleId: entry.vehicleId,
      type: 'refueling',
      date: entry.date,
      amount: entry.totalAmount,
      currency: entry.currency,
      odometerKm: entry.odometerKm,
      volumeLiters: entry.volumeLiters,
      pricePerLiter: entry.pricePerLiter,
      fuelType: entry.fuelType.name,
      isFullTank: entry.isFullTank,
      notes: entry.notes,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );
  }

  FuelType _mapToFuelType(String? fuelTypeString) {
    if (fuelTypeString == null) return FuelType.gasoline;

    switch (fuelTypeString.toLowerCase()) {
      case 'gasoline':
        return FuelType.gasoline;
      case 'diesel':
        return FuelType.diesel;
      case 'electric':
        return FuelType.electric;
      case 'hybrid':
        return FuelType.hybrid;
      case 'lpg':
        return FuelType.lpg;
      case 'cng':
        return FuelType.cng;
      default:
        return FuelType.gasoline;
    }
  }

  // Helper method to calculate total distance
  Future<double> _calculateTotalDistance(String vehicleId) async {
    final transactions = await _transactionDao.getRefuelingTransactions(
      vehicleId,
    );

    if (transactions.length < 2) {
      return 0.0;
    }

    // Sort by date
    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Calculate total distance from first to last odometer reading
    final firstOdometer = sortedTransactions.first.odometerKm ?? 0;
    final lastOdometer = sortedTransactions.last.odometerKm ?? 0;

    return (lastOdometer - firstOdometer).toDouble();
  }
}
