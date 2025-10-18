import 'dart:math';

import 'package:driveit_app/features/refueling/domain/refueling_entry.dart';
import 'package:driveit_app/features/refueling/domain/refueling_summary.dart';

/// Utility to compute analytics from refueling entries.
class RefuelingCalculator {
  const RefuelingCalculator._();

  static RefuelingSummary buildSummary(List<RefuelingEntry> entries) {
    if (entries.isEmpty) {
      return RefuelingSummary.empty;
    }

    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));

    final totalVolume = sorted.fold<double>(
      0,
      (acc, entry) => acc + entry.volumeLiters,
    );
    final totalCost = sorted.fold<double>(
      0,
      (acc, entry) => acc + entry.totalCost,
    );

    var totalDistance = 0.0;
    var fuelUsedForConsumption = 0.0;
    for (var i = 1; i < sorted.length; i++) {
      final previous = sorted[i - 1];
      final current = sorted[i];
      if (!current.isFullFill) continue;
      final distance = current.odometerKm - previous.odometerKm;
      if (distance > 0) {
        totalDistance += distance;
        fuelUsedForConsumption += current.volumeLiters;
      }
    }

    final averageConsumption = totalDistance > 0
        ? (fuelUsedForConsumption / totalDistance) * 100
        : 0.0;
    final averagePricePerLiter = totalVolume > 0
        ? totalCost / totalVolume
        : 0.0;
    final costPerKilometer = totalDistance > 0
        ? totalCost / totalDistance
        : 0.0;
    final timeframeDays = max(
      1,
      sorted.last.date.difference(sorted.first.date).inDays,
    );

    return RefuelingSummary(
      totalVolumeLiters: totalVolume,
      totalCost: totalCost,
      averagePricePerLiter: averagePricePerLiter,
      averageConsumptionPer100km: averageConsumption,
      costPerKilometer: costPerKilometer,
      totalDistanceKm: totalDistance,
      fillUps: sorted.length,
      timeframeDays: timeframeDays,
    );
  }
}
