import 'package:equatable/equatable.dart';

/// Supported buckets for attached vehicle documents.
enum VehicleDocumentCategory {
  insurance('Insurance'),
  registration('Registration'),
  maintenance('Maintenance'),
  purchase('Purchase'),
  other('Other');

  const VehicleDocumentCategory(this.label);

  final String label;

  static VehicleDocumentCategory fromSerialized(String value) {
    return VehicleDocumentCategory.values.firstWhere(
      (item) => item.name == value,
      orElse: () => VehicleDocumentCategory.other,
    );
  }
}

/// Metadata for documents linked to a vehicle (PDFs, scans, etc.).
class VehicleDocument extends Equatable {
  const VehicleDocument({
    required this.id,
    required this.title,
    required this.category,
    required this.url,
    required this.uploadedAt,
    this.notes,
  });

  final String id;
  final String title;
  final VehicleDocumentCategory category;
  final String url;
  final DateTime uploadedAt;
  final String? notes;

  VehicleDocument copyWith({
    String? id,
    String? title,
    VehicleDocumentCategory? category,
    String? url,
    DateTime? uploadedAt,
    String? notes,
  }) {
    return VehicleDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      url: url ?? this.url,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, title, category, url, uploadedAt, notes];
}
