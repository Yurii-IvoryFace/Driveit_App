import 'package:equatable/equatable.dart';

class Attachment extends Equatable {
  const Attachment({
    required this.id,
    this.transactionId,
    this.vehicleId,
    required this.type,
    required this.name,
    required this.filePath,
    this.fileSizeBytes,
    this.mimeType,
    required this.createdAt,
  });

  final String id;
  final String? transactionId;
  final String? vehicleId;
  final String type;
  final String name;
  final String filePath;
  final int? fileSizeBytes;
  final String? mimeType;
  final DateTime createdAt;

  Attachment copyWith({
    String? id,
    String? transactionId,
    String? vehicleId,
    String? type,
    String? name,
    String? filePath,
    int? fileSizeBytes,
    String? mimeType,
    DateTime? createdAt,
  }) {
    return Attachment(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      mimeType: mimeType ?? this.mimeType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    transactionId,
    vehicleId,
    type,
    name,
    filePath,
    fileSizeBytes,
    mimeType,
    createdAt,
  ];
}

