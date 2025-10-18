import 'package:driveit_app/features/vehicles/domain/vehicle_document.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_photo.dart';
import 'package:equatable/equatable.dart';

const Object _unset = Object();

/// Domain entity representing a tracked vehicle.
class Vehicle extends Equatable {
  const Vehicle({
    required this.id,
    required this.displayName,
    required this.make,
    required this.model,
    required this.year,
    this.vin,
    this.licensePlate,
    this.photoUrl,
    this.isPrimary = false,
    this.brandSlug,
    this.brandLogoUrl,
    this.brandLogoThumbUrl,
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

  /// Unique identifier generated locally; replace with server ID later.
  final String id;
  final String displayName;
  final String make;
  final String model;
  final int year;
  final String? vin;
  final String? licensePlate;
  final String? photoUrl;
  final bool isPrimary;
  final String? brandSlug;
  final String? brandLogoUrl;
  final String? brandLogoThumbUrl;
  final List<VehiclePhoto> photos;
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
  final List<VehicleDocument> documents;

  Vehicle copyWith({
    String? id,
    String? displayName,
    String? make,
    String? model,
    int? year,
    String? vin,
    String? licensePlate,
    Object? photoUrl = _unset,
    bool? isPrimary,
    List<VehicleDocument>? documents,
    List<VehiclePhoto>? photos,
    String? brandSlug,
    Object? brandLogoUrl = _unset,
    Object? brandLogoThumbUrl = _unset,
    String? vehicleType,
    String? fuelType,
    String? transmission,
    int? odometerKm,
    DateTime? lastService,
    DateTime? nextService,
    DateTime? insuranceExpiry,
    DateTime? registrationExpiry,
    String? secondaryFuelType,
    double? fuelCapacityPrimary,
    double? fuelCapacitySecondary,
    String? fuelCapacityUnit,
    DateTime? purchaseDate,
    double? purchasePrice,
    int? purchaseOdometerKm,
    DateTime? saleDate,
    double? salePrice,
    int? saleOdometerKm,
    String? notes,
  }) {
    return Vehicle(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      licensePlate: licensePlate ?? this.licensePlate,
      photoUrl: photoUrl == _unset ? this.photoUrl : photoUrl as String?,
      isPrimary: isPrimary ?? this.isPrimary,
      documents: documents ?? this.documents,
      photos: photos ?? this.photos,
      brandSlug: brandSlug ?? this.brandSlug,
      brandLogoUrl: brandLogoUrl == _unset
          ? this.brandLogoUrl
          : brandLogoUrl as String?,
      brandLogoThumbUrl: brandLogoThumbUrl == _unset
          ? this.brandLogoThumbUrl
          : brandLogoThumbUrl as String?,
      vehicleType: vehicleType ?? this.vehicleType,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      odometerKm: odometerKm ?? this.odometerKm,
      lastService: lastService ?? this.lastService,
      nextService: nextService ?? this.nextService,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      registrationExpiry: registrationExpiry ?? this.registrationExpiry,
      secondaryFuelType: secondaryFuelType ?? this.secondaryFuelType,
      fuelCapacityPrimary: fuelCapacityPrimary ?? this.fuelCapacityPrimary,
      fuelCapacitySecondary:
          fuelCapacitySecondary ?? this.fuelCapacitySecondary,
      fuelCapacityUnit: fuelCapacityUnit ?? this.fuelCapacityUnit,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseOdometerKm: purchaseOdometerKm ?? this.purchaseOdometerKm,
      saleDate: saleDate ?? this.saleDate,
      salePrice: salePrice ?? this.salePrice,
      saleOdometerKm: saleOdometerKm ?? this.saleOdometerKm,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    displayName,
    make,
    model,
    year,
    vin,
    licensePlate,
    photoUrl,
    isPrimary,
    documents,
    photos,
    brandSlug,
    brandLogoUrl,
    brandLogoThumbUrl,
    vehicleType,
    fuelType,
    transmission,
    odometerKm,
    lastService,
    nextService,
    insuranceExpiry,
    registrationExpiry,
    secondaryFuelType,
    fuelCapacityPrimary,
    fuelCapacitySecondary,
    fuelCapacityUnit,
    purchaseDate,
    purchasePrice,
    purchaseOdometerKm,
    saleDate,
    salePrice,
    saleOdometerKm,
    notes,
  ];
}
