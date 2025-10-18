import 'package:driveit_app/features/vehicles/data/dto/vehicle_document_dto.dart';
import 'package:driveit_app/features/vehicles/data/dto/vehicle_photo_dto.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle.dart';

/// Data transfer object representing how vehicles are stored via the local API.
class VehicleDto {
  const VehicleDto({
    required this.id,
    required this.displayName,
    required this.make,
    required this.model,
    required this.year,
    this.vin,
    this.licensePlate,
    this.photoUrl,
    this.brandSlug,
    this.brandLogoUrl,
    this.brandLogoThumbUrl,
    this.isPrimary = false,
    this.vehicleType,
    this.fuelType,
    this.transmission,
    this.odometerKm,
    this.lastService,
    this.nextService,
    this.insuranceExpiry,
    this.registrationExpiry,
    this.secondaryFuelType,
    this.fuelCapacityPrimary,
    this.fuelCapacitySecondary,
    this.fuelCapacityUnit,
    this.purchaseDate,
    this.purchasePrice,
    this.purchaseOdometerKm,
    this.saleDate,
    this.salePrice,
    this.saleOdometerKm,
    this.notes,
    this.documents = const [],
    this.photos = const [],
  });

  final String id;
  final String displayName;
  final String make;
  final String model;
  final int year;
  final String? vin;
  final String? licensePlate;
  final String? photoUrl;
  final String? brandSlug;
  final String? brandLogoUrl;
  final String? brandLogoThumbUrl;
  final bool isPrimary;
  final String? vehicleType;
  final String? fuelType;
  final String? transmission;
  final int? odometerKm;
  final DateTime? lastService;
  final DateTime? nextService;
  final DateTime? insuranceExpiry;
  final DateTime? registrationExpiry;
  final String? secondaryFuelType;
  final double? fuelCapacityPrimary;
  final double? fuelCapacitySecondary;
  final String? fuelCapacityUnit;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final int? purchaseOdometerKm;
  final DateTime? saleDate;
  final double? salePrice;
  final int? saleOdometerKm;
  final String? notes;
  final List<VehicleDocumentDto> documents;
  final List<VehiclePhotoDto> photos;

  factory VehicleDto.fromJson(Map<String, dynamic> json) {
    return VehicleDto(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      vin: json['vin'] as String?,
      licensePlate: json['licensePlate'] as String?,
      photoUrl: json['photoUrl'] as String?,
      brandSlug: json['brandSlug'] as String?,
      brandLogoUrl: json['brandLogoUrl'] as String?,
      brandLogoThumbUrl: json['brandLogoThumbUrl'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
      vehicleType: json['vehicleType'] as String?,
      fuelType: json['fuelType'] as String?,
      transmission: json['transmission'] as String?,
      odometerKm: json['odometerKm'] as int?,
      lastService: json['lastService'] != null
          ? DateTime.parse(json['lastService'] as String)
          : null,
      nextService: json['nextService'] != null
          ? DateTime.parse(json['nextService'] as String)
          : null,
      insuranceExpiry: json['insuranceExpiry'] != null
          ? DateTime.parse(json['insuranceExpiry'] as String)
          : null,
      registrationExpiry: json['registrationExpiry'] != null
          ? DateTime.parse(json['registrationExpiry'] as String)
          : null,
      secondaryFuelType: json['secondaryFuelType'] as String?,
      fuelCapacityPrimary: (json['fuelCapacityPrimary'] as num?)?.toDouble(),
      fuelCapacitySecondary: (json['fuelCapacitySecondary'] as num?)
          ?.toDouble(),
      fuelCapacityUnit: json['fuelCapacityUnit'] as String?,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : null,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
      purchaseOdometerKm: json['purchaseOdometerKm'] as int?,
      saleDate: json['saleDate'] != null
          ? DateTime.parse(json['saleDate'] as String)
          : null,
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      saleOdometerKm: json['saleOdometerKm'] as int?,
      notes: json['notes'] as String?,
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map(
                (item) =>
                    VehicleDocumentDto.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map(
                (item) =>
                    VehiclePhotoDto.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'make': make,
      'model': model,
      'year': year,
      if (vin != null) 'vin': vin,
      if (licensePlate != null) 'licensePlate': licensePlate,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (brandSlug != null) 'brandSlug': brandSlug,
      if (brandLogoUrl != null) 'brandLogoUrl': brandLogoUrl,
      if (brandLogoThumbUrl != null) 'brandLogoThumbUrl': brandLogoThumbUrl,
      'isPrimary': isPrimary,
      if (vehicleType != null) 'vehicleType': vehicleType,
      if (fuelType != null) 'fuelType': fuelType,
      if (transmission != null) 'transmission': transmission,
      if (odometerKm != null) 'odometerKm': odometerKm,
      if (lastService != null) 'lastService': lastService!.toIso8601String(),
      if (nextService != null) 'nextService': nextService!.toIso8601String(),
      if (insuranceExpiry != null)
        'insuranceExpiry': insuranceExpiry!.toIso8601String(),
      if (registrationExpiry != null)
        'registrationExpiry': registrationExpiry!.toIso8601String(),
      if (secondaryFuelType != null) 'secondaryFuelType': secondaryFuelType,
      if (fuelCapacityPrimary != null)
        'fuelCapacityPrimary': fuelCapacityPrimary,
      if (fuelCapacitySecondary != null)
        'fuelCapacitySecondary': fuelCapacitySecondary,
      if (fuelCapacityUnit != null) 'fuelCapacityUnit': fuelCapacityUnit,
      if (purchaseDate != null) 'purchaseDate': purchaseDate!.toIso8601String(),
      if (purchasePrice != null) 'purchasePrice': purchasePrice,
      if (purchaseOdometerKm != null) 'purchaseOdometerKm': purchaseOdometerKm,
      if (saleDate != null) 'saleDate': saleDate!.toIso8601String(),
      if (salePrice != null) 'salePrice': salePrice,
      if (saleOdometerKm != null) 'saleOdometerKm': saleOdometerKm,
      if (notes != null) 'notes': notes,
      if (documents.isNotEmpty)
        'documents': documents.map((doc) => doc.toJson()).toList(),
      if (photos.isNotEmpty)
        'photos': photos.map((photo) => photo.toJson()).toList(),
    };
  }

  Vehicle toDomain() {
    return Vehicle(
      id: id,
      displayName: displayName,
      make: make,
      model: model,
      year: year,
      vin: vin,
      licensePlate: licensePlate,
      photoUrl: photoUrl,
      isPrimary: isPrimary,
      brandSlug: brandSlug,
      brandLogoUrl: brandLogoUrl,
      brandLogoThumbUrl: brandLogoThumbUrl,
      vehicleType: vehicleType,
      fuelType: fuelType,
      transmission: transmission,
      odometerKm: odometerKm,
      lastService: lastService,
      nextService: nextService,
      insuranceExpiry: insuranceExpiry,
      registrationExpiry: registrationExpiry,
      secondaryFuelType: secondaryFuelType,
      fuelCapacityPrimary: fuelCapacityPrimary,
      fuelCapacitySecondary: fuelCapacitySecondary,
      fuelCapacityUnit: fuelCapacityUnit,
      purchaseDate: purchaseDate,
      purchasePrice: purchasePrice,
      purchaseOdometerKm: purchaseOdometerKm,
      saleDate: saleDate,
      salePrice: salePrice,
      saleOdometerKm: saleOdometerKm,
      notes: notes,
      documents: documents.map((doc) => doc.toDomain()).toList(),
      photos: photos.map((photo) => photo.toDomain()).toList(),
    );
  }

  factory VehicleDto.fromDomain(Vehicle vehicle) {
    return VehicleDto(
      id: vehicle.id,
      displayName: vehicle.displayName,
      make: vehicle.make,
      model: vehicle.model,
      year: vehicle.year,
      vin: vehicle.vin,
      licensePlate: vehicle.licensePlate,
      photoUrl: vehicle.photoUrl,
      brandSlug: vehicle.brandSlug,
      brandLogoUrl: vehicle.brandLogoUrl,
      brandLogoThumbUrl: vehicle.brandLogoThumbUrl,
      isPrimary: vehicle.isPrimary,
      vehicleType: vehicle.vehicleType,
      fuelType: vehicle.fuelType,
      transmission: vehicle.transmission,
      odometerKm: vehicle.odometerKm,
      lastService: vehicle.lastService,
      nextService: vehicle.nextService,
      insuranceExpiry: vehicle.insuranceExpiry,
      registrationExpiry: vehicle.registrationExpiry,
      secondaryFuelType: vehicle.secondaryFuelType,
      fuelCapacityPrimary: vehicle.fuelCapacityPrimary,
      fuelCapacitySecondary: vehicle.fuelCapacitySecondary,
      fuelCapacityUnit: vehicle.fuelCapacityUnit,
      purchaseDate: vehicle.purchaseDate,
      purchasePrice: vehicle.purchasePrice,
      purchaseOdometerKm: vehicle.purchaseOdometerKm,
      saleDate: vehicle.saleDate,
      salePrice: vehicle.salePrice,
      saleOdometerKm: vehicle.saleOdometerKm,
      notes: vehicle.notes,
      documents: vehicle.documents
          .map((doc) => VehicleDocumentDto.fromDomain(doc))
          .toList(),
      photos: vehicle.photos
          .map((photo) => VehiclePhotoDto.fromDomain(photo))
          .toList(),
    );
  }
}
