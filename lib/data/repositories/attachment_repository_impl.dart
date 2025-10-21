import '../datasources/local/app_database.dart';
import '../datasources/local/daos/attachment_dao.dart';
import '../../domain/entities/attachment.dart' as domain;
import '../../domain/repositories/attachment_repository.dart';

class AttachmentRepositoryImpl implements AttachmentRepository {
  final AppDatabase _database;
  late final AttachmentDao _attachmentDao;

  AttachmentRepositoryImpl(this._database) {
    _attachmentDao = _database.attachmentDao;
  }

  @override
  Future<List<domain.Attachment>> getAttachments() async {
    final attachments = await _attachmentDao.getAll();
    return attachments.map(_mapToEntity).toList();
  }

  @override
  Future<domain.Attachment?> getAttachment(String id) async {
    final attachment = await _attachmentDao.getById(id);
    return attachment != null ? _mapToEntity(attachment) : null;
  }

  @override
  Future<void> saveAttachment(domain.Attachment attachment) async {
    final attachmentData = _mapToData(attachment);
    await _attachmentDao.insert(attachmentData);
  }

  @override
  Future<void> deleteAttachment(String id) async {
    await _attachmentDao.deleteAttachment(id);
  }

  @override
  Future<List<domain.Attachment>> getAttachmentsByVehicle(
    String vehicleId,
  ) async {
    final attachments = await _attachmentDao.getByVehicleId(vehicleId);
    return attachments.map(_mapToEntity).toList();
  }

  @override
  Stream<List<domain.Attachment>> watchAttachmentsByVehicle(
    String vehicleId,
  ) async* {
    await for (final attachments in _attachmentDao.watchByVehicleId(
      vehicleId,
    )) {
      yield attachments.map(_mapToEntity).toList();
    }
  }

  @override
  Future<List<domain.Attachment>> getAttachmentsByTransaction(
    String transactionId,
  ) async {
    final attachments = await _attachmentDao.getByTransactionId(transactionId);
    return attachments.map(_mapToEntity).toList();
  }

  @override
  Stream<List<domain.Attachment>> watchAttachmentsByTransaction(
    String transactionId,
  ) async* {
    await for (final attachments in _attachmentDao.watchByTransactionId(
      transactionId,
    )) {
      yield attachments.map(_mapToEntity).toList();
    }
  }

  @override
  Future<List<domain.Attachment>> getAttachmentsByType(String type) async {
    final attachments = await _attachmentDao.getByType(type);
    return attachments.map(_mapToEntity).toList();
  }

  @override
  Future<List<domain.Attachment>> getVehiclePhotos(String vehicleId) async {
    final attachments = await _attachmentDao.getVehiclePhotos(vehicleId);
    return attachments.map(_mapToEntity).toList();
  }

  @override
  Future<List<domain.Attachment>> getVehicleDocuments(String vehicleId) async {
    final attachments = await _attachmentDao.getVehicleDocuments(vehicleId);
    return attachments.map(_mapToEntity).toList();
  }

  @override
  Future<List<domain.Attachment>> getTransactionAttachments(
    String transactionId,
  ) async {
    final attachments = await _attachmentDao.getTransactionAttachments(
      transactionId,
    );
    return attachments.map(_mapToEntity).toList();
  }

  @override
  Future<AttachmentStats> getAttachmentStats(String vehicleId) async {
    final stats = await _attachmentDao.getStats(vehicleId);
    return AttachmentStats(
      totalCount: stats['totalCount'] as int,
      photoCount: stats['photoCount'] as int,
      documentCount: stats['documentCount'] as int,
      totalSizeBytes: stats['totalSizeBytes'] as int,
    );
  }

  @override
  Future<List<domain.Attachment>> searchAttachmentsByName(String query) async {
    final attachments = await _attachmentDao.searchByName(query);
    return attachments.map(_mapToEntity).toList();
  }

  @override
  Future<List<domain.Attachment>> getAttachmentsByMimeType(
    String mimeType,
  ) async {
    final attachments = await _attachmentDao.getByMimeType(mimeType);
    return attachments.map(_mapToEntity).toList();
  }

  @override
  Future<List<domain.Attachment>> getRecentAttachments() async {
    final attachments = await _attachmentDao.getRecent();
    return attachments.map(_mapToEntity).toList();
  }

  @override
  Future<void> deleteAttachmentsByVehicle(String vehicleId) async {
    await _attachmentDao.deleteByVehicleId(vehicleId);
  }

  @override
  Future<void> deleteAttachmentsByTransaction(String transactionId) async {
    await _attachmentDao.deleteByTransactionId(transactionId);
  }

  // Mapping methods
  domain.Attachment _mapToEntity(Attachment data) {
    return domain.Attachment(
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

  Attachment _mapToData(domain.Attachment entity) {
    return Attachment(
      id: entity.id,
      transactionId: entity.transactionId,
      vehicleId: entity.vehicleId,
      type: entity.type,
      name: entity.name,
      filePath: entity.filePath,
      fileSizeBytes: entity.fileSizeBytes,
      mimeType: entity.mimeType,
      createdAt: entity.createdAt,
    );
  }
}
