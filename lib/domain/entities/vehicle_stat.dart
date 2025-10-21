import 'package:equatable/equatable.dart';

class VehicleStat extends Equatable {
  const VehicleStat({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.value,
    this.unit,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String vehicleId;
  final VehicleStatType type;
  final String value;
  final String? unit;
  final String? notes;
  final DateTime createdAt;

  VehicleStat copyWith({
    String? id,
    String? vehicleId,
    VehicleStatType? type,
    String? value,
    String? unit,
    String? notes,
    DateTime? createdAt,
  }) {
    return VehicleStat(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    type,
    value,
    unit,
    notes,
    createdAt,
  ];
}

enum VehicleStatType {
  odometer,
  lastService,
  nextService,
  insuranceExpiry,
  registrationExpiry,
  purchaseDate,
  saleDate,
  custom;

  String get displayName {
    switch (this) {
      case VehicleStatType.odometer:
        return 'Odometer';
      case VehicleStatType.lastService:
        return 'Last Service';
      case VehicleStatType.nextService:
        return 'Next Service';
      case VehicleStatType.insuranceExpiry:
        return 'Insurance Expiry';
      case VehicleStatType.registrationExpiry:
        return 'Registration Expiry';
      case VehicleStatType.purchaseDate:
        return 'Purchase Date';
      case VehicleStatType.saleDate:
        return 'Sale Date';
      case VehicleStatType.custom:
        return 'Custom';
    }
  }
}

extension VehicleStatTypeExtension on VehicleStatType {
  String get defaultUnit {
    switch (this) {
      case VehicleStatType.odometer:
        return 'km';
      case VehicleStatType.lastService:
      case VehicleStatType.nextService:
      case VehicleStatType.insuranceExpiry:
      case VehicleStatType.registrationExpiry:
      case VehicleStatType.purchaseDate:
      case VehicleStatType.saleDate:
        return '';
      case VehicleStatType.custom:
        return '';
    }
  }
}
