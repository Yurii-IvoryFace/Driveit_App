import 'package:freezed_annotation/freezed_annotation.dart';

part 'attachment_model.freezed.dart';
part 'attachment_model.g.dart';

enum AttachmentType { photo, document }

@freezed
class AttachmentModel with _$AttachmentModel {
  const factory AttachmentModel({
    required String id,
    String? transactionId,
    String? vehicleId,
    required AttachmentType type,
    required String name,
    required String filePath,
    int? fileSizeBytes,
    String? mimeType,
    required DateTime createdAt,
  }) = _AttachmentModel;

  factory AttachmentModel.fromJson(Map<String, dynamic> json) =>
      _$AttachmentModelFromJson(json);
}
