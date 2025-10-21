import 'package:equatable/equatable.dart';
import 'vehicle_stat.dart' as vehicle_stat;

class Vehicle extends Equatable {
  const Vehicle({
    required this.id,
    required this.name,
    required this.make,
    required this.model,
    required this.year,
    this.vin,
    this.licensePlate,
    this.photoUrl,
    this.isPrimary = false,
    this.fuelType,
    this.odometerKm,
    this.purchaseDate,
    this.purchasePrice,
    this.purchaseOdometerKm,
    this.notes,
    this.photos = const [],
    this.documents = const [],
    this.stats = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String make;
  final String model;
  final int year;
  final String? vin;
  final String? licensePlate;
  final String? photoUrl;
  final bool isPrimary;
  final String? fuelType;
  final int? odometerKm;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final int? purchaseOdometerKm;
  final String? notes;
  final List<VehiclePhoto> photos;
  final List<VehicleDocument> documents;
  final List<vehicle_stat.VehicleStat> stats;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle copyWith({
    String? id,
    String? name,
    String? make,
    String? model,
    int? year,
    String? vin,
    String? licensePlate,
    String? photoUrl,
    bool? isPrimary,
    String? fuelType,
    int? odometerKm,
    DateTime? purchaseDate,
    double? purchasePrice,
    int? purchaseOdometerKm,
    String? notes,
    List<VehiclePhoto>? photos,
    List<VehicleDocument>? documents,
    List<vehicle_stat.VehicleStat>? stats,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      licensePlate: licensePlate ?? this.licensePlate,
      photoUrl: photoUrl ?? this.photoUrl,
      isPrimary: isPrimary ?? this.isPrimary,
      fuelType: fuelType ?? this.fuelType,
      odometerKm: odometerKm ?? this.odometerKm,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseOdometerKm: purchaseOdometerKm ?? this.purchaseOdometerKm,
      notes: notes ?? this.notes,
      photos: photos ?? this.photos,
      documents: documents ?? this.documents,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    make,
    model,
    year,
    vin,
    licensePlate,
    photoUrl,
    isPrimary,
    fuelType,
    odometerKm,
    purchaseDate,
    purchasePrice,
    purchaseOdometerKm,
    notes,
    photos,
    documents,
    stats,
    createdAt,
    updatedAt,
  ];
}

class VehiclePhoto extends Equatable {
  const VehiclePhoto({
    required this.id,
    required this.vehicleId,
    required this.name,
    required this.filePath,
    this.url,
    this.description,
    this.fileSizeBytes,
    this.mimeType,
    required this.createdAt,
  });

  final String id;
  final String vehicleId;
  final String name;
  final String filePath;
  final String? url;
  final String? description;
  final int? fileSizeBytes;
  final String? mimeType;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    name,
    filePath,
    url,
    description,
    fileSizeBytes,
    mimeType,
    createdAt,
  ];
}

class VehicleDocument extends Equatable {
  const VehicleDocument({
    required this.id,
    required this.vehicleId,
    required this.name,
    required this.filePath,
    this.type,
    this.fileSizeBytes,
    this.mimeType,
    required this.createdAt,
  });

  final String id;
  final String vehicleId;
  final String name;
  final String filePath;
  final String? type;
  final int? fileSizeBytes;
  final String? mimeType;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    name,
    filePath,
    type,
    fileSizeBytes,
    mimeType,
    createdAt,
  ];
}
