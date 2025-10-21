import '../entities/vehicle.dart';
import '../entities/vehicle_stat.dart' as vehicle_stat;

abstract class VehicleRepository {
  Future<List<Vehicle>> getVehicles();
  Future<Vehicle?> getVehicle(String id);
  Future<void> saveVehicle(Vehicle vehicle);
  Future<void> deleteVehicle(String id);
  Stream<List<Vehicle>> watchVehicles();
  Future<void> setPrimaryVehicle(String id);
  Future<Vehicle?> getPrimaryVehicle();
  Stream<List<VehicleWithStats>> watchVehiclesWithStats();
  Future<VehicleWithPhotos?> getVehicleWithPhotos(String id);
  Future<VehicleWithDocuments?> getVehicleWithDocuments(String id);

  // Vehicle Stats methods
  Future<void> addVehicleStat(vehicle_stat.VehicleStat stat);
  Future<void> updateVehicleStat(vehicle_stat.VehicleStat stat);
  Future<void> deleteVehicleStat(String statId);
  Future<List<vehicle_stat.VehicleStat>> getVehicleStats(String vehicleId);
  Stream<List<vehicle_stat.VehicleStat>> watchVehicleStats(String vehicleId);

  // Vehicle Photos methods
  Future<void> addVehiclePhoto(VehiclePhoto photo);
  Future<void> updateVehiclePhoto(VehiclePhoto photo);
  Future<void> deleteVehiclePhoto(String photoId);
  Future<List<VehiclePhoto>> getVehiclePhotos(String vehicleId);
  Stream<List<VehiclePhoto>> watchVehiclePhotos(String vehicleId);

  // Vehicle Documents methods
  Future<void> addVehicleDocument(VehicleDocument document);
  Future<void> updateVehicleDocument(VehicleDocument document);
  Future<void> deleteVehicleDocument(String documentId);
  Future<List<VehicleDocument>> getVehicleDocuments(String vehicleId);
  Stream<List<VehicleDocument>> watchVehicleDocuments(String vehicleId);
}

class VehicleWithStats {
  final Vehicle vehicle;
  final int transactionCount;
  final DateTime? lastTransactionDate;

  VehicleWithStats({
    required this.vehicle,
    required this.transactionCount,
    this.lastTransactionDate,
  });
}

class VehicleWithPhotos {
  final Vehicle vehicle;
  final List<VehiclePhoto> photos;

  VehicleWithPhotos({required this.vehicle, required this.photos});
}

class VehicleWithDocuments {
  final Vehicle vehicle;
  final List<VehicleDocument> documents;

  VehicleWithDocuments({required this.vehicle, required this.documents});
}
