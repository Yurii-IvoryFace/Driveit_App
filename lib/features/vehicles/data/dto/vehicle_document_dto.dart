import 'package:driveit_app/features/vehicles/domain/vehicle_document.dart';

class VehicleDocumentDto {
  const VehicleDocumentDto({
    required this.id,
    required this.title,
    required this.category,
    required this.url,
    required this.uploadedAt,
    this.notes,
  });

  final String id;
  final String title;
  final String category;
  final String url;
  final DateTime uploadedAt;
  final String? notes;

  factory VehicleDocumentDto.fromJson(Map<String, dynamic> json) {
    return VehicleDocumentDto(
      id: json['id'] as String,
      title: json['title'] as String,
      category:
          json['category'] as String? ?? VehicleDocumentCategory.other.name,
      url: json['url'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'url': url,
      'uploadedAt': uploadedAt.toIso8601String(),
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }

  VehicleDocument toDomain() {
    return VehicleDocument(
      id: id,
      title: title,
      category: VehicleDocumentCategory.fromSerialized(category),
      url: url,
      uploadedAt: uploadedAt,
      notes: notes,
    );
  }

  factory VehicleDocumentDto.fromDomain(VehicleDocument document) {
    return VehicleDocumentDto(
      id: document.id,
      title: document.title,
      category: document.category.name,
      url: document.url,
      uploadedAt: document.uploadedAt,
      notes: document.notes,
    );
  }
}
