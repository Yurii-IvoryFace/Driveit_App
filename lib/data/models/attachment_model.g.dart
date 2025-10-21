// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttachmentModelImpl _$$AttachmentModelImplFromJson(
  Map<String, dynamic> json,
) => _$AttachmentModelImpl(
  id: json['id'] as String,
  transactionId: json['transactionId'] as String?,
  vehicleId: json['vehicleId'] as String?,
  type: $enumDecode(_$AttachmentTypeEnumMap, json['type']),
  name: json['name'] as String,
  filePath: json['filePath'] as String,
  fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt(),
  mimeType: json['mimeType'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$AttachmentModelImplToJson(
  _$AttachmentModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'transactionId': instance.transactionId,
  'vehicleId': instance.vehicleId,
  'type': _$AttachmentTypeEnumMap[instance.type]!,
  'name': instance.name,
  'filePath': instance.filePath,
  'fileSizeBytes': instance.fileSizeBytes,
  'mimeType': instance.mimeType,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$AttachmentTypeEnumMap = {
  AttachmentType.photo: 'photo',
  AttachmentType.document: 'document',
};
