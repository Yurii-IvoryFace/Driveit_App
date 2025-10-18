import 'package:driveit_app/features/refueling/domain/fuel_type.dart';
import 'package:equatable/equatable.dart';

/// Single refueling event for a vehicle.
class RefuelingEntry extends Equatable {
  const RefuelingEntry({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.odometerKm,
    required this.volumeLiters,
    required this.totalCost,
    required this.fuelType,
    required this.isFullFill,
    this.pricePerLiter,
    this.station,
    this.notes,
  });

  final String id;
  final String vehicleId;
  final DateTime date;
  final double odometerKm;
  final double volumeLiters;
  final double totalCost;
  final double? pricePerLiter;
  final FuelType fuelType;
  final bool isFullFill;
  final String? station;
  final String? notes;

  double get effectivePricePerLiter =>
      pricePerLiter ?? (volumeLiters == 0 ? 0 : totalCost / volumeLiters);

  RefuelingEntry copyWith({
    String? id,
    String? vehicleId,
    DateTime? date,
    double? odometerKm,
    double? volumeLiters,
    double? totalCost,
    double? pricePerLiter,
    FuelType? fuelType,
    bool? isFullFill,
    String? station,
    String? notes,
  }) {
    return RefuelingEntry(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      odometerKm: odometerKm ?? this.odometerKm,
      volumeLiters: volumeLiters ?? this.volumeLiters,
      totalCost: totalCost ?? this.totalCost,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      fuelType: fuelType ?? this.fuelType,
      isFullFill: isFullFill ?? this.isFullFill,
      station: station ?? this.station,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    date,
    odometerKm,
    volumeLiters,
    totalCost,
    pricePerLiter,
    fuelType,
    isFullFill,
    station,
    notes,
  ];
}
