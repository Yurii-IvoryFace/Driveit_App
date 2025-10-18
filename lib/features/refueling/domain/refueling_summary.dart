import 'package:equatable/equatable.dart';

/// Aggregated metrics derived from refueling entries.
class RefuelingSummary extends Equatable {
  const RefuelingSummary({
    required this.totalVolumeLiters,
    required this.totalCost,
    required this.averagePricePerLiter,
    required this.averageConsumptionPer100km,
    required this.costPerKilometer,
    required this.totalDistanceKm,
    required this.fillUps,
    required this.timeframeDays,
  });

  final double totalVolumeLiters;
  final double totalCost;
  final double averagePricePerLiter;
  final double averageConsumptionPer100km;
  final double costPerKilometer;
  final double totalDistanceKm;
  final int fillUps;
  final int timeframeDays;

  static const empty = RefuelingSummary(
    totalVolumeLiters: 0,
    totalCost: 0,
    averagePricePerLiter: 0,
    averageConsumptionPer100km: 0,
    costPerKilometer: 0,
    totalDistanceKm: 0,
    fillUps: 0,
    timeframeDays: 0,
  );

  @override
  List<Object?> get props => [
    totalVolumeLiters,
    totalCost,
    averagePricePerLiter,
    averageConsumptionPer100km,
    costPerKilometer,
    totalDistanceKm,
    fillUps,
    timeframeDays,
  ];
}
