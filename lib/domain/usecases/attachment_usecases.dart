import '../entities/attachment.dart';
import '../repositories/attachment_repository.dart';

class GetAttachments {
  final AttachmentRepository repository;

  GetAttachments(this.repository);

  Future<List<Attachment>> call() => repository.getAttachments();
}

class GetAttachment {
  final AttachmentRepository repository;

  GetAttachment(this.repository);

  Future<Attachment?> call(String id) => repository.getAttachment(id);
}

class SaveAttachment {
  final AttachmentRepository repository;

  SaveAttachment(this.repository);

  Future<void> call(Attachment attachment) =>
      repository.saveAttachment(attachment);
}

class DeleteAttachment {
  final AttachmentRepository repository;

  DeleteAttachment(this.repository);

  Future<void> call(String id) => repository.deleteAttachment(id);
}

class GetAttachmentsByVehicle {
  final AttachmentRepository repository;

  GetAttachmentsByVehicle(this.repository);

  Future<List<Attachment>> call(String vehicleId) =>
      repository.getAttachmentsByVehicle(vehicleId);
}

class WatchAttachmentsByVehicle {
  final AttachmentRepository repository;

  WatchAttachmentsByVehicle(this.repository);

  Stream<List<Attachment>> call(String vehicleId) =>
      repository.watchAttachmentsByVehicle(vehicleId);
}

class GetAttachmentsByTransaction {
  final AttachmentRepository repository;

  GetAttachmentsByTransaction(this.repository);

  Future<List<Attachment>> call(String transactionId) =>
      repository.getAttachmentsByTransaction(transactionId);
}

class WatchAttachmentsByTransaction {
  final AttachmentRepository repository;

  WatchAttachmentsByTransaction(this.repository);

  Stream<List<Attachment>> call(String transactionId) =>
      repository.watchAttachmentsByTransaction(transactionId);
}

class GetAttachmentsByType {
  final AttachmentRepository repository;

  GetAttachmentsByType(this.repository);

  Future<List<Attachment>> call(String type) =>
      repository.getAttachmentsByType(type);
}

class GetVehiclePhotos {
  final AttachmentRepository repository;

  GetVehiclePhotos(this.repository);

  Future<List<Attachment>> call(String vehicleId) =>
      repository.getVehiclePhotos(vehicleId);
}

class GetVehicleDocuments {
  final AttachmentRepository repository;

  GetVehicleDocuments(this.repository);

  Future<List<Attachment>> call(String vehicleId) =>
      repository.getVehicleDocuments(vehicleId);
}

class GetTransactionAttachments {
  final AttachmentRepository repository;

  GetTransactionAttachments(this.repository);

  Future<List<Attachment>> call(String transactionId) =>
      repository.getTransactionAttachments(transactionId);
}

class GetAttachmentStats {
  final AttachmentRepository repository;

  GetAttachmentStats(this.repository);

  Future<AttachmentStats> call(String vehicleId) =>
      repository.getAttachmentStats(vehicleId);
}

class SearchAttachmentsByName {
  final AttachmentRepository repository;

  SearchAttachmentsByName(this.repository);

  Future<List<Attachment>> call(String query) =>
      repository.searchAttachmentsByName(query);
}

class GetAttachmentsByMimeType {
  final AttachmentRepository repository;

  GetAttachmentsByMimeType(this.repository);

  Future<List<Attachment>> call(String mimeType) =>
      repository.getAttachmentsByMimeType(mimeType);
}

class GetRecentAttachments {
  final AttachmentRepository repository;

  GetRecentAttachments(this.repository);

  Future<List<Attachment>> call() => repository.getRecentAttachments();
}

class DeleteAttachmentsByVehicle {
  final AttachmentRepository repository;

  DeleteAttachmentsByVehicle(this.repository);

  Future<void> call(String vehicleId) =>
      repository.deleteAttachmentsByVehicle(vehicleId);
}

class DeleteAttachmentsByTransaction {
  final AttachmentRepository repository;

  DeleteAttachmentsByTransaction(this.repository);

  Future<void> call(String transactionId) =>
      repository.deleteAttachmentsByTransaction(transactionId);
}
