import 'package:driveit_app/features/vehicles/domain/vehicle_photo.dart';

class VehiclePhotoDto {
  const VehiclePhotoDto({
    required this.id,
    required this.url,
    required this.category,
    required this.addedAt,
    this.notes,
  });

  final String id;
  final String url;
  final String category;
  final DateTime addedAt;
  final String? notes;

  factory VehiclePhotoDto.fromJson(Map<String, dynamic> json) {
    return VehiclePhotoDto(
      id: json['id'] as String,
      url: json['url'] as String,
      category:
          json['category'] as String? ?? VehiclePhotoCategory.exterior.name,
      addedAt: DateTime.parse(json['addedAt'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'category': category,
      'addedAt': addedAt.toIso8601String(),
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }

  VehiclePhoto toDomain() {
    return VehiclePhoto(
      id: id,
      url: url,
      category: VehiclePhotoCategory.fromSerialized(category),
      addedAt: addedAt,
      notes: notes,
    );
  }

  factory VehiclePhotoDto.fromDomain(VehiclePhoto photo) {
    return VehiclePhotoDto(
      id: photo.id,
      url: photo.url,
      category: photo.category.name,
      addedAt: photo.addedAt,
      notes: photo.notes,
    );
  }
}
