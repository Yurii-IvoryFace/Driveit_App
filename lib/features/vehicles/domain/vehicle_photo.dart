import 'package:equatable/equatable.dart';

/// Classification for stored vehicle photos to help organize the gallery.
enum VehiclePhotoCategory {
  exterior('Exterior'),
  interior('Interior'),
  documents('Documents'),
  maintenance('Maintenance'),
  receipts('Receipts');

  const VehiclePhotoCategory(this.label);

  final String label;

  static VehiclePhotoCategory fromSerialized(String value) {
    return VehiclePhotoCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => VehiclePhotoCategory.exterior,
    );
  }
}

/// Value object describing a single photo associated with a vehicle.
class VehiclePhoto extends Equatable {
  const VehiclePhoto({
    required this.id,
    required this.url,
    required this.category,
    required this.addedAt,
    this.notes,
  });

  final String id;
  final String url;
  final VehiclePhotoCategory category;
  final DateTime addedAt;
  final String? notes;

  VehiclePhoto copyWith({
    String? id,
    String? url,
    VehiclePhotoCategory? category,
    DateTime? addedAt,
    String? notes,
  }) {
    return VehiclePhoto(
      id: id ?? this.id,
      url: url ?? this.url,
      category: category ?? this.category,
      addedAt: addedAt ?? this.addedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, url, category, addedAt, notes];
}
