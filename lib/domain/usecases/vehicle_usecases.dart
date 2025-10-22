import '../entities/vehicle.dart';
import '../entities/vehicle_stat.dart' as vehicle_stat;
import '../repositories/vehicle_repository.dart';

class GetVehicles {
  final VehicleRepository repository;

  GetVehicles(this.repository);

  Future<List<Vehicle>> call() => repository.getVehicles();
}

class GetVehicle {
  final VehicleRepository repository;

  GetVehicle(this.repository);

  Future<Vehicle?> call(String id) => repository.getVehicle(id);
}

class SaveVehicle {
  final VehicleRepository repository;

  SaveVehicle(this.repository);

  Future<void> call(Vehicle vehicle) => repository.saveVehicle(vehicle);
}

class DeleteVehicle {
  final VehicleRepository repository;

  DeleteVehicle(this.repository);

  Future<void> call(String id) => repository.deleteVehicle(id);
}

class WatchVehicles {
  final VehicleRepository repository;

  WatchVehicles(this.repository);

  Stream<List<Vehicle>> call() => repository.watchVehicles();
}

class SetPrimaryVehicle {
  final VehicleRepository repository;

  SetPrimaryVehicle(this.repository);

  Future<void> call(String id) => repository.setPrimaryVehicle(id);
}

class UpdateVehicleOdometer {
  final VehicleRepository _repository;

  UpdateVehicleOdometer(this._repository);

  Future<void> call(String vehicleId, int odometerKm) async {
    final vehicle = await _repository.getVehicle(vehicleId);
    if (vehicle != null) {
      final updatedVehicle = vehicle.copyWith(odometerKm: odometerKm);
      await _repository.saveVehicle(updatedVehicle);
    }
  }
}

class GetPrimaryVehicle {
  final VehicleRepository repository;

  GetPrimaryVehicle(this.repository);

  Future<Vehicle?> call() => repository.getPrimaryVehicle();
}

class WatchVehiclesWithStats {
  final VehicleRepository repository;

  WatchVehiclesWithStats(this.repository);

  Stream<List<VehicleWithStats>> call() => repository.watchVehiclesWithStats();
}

class GetVehicleWithPhotos {
  final VehicleRepository repository;

  GetVehicleWithPhotos(this.repository);

  Future<VehicleWithPhotos?> call(String id) =>
      repository.getVehicleWithPhotos(id);
}

class GetVehicleWithDocuments {
  final VehicleRepository repository;

  GetVehicleWithDocuments(this.repository);

  Future<VehicleWithDocuments?> call(String id) =>
      repository.getVehicleWithDocuments(id);
}

// Vehicle Stats Use Cases
class AddVehicleStat {
  final VehicleRepository repository;

  AddVehicleStat(this.repository);

  Future<void> call(vehicle_stat.VehicleStat stat) =>
      repository.addVehicleStat(stat);
}

class UpdateVehicleStat {
  final VehicleRepository repository;

  UpdateVehicleStat(this.repository);

  Future<void> call(vehicle_stat.VehicleStat stat) =>
      repository.updateVehicleStat(stat);
}

class DeleteVehicleStat {
  final VehicleRepository repository;

  DeleteVehicleStat(this.repository);

  Future<void> call(String statId) => repository.deleteVehicleStat(statId);
}

class GetVehicleStats {
  final VehicleRepository repository;

  GetVehicleStats(this.repository);

  Future<List<vehicle_stat.VehicleStat>> call(String vehicleId) =>
      repository.getVehicleStats(vehicleId);
}

class WatchVehicleStats {
  final VehicleRepository repository;

  WatchVehicleStats(this.repository);

  Stream<List<vehicle_stat.VehicleStat>> call(String vehicleId) =>
      repository.watchVehicleStats(vehicleId);
}

// Vehicle Photos Use Cases
class AddVehiclePhoto {
  final VehicleRepository repository;

  AddVehiclePhoto(this.repository);

  Future<void> call(VehiclePhoto photo) => repository.addVehiclePhoto(photo);
}

class UpdateVehiclePhoto {
  final VehicleRepository repository;

  UpdateVehiclePhoto(this.repository);

  Future<void> call(VehiclePhoto photo) => repository.updateVehiclePhoto(photo);
}

class DeleteVehiclePhoto {
  final VehicleRepository repository;

  DeleteVehiclePhoto(this.repository);

  Future<void> call(String photoId) => repository.deleteVehiclePhoto(photoId);
}

class GetVehiclePhotos {
  final VehicleRepository repository;

  GetVehiclePhotos(this.repository);

  Future<List<VehiclePhoto>> call(String vehicleId) =>
      repository.getVehiclePhotos(vehicleId);
}

class WatchVehiclePhotos {
  final VehicleRepository repository;

  WatchVehiclePhotos(this.repository);

  Stream<List<VehiclePhoto>> call(String vehicleId) =>
      repository.watchVehiclePhotos(vehicleId);
}

// Vehicle Documents Use Cases
class AddVehicleDocument {
  final VehicleRepository repository;

  AddVehicleDocument(this.repository);

  Future<void> call(VehicleDocument document) =>
      repository.addVehicleDocument(document);
}

class UpdateVehicleDocument {
  final VehicleRepository repository;

  UpdateVehicleDocument(this.repository);

  Future<void> call(VehicleDocument document) =>
      repository.updateVehicleDocument(document);
}

class DeleteVehicleDocument {
  final VehicleRepository repository;

  DeleteVehicleDocument(this.repository);

  Future<void> call(String documentId) =>
      repository.deleteVehicleDocument(documentId);
}

class GetVehicleDocuments {
  final VehicleRepository repository;

  GetVehicleDocuments(this.repository);

  Future<List<VehicleDocument>> call(String vehicleId) =>
      repository.getVehicleDocuments(vehicleId);
}

class WatchVehicleDocuments {
  final VehicleRepository repository;

  WatchVehicleDocuments(this.repository);

  Stream<List<VehicleDocument>> call(String vehicleId) =>
      repository.watchVehicleDocuments(vehicleId);
}
