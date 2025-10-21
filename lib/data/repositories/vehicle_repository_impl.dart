import '../datasources/local/app_database.dart';
import '../datasources/local/daos/vehicle_dao.dart';
import '../datasources/local/daos/attachment_dao.dart';
import '../../domain/entities/vehicle.dart' as domain;
import '../../domain/entities/vehicle_stat.dart' as vehicle_stat;
import '../../domain/repositories/vehicle_repository.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final AppDatabase _database;
  late final VehicleDao _vehicleDao;
  late final AttachmentDao _attachmentDao;

  VehicleRepositoryImpl(this._database) {
    _vehicleDao = _database.vehicleDao;
    _attachmentDao = _database.attachmentDao;
  }

  @override
  Future<List<domain.Vehicle>> getVehicles() async {
    final vehicles = await _vehicleDao.getAll();
    return vehicles.map(_mapToEntity).toList();
  }

  @override
  Future<domain.Vehicle?> getVehicle(String id) async {
    final vehicle = await _vehicleDao.getById(id);
    return vehicle != null ? _mapToEntity(vehicle) : null;
  }

  @override
  Future<void> saveVehicle(domain.Vehicle vehicle) async {
    final vehicleData = _mapToData(vehicle);
    // Check if vehicle exists
    final existingVehicle = await _vehicleDao.getById(vehicle.id);
    if (existingVehicle != null) {
      await _vehicleDao.updateVehicle(vehicleData);
    } else {
      await _vehicleDao.insert(vehicleData);
    }
  }

  @override
  Future<void> deleteVehicle(String id) async {
    await _vehicleDao.deleteVehicle(id);
  }

  @override
  Stream<List<domain.Vehicle>> watchVehicles() async* {
    await for (final vehicles in _vehicleDao.watchAll()) {
      yield vehicles.map(_mapToEntity).toList();
    }
  }

  @override
  Future<void> setPrimaryVehicle(String id) async {
    await _vehicleDao.setPrimary(id);
  }

  @override
  Future<domain.Vehicle?> getPrimaryVehicle() async {
    final vehicle = await _vehicleDao.getPrimary();
    return vehicle != null ? _mapToEntity(vehicle) : null;
  }

  @override
  Stream<List<VehicleWithStats>> watchVehiclesWithStats() async* {
    await for (final vehiclesWithStats in _vehicleDao.watchWithStats()) {
      yield vehiclesWithStats
          .map(
            (v) => VehicleWithStats(
              vehicle: _mapToEntity(v['vehicle'] as Vehicle),
              transactionCount: v['transactionCount'] as int,
              lastTransactionDate: v['lastTransactionDate'] as DateTime?,
            ),
          )
          .toList();
    }
  }

  @override
  Future<VehicleWithPhotos?> getVehicleWithPhotos(String id) async {
    final result = await _vehicleDao.getWithPhotos(id);
    if (result == null) return null;

    return VehicleWithPhotos(
      vehicle: _mapToEntity(result['vehicle'] as Vehicle),
      photos: (result['photos'] as List<Attachment>)
          .map(_mapAttachmentToVehiclePhoto)
          .toList(),
    );
  }

  @override
  Future<VehicleWithDocuments?> getVehicleWithDocuments(String id) async {
    final result = await _vehicleDao.getWithDocuments(id);
    if (result == null) return null;

    return VehicleWithDocuments(
      vehicle: _mapToEntity(result['vehicle'] as Vehicle),
      documents: (result['documents'] as List<Attachment>)
          .map(_mapAttachmentToVehicleDocument)
          .toList(),
    );
  }

  // Mapping methods
  domain.Vehicle _mapToEntity(Vehicle data) {
    return domain.Vehicle(
      id: data.id,
      name: data.name,
      make: data.make,
      model: data.model,
      year: data.year,
      vin: data.vin,
      licensePlate: data.licensePlate,
      photoUrl: data.photoUrl,
      isPrimary: data.isPrimary,
      fuelType: data.fuelType,
      odometerKm: data.odometerKm,
      purchaseDate: data.purchaseDate,
      purchasePrice: data.purchasePrice,
      purchaseOdometerKm: data.purchaseOdometerKm,
      notes: data.notes,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  Vehicle _mapToData(domain.Vehicle entity) {
    return Vehicle(
      id: entity.id,
      name: entity.name,
      make: entity.make,
      model: entity.model,
      year: entity.year,
      vin: entity.vin,
      licensePlate: entity.licensePlate,
      photoUrl: entity.photoUrl,
      isPrimary: entity.isPrimary,
      fuelType: entity.fuelType,
      odometerKm: entity.odometerKm,
      purchaseDate: entity.purchaseDate,
      purchasePrice: entity.purchasePrice,
      purchaseOdometerKm: entity.purchaseOdometerKm,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  domain.VehiclePhoto _mapAttachmentToVehiclePhoto(Attachment data) {
    return domain.VehiclePhoto(
      id: data.id,
      vehicleId: data.vehicleId!,
      name: data.name,
      filePath: data.filePath,
      fileSizeBytes: data.fileSizeBytes,
      mimeType: data.mimeType,
      createdAt: data.createdAt,
    );
  }

  domain.VehicleDocument _mapAttachmentToVehicleDocument(Attachment data) {
    return domain.VehicleDocument(
      id: data.id,
      vehicleId: data.vehicleId!,
      name: data.name,
      filePath: data.filePath,
      fileSizeBytes: data.fileSizeBytes,
      mimeType: data.mimeType,
      createdAt: data.createdAt,
    );
  }

  // Vehicle Stats implementations
  @override
  Future<void> addVehicleStat(vehicle_stat.VehicleStat stat) async {
    // For now, we'll store stats as attachments with type 'stat'
    // In a real implementation, you might want a separate stats table
    final attachment = Attachment(
      id: stat.id,
      vehicleId: stat.vehicleId,
      type: 'stat',
      name: '${stat.type.name}_${stat.value}',
      filePath: stat.value, // Store the value in filePath for now
      mimeType: stat.unit,
      createdAt: stat.createdAt,
    );
    await _attachmentDao.insert(attachment);
  }

  @override
  Future<void> updateVehicleStat(vehicle_stat.VehicleStat stat) async {
    final attachment = Attachment(
      id: stat.id,
      vehicleId: stat.vehicleId,
      type: 'stat',
      name: '${stat.type.name}_${stat.value}',
      filePath: stat.value,
      mimeType: stat.unit,
      createdAt: stat.createdAt,
    );
    await _attachmentDao.updateAttachment(attachment);
  }

  @override
  Future<void> deleteVehicleStat(String statId) async {
    await _attachmentDao.deleteAttachment(statId);
  }

  @override
  Future<List<vehicle_stat.VehicleStat>> getVehicleStats(
    String vehicleId,
  ) async {
    final attachments = await _attachmentDao.getByVehicleId(vehicleId);
    return attachments
        .where((a) => a.type == 'stat')
        .map(_mapAttachmentToVehicleStat)
        .toList();
  }

  @override
  Stream<List<vehicle_stat.VehicleStat>> watchVehicleStats(
    String vehicleId,
  ) async* {
    await for (final attachments in _attachmentDao.watchByVehicleId(
      vehicleId,
    )) {
      yield attachments
          .where((a) => a.type == 'stat')
          .map(_mapAttachmentToVehicleStat)
          .toList();
    }
  }

  // Vehicle Photos implementations
  @override
  Future<void> addVehiclePhoto(domain.VehiclePhoto photo) async {
    final attachment = Attachment(
      id: photo.id,
      vehicleId: photo.vehicleId,
      type: 'photo',
      name: photo.name,
      filePath: photo.filePath,
      fileSizeBytes: photo.fileSizeBytes,
      mimeType: photo.mimeType,
      createdAt: photo.createdAt,
    );
    await _attachmentDao.insert(attachment);
  }

  @override
  Future<void> updateVehiclePhoto(domain.VehiclePhoto photo) async {
    final attachment = Attachment(
      id: photo.id,
      vehicleId: photo.vehicleId,
      type: 'photo',
      name: photo.name,
      filePath: photo.filePath,
      fileSizeBytes: photo.fileSizeBytes,
      mimeType: photo.mimeType,
      createdAt: photo.createdAt,
    );
    await _attachmentDao.updateAttachment(attachment);
  }

  @override
  Future<void> deleteVehiclePhoto(String photoId) async {
    await _attachmentDao.deleteAttachment(photoId);
  }

  @override
  Future<List<domain.VehiclePhoto>> getVehiclePhotos(String vehicleId) async {
    final attachments = await _attachmentDao.getVehiclePhotos(vehicleId);
    return attachments.map(_mapAttachmentToVehiclePhoto).toList();
  }

  @override
  Stream<List<domain.VehiclePhoto>> watchVehiclePhotos(
    String vehicleId,
  ) async* {
    await for (final attachments in _attachmentDao.watchByVehicleId(
      vehicleId,
    )) {
      yield attachments
          .where((a) => a.type == 'photo')
          .map(_mapAttachmentToVehiclePhoto)
          .toList();
    }
  }

  // Vehicle Documents implementations
  @override
  Future<void> addVehicleDocument(domain.VehicleDocument document) async {
    final attachment = Attachment(
      id: document.id,
      vehicleId: document.vehicleId,
      type: 'document',
      name: document.name,
      filePath: document.filePath,
      fileSizeBytes: document.fileSizeBytes,
      mimeType: document.mimeType,
      createdAt: document.createdAt,
    );
    await _attachmentDao.insert(attachment);
  }

  @override
  Future<void> updateVehicleDocument(domain.VehicleDocument document) async {
    final attachment = Attachment(
      id: document.id,
      vehicleId: document.vehicleId,
      type: 'document',
      name: document.name,
      filePath: document.filePath,
      fileSizeBytes: document.fileSizeBytes,
      mimeType: document.mimeType,
      createdAt: document.createdAt,
    );
    await _attachmentDao.updateAttachment(attachment);
  }

  @override
  Future<void> deleteVehicleDocument(String documentId) async {
    await _attachmentDao.deleteAttachment(documentId);
  }

  @override
  Future<List<domain.VehicleDocument>> getVehicleDocuments(
    String vehicleId,
  ) async {
    final attachments = await _attachmentDao.getVehicleDocuments(vehicleId);
    return attachments.map(_mapAttachmentToVehicleDocument).toList();
  }

  @override
  Stream<List<domain.VehicleDocument>> watchVehicleDocuments(
    String vehicleId,
  ) async* {
    await for (final attachments in _attachmentDao.watchByVehicleId(
      vehicleId,
    )) {
      yield attachments
          .where((a) => a.type == 'document')
          .map(_mapAttachmentToVehicleDocument)
          .toList();
    }
  }

  // Helper method to map attachment to vehicle stat
  vehicle_stat.VehicleStat _mapAttachmentToVehicleStat(Attachment data) {
    // Parse the stat type and value from the name and filePath
    final parts = data.name.split('_');
    if (parts.length < 2) {
      throw Exception('Invalid stat format');
    }

    final statType = vehicle_stat.VehicleStatType.values.firstWhere(
      (type) => type.name == parts[0],
      orElse: () => vehicle_stat.VehicleStatType.custom,
    );

    return vehicle_stat.VehicleStat(
      id: data.id,
      vehicleId: data.vehicleId!,
      type: statType,
      value: data.filePath, // The value is stored in filePath
      unit: data.mimeType,
      createdAt: data.createdAt,
    );
  }
}
