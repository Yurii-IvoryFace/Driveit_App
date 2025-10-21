import 'package:equatable/equatable.dart';

import 'fuel_type.dart';

class RefuelingEntry extends Equatable {
  final String id;
  final String vehicleId;
  final DateTime date;
  final double volumeLiters;
  final double pricePerLiter;
  final double totalAmount;
  final String currency;
  final int odometerKm;
  final FuelType fuelType;
  final bool isFullTank;
  final String? gasStation;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RefuelingEntry({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.volumeLiters,
    required this.pricePerLiter,
    required this.totalAmount,
    required this.currency,
    required this.odometerKm,
    required this.fuelType,
    required this.isFullTank,
    this.gasStation,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    date,
    volumeLiters,
    pricePerLiter,
    totalAmount,
    currency,
    odometerKm,
    fuelType,
    isFullTank,
    gasStation,
    notes,
    createdAt,
    updatedAt,
  ];

  RefuelingEntry copyWith({
    String? id,
    String? vehicleId,
    DateTime? date,
    double? volumeLiters,
    double? pricePerLiter,
    double? totalAmount,
    String? currency,
    int? odometerKm,
    FuelType? fuelType,
    bool? isFullTank,
    String? gasStation,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RefuelingEntry(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      volumeLiters: volumeLiters ?? this.volumeLiters,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      odometerKm: odometerKm ?? this.odometerKm,
      fuelType: fuelType ?? this.fuelType,
      isFullTank: isFullTank ?? this.isFullTank,
      gasStation: gasStation ?? this.gasStation,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
