import 'package:drift/drift.dart';
import '../app_database.dart';

part 'attachment_dao.g.dart';

@DriftAccessor(tables: [Attachments, Vehicles, Transactions])
class AttachmentDao extends DatabaseAccessor<AppDatabase>
    with _$AttachmentDaoMixin {
  AttachmentDao(super.db);

  // Get all attachments
  Future<List<Attachment>> getAll() async {
    return await select(attachments).get();
  }

  // Get attachment by ID
  Future<Attachment?> getById(String id) async {
    return await (select(
      attachments,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // Get attachments by vehicle ID
  Future<List<Attachment>> getByVehicleId(String vehicleId) async {
    return await (select(attachments)
          ..where((tbl) => tbl.vehicleId.equals(vehicleId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  // Get attachments by transaction ID
  Future<List<Attachment>> getByTransactionId(String transactionId) async {
    return await (select(attachments)
          ..where((tbl) => tbl.transactionId.equals(transactionId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  // Get attachments by type
  Future<List<Attachment>> getByType(String type) async {
    return await (select(attachments)
          ..where((tbl) => tbl.type.equals(type))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  // Get vehicle photos
  Future<List<Attachment>> getVehiclePhotos(String vehicleId) async {
    return await (select(attachments)
          ..where(
            (tbl) => tbl.vehicleId.equals(vehicleId) & tbl.type.equals('photo'),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  // Get vehicle documents
  Future<List<Attachment>> getVehicleDocuments(String vehicleId) async {
    return await (select(attachments)
          ..where(
            (tbl) =>
                tbl.vehicleId.equals(vehicleId) & tbl.type.equals('document'),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  // Get transaction attachments (receipts, etc.)
  Future<List<Attachment>> getTransactionAttachments(
    String transactionId,
  ) async {
    return await (select(attachments)
          ..where((tbl) => tbl.transactionId.equals(transactionId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  // Watch attachments by vehicle ID (for reactive UI)
  Stream<List<Attachment>> watchByVehicleId(String vehicleId) {
    return (select(attachments)
          ..where((tbl) => tbl.vehicleId.equals(vehicleId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();
  }

  // Watch attachments by transaction ID
  Stream<List<Attachment>> watchByTransactionId(String transactionId) {
    return (select(attachments)
          ..where((tbl) => tbl.transactionId.equals(transactionId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();
  }

  // Insert attachment
  Future<void> insert(Attachment attachment) async {
    await into(attachments).insert(attachment);
  }

  // Update attachment
  Future<void> updateAttachment(Attachment attachment) async {
    await (update(
      attachments,
    )..where((tbl) => tbl.id.equals(attachment.id))).write(attachment);
  }

  // Delete attachment
  Future<void> deleteAttachment(String id) async {
    await (delete(attachments)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Delete attachments by vehicle ID
  Future<void> deleteByVehicleId(String vehicleId) async {
    await (delete(
      attachments,
    )..where((tbl) => tbl.vehicleId.equals(vehicleId))).go();
  }

  // Delete attachments by transaction ID
  Future<void> deleteByTransactionId(String transactionId) async {
    await (delete(
      attachments,
    )..where((tbl) => tbl.transactionId.equals(transactionId))).go();
  }

  // Get attachment statistics
  Future<Map<String, dynamic>> getStats(String vehicleId) async {
    final allAttachments = await getByVehicleId(vehicleId);

    int photoCount = 0;
    int documentCount = 0;
    int totalSizeBytes = 0;

    for (final attachment in allAttachments) {
      if (attachment.type == 'photo') {
        photoCount++;
      } else if (attachment.type == 'document') {
        documentCount++;
      }
      totalSizeBytes += attachment.fileSizeBytes ?? 0;
    }

    return {
      'totalCount': allAttachments.length,
      'photoCount': photoCount,
      'documentCount': documentCount,
      'totalSizeBytes': totalSizeBytes,
    };
  }

  // Search attachments by name
  Future<List<Attachment>> searchByName(String query) async {
    return await (select(attachments)
          ..where((tbl) => tbl.name.contains(query))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  // Get attachments by MIME type
  Future<List<Attachment>> getByMimeType(String mimeType) async {
    return await (select(attachments)
          ..where((tbl) => tbl.mimeType.equals(mimeType))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  // Get recent attachments (last 30 days)
  Future<List<Attachment>> getRecent() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return await (select(attachments)
          ..where((tbl) => tbl.createdAt.isBiggerOrEqualValue(thirtyDaysAgo))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }
}
