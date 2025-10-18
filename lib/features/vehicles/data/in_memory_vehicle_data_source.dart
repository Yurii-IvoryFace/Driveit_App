import 'dart:async';

import 'package:driveit_app/features/vehicles/data/dto/vehicle_document_dto.dart';
import 'package:driveit_app/features/vehicles/data/dto/vehicle_dto.dart';
import 'package:driveit_app/features/vehicles/data/dto/vehicle_photo_dto.dart';
import 'package:driveit_app/features/vehicles/data/vehicle_local_data_source.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_document.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_photo.dart';
import 'package:uuid/uuid.dart';

/// In-memory data source used as a placeholder until a real backend is ready.
class InMemoryVehicleDataSource implements VehicleLocalDataSource {
  InMemoryVehicleDataSource({List<VehicleDto>? seed})
    : _controller = StreamController<List<VehicleDto>>.broadcast() {
    _vehicles =
        seed ??
        [
          VehicleDto(
            id: _uuid.v4(),
            displayName: 'Daily Driver',
            make: 'Toyota',
            model: 'Corolla',
            year: 2019,
            licensePlate: 'AA1234BB',
            isPrimary: true,
            photoUrl:
                'https://images.unsplash.com/photo-1517948430535-1e2469d3147c?auto=format&fit=crop&w=900&q=80',
            vehicleType: 'Passenger',
            fuelType: 'Petrol',
            transmission: 'Automatic',
            odometerKm: 182340,
            lastService: DateTime.now().subtract(const Duration(days: 38)),
            nextService: DateTime.now().add(const Duration(days: 120)),
            insuranceExpiry: DateTime.now().add(const Duration(days: 210)),
            registrationExpiry: DateTime.now().add(const Duration(days: 320)),
            documents: [
              VehicleDocumentDto(
                id: _uuid.v4(),
                title: 'Insurance Policy 2025',
                category: VehicleDocumentCategory.insurance.name,
                url: 'https://example.com/docs/insurance-policy.pdf',
                uploadedAt: DateTime.now().subtract(const Duration(days: 14)),
                notes: 'AXA coverage valid through next renewal.',
              ),
              VehicleDocumentDto(
                id: _uuid.v4(),
                title: 'Registration Renewal',
                category: VehicleDocumentCategory.registration.name,
                url: 'https://example.com/docs/registration.pdf',
                uploadedAt: DateTime.now().subtract(const Duration(days: 50)),
              ),
            ],
            photos: [
              VehiclePhotoDto(
                id: _uuid.v4(),
                url:
                    'https://images.unsplash.com/photo-1503377989598-769c84f986c5?auto=format&fit=crop&w=900&q=80',
                category: VehiclePhotoCategory.exterior.name,
                addedAt: DateTime.now().subtract(const Duration(days: 12)),
              ),
              VehiclePhotoDto(
                id: _uuid.v4(),
                url:
                    'https://images.unsplash.com/photo-1471478331149-c72f17e33c73?auto=format&fit=crop&w=900&q=80',
                category: VehiclePhotoCategory.maintenance.name,
                addedAt: DateTime.now().subtract(const Duration(days: 30)),
              ),
              VehiclePhotoDto(
                id: _uuid.v4(),
                url:
                    'https://images.unsplash.com/photo-1523983254932-9abfd9991124?auto=format&fit=crop&w=900&q=80',
                category: VehiclePhotoCategory.documents.name,
                addedAt: DateTime.now().subtract(const Duration(days: 45)),
              ),
            ],
          ),
          VehicleDto(
            id: _uuid.v4(),
            displayName: 'Weekend Ride',
            make: 'Mazda',
            model: 'MX-5',
            year: 2016,
            photoUrl:
                'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&w=900&q=80',
            vehicleType: 'Passenger',
            fuelType: 'Petrol',
            transmission: 'Manual',
            odometerKm: 78210,
            lastService: DateTime.now().subtract(const Duration(days: 90)),
            nextService: DateTime.now().add(const Duration(days: 180)),
            insuranceExpiry: DateTime.now().add(const Duration(days: 140)),
            registrationExpiry: DateTime.now().add(const Duration(days: 200)),
            documents: [
              VehicleDocumentDto(
                id: _uuid.v4(),
                title: 'Purchase Invoice',
                category: VehicleDocumentCategory.purchase.name,
                url: 'https://example.com/docs/invoice.pdf',
                uploadedAt: DateTime.now().subtract(const Duration(days: 400)),
              ),
            ],
            photos: [
              VehiclePhotoDto(
                id: _uuid.v4(),
                url:
                    'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=900&q=80',
                category: VehiclePhotoCategory.exterior.name,
                addedAt: DateTime.now().subtract(const Duration(days: 7)),
              ),
              VehiclePhotoDto(
                id: _uuid.v4(),
                url:
                    'https://images.unsplash.com/photo-1617813489486-987a87c4a023?auto=format&fit=crop&w=900&q=80',
                category: VehiclePhotoCategory.interior.name,
                addedAt: DateTime.now().subtract(const Duration(days: 15)),
              ),
            ],
          ),
        ];
    _controller.onListen = _emit;
  }

  final _uuid = const Uuid();
  late List<VehicleDto> _vehicles;
  final StreamController<List<VehicleDto>> _controller;

  List<VehicleDto> get currentSnapshot =>
      List<VehicleDto>.unmodifiable(_vehicles);

  @override
  Stream<List<VehicleDto>> watchAll() => _controller.stream;

  @override
  Future<List<VehicleDto>> getAll() async =>
      List<VehicleDto>.unmodifiable(_vehicles);

  @override
  Future<void> upsert(VehicleDto dto) async {
    final existingIndex = _vehicles.indexWhere(
      (element) => element.id == dto.id,
    );
    if (existingIndex == -1) {
      _vehicles = [..._vehicles, dto];
    } else {
      _vehicles = [
        ..._vehicles.sublist(0, existingIndex),
        dto,
        ..._vehicles.sublist(existingIndex + 1),
      ];
    }
    _emit();
  }

  @override
  Future<void> remove(String id) async {
    _vehicles = _vehicles.where((vehicle) => vehicle.id != id).toList();
    _emit();
  }

  @override
  Future<void> markPrimary(String id) async {
    _vehicles = _vehicles
        .map((vehicle) => vehicle.copyWith(isPrimary: vehicle.id == id))
        .toList();
    _emit();
  }

  /// Helper for UI forms to generate an ID without hitting a backend yet.
  VehicleDto createDraft({
    required String displayName,
    required String make,
    required String model,
    required int year,
    String? vin,
    String? licensePlate,
    String? brandSlug,
    String? brandLogoUrl,
    String? brandLogoThumbUrl,
    String? fuelType,
    String? secondaryFuelType,
    String? transmission,
    int? odometerKm,
    DateTime? nextService,
    DateTime? insuranceExpiry,
    DateTime? registrationExpiry,
    String? vehicleType,
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
    List<VehicleDocumentDto> documents = const [],
    List<VehiclePhotoDto> photos = const [],
  }) {
    return VehicleDto(
      id: _uuid.v4(),
      displayName: displayName,
      make: make,
      model: model,
      year: year,
      vin: vin,
      licensePlate: licensePlate,
      brandSlug: brandSlug,
      brandLogoUrl: brandLogoUrl,
      brandLogoThumbUrl: brandLogoThumbUrl,
      vehicleType: vehicleType,
      fuelType: fuelType,
      secondaryFuelType: secondaryFuelType,
      transmission: transmission,
      odometerKm: odometerKm,
      nextService: nextService,
      insuranceExpiry: insuranceExpiry,
      registrationExpiry: registrationExpiry,
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
      documents: documents,
      photos: photos,
    );
  }

  void dispose() {
    _controller.close();
  }

  void _emit() {
    scheduleMicrotask(() {
      if (_controller.isClosed) return;
      _controller.add(List.unmodifiable(_vehicles));
    });
  }
}

extension on VehicleDto {
  VehicleDto copyWith({
    String? id,
    String? displayName,
    String? make,
    String? model,
    int? year,
    String? vin,
    String? licensePlate,
    String? photoUrl,
    String? brandSlug,
    String? brandLogoUrl,
    String? brandLogoThumbUrl,
    bool? isPrimary,
    List<VehicleDocumentDto>? documents,
    List<VehiclePhotoDto>? photos,
    String? vehicleType,
    String? fuelType,
    String? secondaryFuelType,
    String? transmission,
    int? odometerKm,
    DateTime? lastService,
    DateTime? nextService,
    DateTime? insuranceExpiry,
    DateTime? registrationExpiry,
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
    return VehicleDto(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      licensePlate: licensePlate ?? this.licensePlate,
      photoUrl: photoUrl ?? this.photoUrl,
      brandSlug: brandSlug ?? this.brandSlug,
      brandLogoUrl: brandLogoUrl ?? this.brandLogoUrl,
      brandLogoThumbUrl: brandLogoThumbUrl ?? this.brandLogoThumbUrl,
      isPrimary: isPrimary ?? this.isPrimary,
      documents: documents ?? this.documents,
      photos: photos ?? this.photos,
      vehicleType: vehicleType ?? this.vehicleType,
      fuelType: fuelType ?? this.fuelType,
      secondaryFuelType: secondaryFuelType ?? this.secondaryFuelType,
      transmission: transmission ?? this.transmission,
      odometerKm: odometerKm ?? this.odometerKm,
      lastService: lastService ?? this.lastService,
      nextService: nextService ?? this.nextService,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      registrationExpiry: registrationExpiry ?? this.registrationExpiry,
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
}
