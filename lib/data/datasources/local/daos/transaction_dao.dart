import 'package:drift/drift.dart';
import '../app_database.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions, Vehicles, Attachments])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  // Get all transactions
  Future<List<Transaction>> getAll() async {
    return await select(transactions).get();
  }

  // Get transaction by ID
  Future<Transaction?> getById(String id) async {
    return await (select(
      transactions,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // Get transactions by vehicle ID
  Future<List<Transaction>> getByVehicleId(String vehicleId) async {
    return await (select(transactions)
          ..where((tbl) => tbl.vehicleId.equals(vehicleId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .get();
  }

  // Watch transactions by vehicle ID (for reactive UI)
  Stream<List<Transaction>> watchByVehicleId(String vehicleId) {
    return (select(transactions)
          ..where((tbl) => tbl.vehicleId.equals(vehicleId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .watch();
  }

  // Watch all transactions
  Stream<List<Transaction>> watchAll() {
    return (select(
      transactions,
    )..orderBy([(tbl) => OrderingTerm.desc(tbl.date)])).watch();
  }

  // Get transactions by type
  Future<List<Transaction>> getByType(String type) async {
    return await (select(transactions)
          ..where((tbl) => tbl.type.equals(type))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .get();
  }

  // Get transactions by date range
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) async {
    return await (select(transactions)
          ..where(
            (tbl) =>
                tbl.date.isBiggerOrEqualValue(start) &
                tbl.date.isSmallerOrEqualValue(end),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .get();
  }

  // Get transactions by vehicle and date range
  Future<List<Transaction>> getByVehicleAndDateRange(
    String vehicleId,
    DateTime start,
    DateTime end,
  ) async {
    return await (select(transactions)
          ..where(
            (tbl) =>
                tbl.vehicleId.equals(vehicleId) &
                tbl.date.isBiggerOrEqualValue(start) &
                tbl.date.isSmallerOrEqualValue(end),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .get();
  }

  // Get refueling transactions
  Future<List<Transaction>> getRefuelingTransactions(String vehicleId) async {
    return await (select(transactions)
          ..where(
            (tbl) =>
                tbl.vehicleId.equals(vehicleId) & tbl.type.equals('refueling'),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .get();
  }

  // Get expense transactions
  Future<List<Transaction>> getExpenseTransactions(String vehicleId) async {
    return await (select(transactions)
          ..where(
            (tbl) =>
                tbl.vehicleId.equals(vehicleId) &
                tbl.type.isIn([
                  'maintenance',
                  'insurance',
                  'parking',
                  'toll',
                  'carWash',
                  'other',
                ]),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .get();
  }

  // Get service transactions
  Future<List<Transaction>> getServiceTransactions(String vehicleId) async {
    return await (select(transactions)
          ..where(
            (tbl) =>
                tbl.vehicleId.equals(vehicleId) &
                tbl.type.equals('maintenance'),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .get();
  }

  // Insert transaction
  Future<void> insert(Transaction transaction) async {
    await into(transactions).insert(transaction);
  }

  // Update transaction
  Future<void> updateTransaction(Transaction transaction) async {
    await (update(
      transactions,
    )..where((tbl) => tbl.id.equals(transaction.id))).write(transaction);
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    await (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Get transaction with attachments
  Future<Map<String, dynamic>?> getWithAttachments(String id) async {
    final transaction = await getById(id);
    if (transaction == null) return null;

    final attachmentList = await (select(
      attachments,
    )..where((tbl) => tbl.transactionId.equals(id))).get();

    return {'transaction': transaction, 'attachments': attachmentList};
  }

  // Get fuel consumption statistics
  Future<List<Map<String, dynamic>>> getFuelConsumptionStats(
    String vehicleId,
  ) async {
    final refuelingData = await getRefuelingTransactions(vehicleId);

    if (refuelingData.length < 2) return [];

    List<Map<String, dynamic>> consumptionData = [];

    for (int i = 0; i < refuelingData.length - 1; i++) {
      final current = refuelingData[i];
      final previous = refuelingData[i + 1];

      if (current.volumeLiters != null &&
          current.odometerKm != null &&
          previous.odometerKm != null) {
        final distance = current.odometerKm! - previous.odometerKm!;
        if (distance > 0) {
          final consumption =
              (current.volumeLiters! / distance) * 100; // L/100km
          consumptionData.add({
            'date': current.date,
            'consumption': consumption,
            'distance': distance.toDouble(),
            'volume': current.volumeLiters!,
            'pricePerLiter': current.pricePerLiter,
          });
        }
      }
    }

    return consumptionData;
  }

  // Get monthly cost summary
  Future<List<Map<String, dynamic>>> getMonthlyCostSummary(
    String vehicleId,
    int year,
  ) async {
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31);

    final transactions = await getByVehicleAndDateRange(
      vehicleId,
      startDate,
      endDate,
    );

    Map<int, Map<String, dynamic>> monthlyData = {};

    for (final transaction in transactions) {
      final month = transaction.date.month;
      if (!monthlyData.containsKey(month)) {
        monthlyData[month] = {
          'month': month,
          'totalCost': 0.0,
          'fuelCost': 0.0,
          'maintenanceCost': 0.0,
          'otherCost': 0.0,
        };
      }

      final cost = transaction.amount ?? 0.0;
      monthlyData[month]!['totalCost'] =
          (monthlyData[month]!['totalCost'] as double) + cost;

      if (transaction.type == 'refueling') {
        monthlyData[month]!['fuelCost'] =
            (monthlyData[month]!['fuelCost'] as double) + cost;
      } else if (transaction.type == 'maintenance') {
        monthlyData[month]!['maintenanceCost'] =
            (monthlyData[month]!['maintenanceCost'] as double) + cost;
      } else {
        monthlyData[month]!['otherCost'] =
            (monthlyData[month]!['otherCost'] as double) + cost;
      }
    }

    return monthlyData.values.toList()
      ..sort((a, b) => (a['month'] as int).compareTo(b['month'] as int));
  }
}
