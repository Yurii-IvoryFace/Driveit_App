import 'package:driveit_app/features/vehicles/domain/vehicle_stat.dart';

/// Repository interface for managing vehicle statistics.
abstract class VehicleStatRepository {
  /// Fetches all statistics for a specific vehicle.
  Future<List<VehicleStat>> fetchStats(String vehicleId);

  /// Watches statistics for a specific vehicle as a stream.
  Stream<List<VehicleStat>> watchStats(String vehicleId);

  /// Saves a vehicle statistic entry.
  Future<void> saveStat(VehicleStat stat);

  /// Deletes a vehicle statistic entry.
  Future<void> deleteStat(String statId);

  /// Gets a specific statistic by ID.
  Future<VehicleStat?> getStat(String statId);

  /// Gets the latest statistic of a specific type for a vehicle.
  Future<VehicleStat?> getLatestStat(String vehicleId, String type);

  /// Creates or updates the odometer stat for a vehicle based on its current odometer reading.
  Future<void> ensureOdometerStat(String vehicleId, int odometerKm);
}

