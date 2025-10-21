import '../entities/refueling_entry.dart';
import '../entities/refueling_summary.dart';

abstract class RefuelingRepository {
  Future<List<RefuelingEntry>> getRefuelingEntries();
  Future<RefuelingEntry?> getRefuelingEntry(String id);
  Future<void> addRefuelingEntry(RefuelingEntry entry);
  Future<void> updateRefuelingEntry(RefuelingEntry entry);
  Future<void> deleteRefuelingEntry(String id);
  Stream<List<RefuelingEntry>> watchRefuelingEntries();

  Future<List<RefuelingEntry>> getRefuelingEntriesByVehicle(String vehicleId);
  Stream<List<RefuelingEntry>> watchRefuelingEntriesByVehicle(String vehicleId);

  Future<List<RefuelingEntry>> getRefuelingEntriesByDateRange({
    required String vehicleId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<RefuelingEntry>> getRecentRefuelingEntries({
    required String vehicleId,
    int limit = 10,
  });

  Future<RefuelingSummary> getRefuelingSummary(String vehicleId);

  Future<double> calculateFuelEfficiency({
    required String vehicleId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Map<String, dynamic>> getRefuelingStatistics({
    required String vehicleId,
    DateTime? startDate,
    DateTime? endDate,
  });
}
