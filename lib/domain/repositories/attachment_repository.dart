import '../entities/attachment.dart';

abstract class AttachmentRepository {
  Future<List<Attachment>> getAttachments();
  Future<Attachment?> getAttachment(String id);
  Future<void> saveAttachment(Attachment attachment);
  Future<void> deleteAttachment(String id);
  Future<List<Attachment>> getAttachmentsByVehicle(String vehicleId);
  Stream<List<Attachment>> watchAttachmentsByVehicle(String vehicleId);
  Future<List<Attachment>> getAttachmentsByTransaction(String transactionId);
  Stream<List<Attachment>> watchAttachmentsByTransaction(String transactionId);
  Future<List<Attachment>> getAttachmentsByType(String type);
  Future<List<Attachment>> getVehiclePhotos(String vehicleId);
  Future<List<Attachment>> getVehicleDocuments(String vehicleId);
  Future<List<Attachment>> getTransactionAttachments(String transactionId);
  Future<AttachmentStats> getAttachmentStats(String vehicleId);
  Future<List<Attachment>> searchAttachmentsByName(String query);
  Future<List<Attachment>> getAttachmentsByMimeType(String mimeType);
  Future<List<Attachment>> getRecentAttachments();
  Future<void> deleteAttachmentsByVehicle(String vehicleId);
  Future<void> deleteAttachmentsByTransaction(String transactionId);
}

class AttachmentStats {
  final int totalCount;
  final int photoCount;
  final int documentCount;
  final int totalSizeBytes;

  AttachmentStats({
    required this.totalCount,
    required this.photoCount,
    required this.documentCount,
    required this.totalSizeBytes,
  });

  double get totalSizeMB => totalSizeBytes / (1024 * 1024);
}

