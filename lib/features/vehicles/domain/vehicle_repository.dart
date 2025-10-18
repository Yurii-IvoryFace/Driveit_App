import 'package:driveit_app/features/vehicles/domain/vehicle.dart';

/// Contract for vehicle persistence regardless of storage backend.
abstract class VehicleRepository {
  Stream<List<Vehicle>> watchVehicles();

  Future<List<Vehicle>> fetchVehicles();

  Future<void> saveVehicle(Vehicle vehicle);

  Future<void> deleteVehicle(String id);

  Future<void> setPrimaryVehicle(String id);
}
