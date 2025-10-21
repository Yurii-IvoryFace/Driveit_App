import 'package:equatable/equatable.dart';

enum TransactionType {
  refueling,
  maintenance,
  insurance,
  parking,
  toll,
  carWash,
  other,
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.refueling:
        return 'Refueling';
      case TransactionType.maintenance:
        return 'Maintenance';
      case TransactionType.insurance:
        return 'Insurance';
      case TransactionType.parking:
        return 'Parking';
      case TransactionType.toll:
        return 'Toll';
      case TransactionType.carWash:
        return 'Car Wash';
      case TransactionType.other:
        return 'Other';
    }
  }
}

class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.date,
    this.amount,
    this.currency,
    this.odometerKm,
    this.volumeLiters,
    this.pricePerLiter,
    this.fuelType,
    this.isFullTank,
    this.serviceType,
    this.serviceProvider,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String vehicleId;
  final TransactionType type;
  final DateTime date;
  final double? amount;
  final String? currency;
  final int? odometerKm;

  // Refueling specific
  final double? volumeLiters;
  final double? pricePerLiter;
  final String? fuelType;
  final bool? isFullTank;

  // Service specific
  final String? serviceType;
  final String? serviceProvider;

  // Common
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    type,
    date,
    amount,
    currency,
    odometerKm,
    volumeLiters,
    pricePerLiter,
    fuelType,
    isFullTank,
    serviceType,
    serviceProvider,
    notes,
    createdAt,
    updatedAt,
  ];
}
