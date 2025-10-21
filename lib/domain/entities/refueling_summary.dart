import 'package:equatable/equatable.dart';

class RefuelingSummary extends Equatable {
  final String vehicleId;
  final int totalRefuelings;
  final double totalVolumeLiters;
  final double totalAmount;
  final String currency;
  final double averagePricePerLiter;
  final double averageVolumePerRefueling;
  final double averageAmountPerRefueling;
  final double fuelEfficiency; // L/100km
  final double totalDistanceKm;
  final DateTime? lastRefuelingDate;
  final DateTime? firstRefuelingDate;
  final double? bestEfficiency; // Best L/100km
  final double? worstEfficiency; // Worst L/100km
  final double averageEfficiency; // Average L/100km

  const RefuelingSummary({
    required this.vehicleId,
    required this.totalRefuelings,
    required this.totalVolumeLiters,
    required this.totalAmount,
    required this.currency,
    required this.averagePricePerLiter,
    required this.averageVolumePerRefueling,
    required this.averageAmountPerRefueling,
    required this.fuelEfficiency,
    required this.totalDistanceKm,
    this.lastRefuelingDate,
    this.firstRefuelingDate,
    this.bestEfficiency,
    this.worstEfficiency,
    required this.averageEfficiency,
  });

  @override
  List<Object?> get props => [
    vehicleId,
    totalRefuelings,
    totalVolumeLiters,
    totalAmount,
    currency,
    averagePricePerLiter,
    averageVolumePerRefueling,
    averageAmountPerRefueling,
    fuelEfficiency,
    totalDistanceKm,
    lastRefuelingDate,
    firstRefuelingDate,
    bestEfficiency,
    worstEfficiency,
    averageEfficiency,
  ];

  /// Calculate fuel efficiency between two refueling entries
  static double calculateEfficiency({
    required int previousOdometer,
    required int currentOdometer,
    required double volumeLiters,
  }) {
    final distanceKm = currentOdometer - previousOdometer;
    if (distanceKm <= 0 || volumeLiters <= 0) return 0.0;

    return (volumeLiters / distanceKm) * 100; // L/100km
  }

  /// Calculate total distance from first to last refueling
  static double calculateTotalDistance({
    required int firstOdometer,
    required int lastOdometer,
  }) {
    return (lastOdometer - firstOdometer).toDouble();
  }

  /// Calculate average efficiency from multiple efficiency values
  static double calculateAverageEfficiency(List<double> efficiencies) {
    if (efficiencies.isEmpty) return 0.0;

    final validEfficiencies = efficiencies.where((e) => e > 0).toList();
    if (validEfficiencies.isEmpty) return 0.0;

    return validEfficiencies.reduce((a, b) => a + b) / validEfficiencies.length;
  }
}
