import 'package:driveit_app/features/refueling/domain/refueling_entry.dart';
import 'package:driveit_app/features/refueling/domain/refueling_summary.dart';

/// Contract for persisting refueling entries and exposing analytics.
abstract class RefuelingRepository {
  Stream<List<RefuelingEntry>> watchByVehicle(String vehicleId);

  Future<List<RefuelingEntry>> fetchByVehicle(String vehicleId);

  Future<void> saveEntry(RefuelingEntry entry);

  Future<void> deleteEntry(String id);

  Stream<RefuelingSummary> watchSummary(String vehicleId);
}
