import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/entities/refueling_entry.dart';

class ChartDataUtils {
  /// Convert transactions to line chart data for cost trends
  static List<FlSpot> getCostTrendSpots(List<Transaction> transactions) {
    if (transactions.isEmpty) return [];

    // Group by date and sum amounts
    final Map<DateTime, double> dailyCosts = {};
    for (final transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      dailyCosts[date] =
          (dailyCosts[date] ?? 0) + (transaction.amount?.toDouble() ?? 0.0);
    }

    // Sort by date (chronological order)
    final sortedDates = dailyCosts.keys.toList()..sort();

    // Convert to FlSpot format
    final spots = <FlSpot>[];
    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final cost = dailyCosts[date]!;
      spots.add(FlSpot(i.toDouble(), cost));
    }

    return spots;
  }

  /// Convert refueling entries to line chart data for fuel consumption
  static List<FlSpot> getFuelConsumptionSpots(List<RefuelingEntry> entries) {
    if (entries.length < 2) return [];

    // Sort by date
    final sortedEntries = List<RefuelingEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    for (int i = 1; i < sortedEntries.length; i++) {
      final current = sortedEntries[i];
      final previous = sortedEntries[i - 1];

      final distance = current.odometerKm - previous.odometerKm;
      if (distance > 0 && current.volumeLiters > 0) {
        final consumption = (current.volumeLiters / distance) * 100; // L/100km
        spots.add(FlSpot(i.toDouble(), consumption));
      }
    }

    return spots;
  }

  /// Convert refueling entries to line chart data for fuel volume
  static List<FlSpot> getFuelVolumeSpots(List<RefuelingEntry> entries) {
    if (entries.isEmpty) return [];

    // Sort by date
    final sortedEntries = List<RefuelingEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      spots.add(FlSpot(i.toDouble(), entry.volumeLiters));
    }

    return spots;
  }

  /// Convert refueling entries to line chart data for fuel price
  static List<FlSpot> getFuelPriceSpots(List<RefuelingEntry> entries) {
    if (entries.isEmpty) return [];

    // Sort by date
    final sortedEntries = List<RefuelingEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      spots.add(FlSpot(i.toDouble(), entry.pricePerLiter));
    }

    return spots;
  }

  /// Convert refueling entries to line chart data for odometer trend
  static List<FlSpot> getOdometerTrendSpots(List<RefuelingEntry> entries) {
    if (entries.isEmpty) return [];

    // Sort by date
    final sortedEntries = List<RefuelingEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      spots.add(FlSpot(i.toDouble(), entry.odometerKm.toDouble()));
    }

    return spots;
  }

  /// Convert transactions to line chart data for odometer trend (all transactions with odometer)
  static List<FlSpot> getOdometerTrendSpotsFromTransactions(
    List<Transaction> transactions,
  ) {
    if (transactions.isEmpty) return [];

    // Filter transactions that have odometer readings and sort by date
    final odometerTransactions =
        transactions.where((t) => t.odometerKm != null).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    for (int i = 0; i < odometerTransactions.length; i++) {
      final transaction = odometerTransactions[i];
      spots.add(FlSpot(i.toDouble(), transaction.odometerKm!.toDouble()));
    }

    return spots;
  }

  /// Convert refueling entries to line chart data for distance between refuelings
  static List<FlSpot> getDistanceSpots(List<RefuelingEntry> entries) {
    if (entries.length < 2) return [];

    // Sort by date
    final sortedEntries = List<RefuelingEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    for (int i = 1; i < sortedEntries.length; i++) {
      final distance =
          sortedEntries[i].odometerKm - sortedEntries[i - 1].odometerKm;
      spots.add(FlSpot(i.toDouble(), distance.toDouble()));
    }

    return spots;
  }

  /// Convert transactions to line chart data for distance between transactions with odometer
  static List<FlSpot> getDistanceSpotsFromTransactions(
    List<Transaction> transactions,
  ) {
    // Filter transactions that have odometer readings
    final odometerTransactions = transactions
        .where((t) => t.odometerKm != null)
        .toList();

    if (odometerTransactions.length < 2) return [];

    // Sort by date
    final sortedTransactions = List<Transaction>.from(odometerTransactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    for (int i = 1; i < sortedTransactions.length; i++) {
      final distance =
          sortedTransactions[i].odometerKm! -
          sortedTransactions[i - 1].odometerKm!;
      spots.add(FlSpot(i.toDouble(), distance.toDouble()));
    }

    return spots;
  }

  /// Convert transactions to pie chart data by type
  static List<PieChartSectionData> getTransactionTypePieData(
    List<Transaction> transactions,
  ) {
    if (transactions.isEmpty) return [];

    final Map<String, double> typeTotals = {};
    for (final transaction in transactions) {
      final type = _getTransactionTypeName(transaction.type);
      typeTotals[type] =
          (typeTotals[type] ?? 0) + (transaction.amount?.toDouble() ?? 0.0);
    }

    final sections = <PieChartSectionData>[];
    final colors = [
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFFF44336), // Red
      const Color(0xFF9C27B0), // Purple
    ];

    int colorIndex = 0;
    typeTotals.forEach((type, amount) {
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: amount,
          title: type,
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return sections;
  }

  /// Format currency for display
  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)}₴';
  }

  /// Format fuel consumption for display
  static String formatFuelConsumption(double consumption) {
    return '${consumption.toStringAsFixed(1)} л/100км';
  }

  /// Format distance for display
  static String formatDistance(double distance) {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)}К км';
    } else {
      return '${distance.toStringAsFixed(0)} км';
    }
  }

  /// Calculate average fuel consumption from refueling entries
  static double calculateAverageFuelConsumption(List<RefuelingEntry> entries) {
    if (entries.length < 2) return 0.0;

    // Sort by date
    final sortedEntries = List<RefuelingEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    double totalConsumption = 0.0;
    int validCalculations = 0;

    for (int i = 1; i < sortedEntries.length; i++) {
      final current = sortedEntries[i];
      final previous = sortedEntries[i - 1];

      final distance = current.odometerKm - previous.odometerKm;
      final fuel = current.volumeLiters;

      if (distance > 0 && fuel > 0) {
        final consumption = (fuel * 100) / distance; // L/100km
        totalConsumption += consumption;
        validCalculations++;
      }
    }

    return validCalculations > 0 ? totalConsumption / validCalculations : 0.0;
  }

  /// Convert transactions to bar chart data for monthly costs
  static List<BarChartGroupData> getMonthlyCostsBarData(
    List<Transaction> transactions,
  ) {
    if (transactions.isEmpty) return [];

    // Group by month
    final Map<String, double> monthlyCosts = {};
    for (final transaction in transactions) {
      final monthKey =
          '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
      monthlyCosts[monthKey] =
          (monthlyCosts[monthKey] ?? 0) +
          (transaction.amount?.toDouble() ?? 0.0);
    }

    // Sort by month
    final sortedMonths = monthlyCosts.keys.toList()..sort();

    // Convert to BarChartGroupData format
    final barGroups = <BarChartGroupData>[];
    final colors = [
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFFF44336), // Red
      const Color(0xFF9C27B0), // Purple
    ];

    for (int i = 0; i < sortedMonths.length; i++) {
      final month = sortedMonths[i];
      final cost = monthlyCosts[month]!;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: cost,
              color: colors[i % colors.length],
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return barGroups;
  }

  /// Convert transactions to bar chart data for costs by category
  static List<BarChartGroupData> getCostsByCategoryBarData(
    List<Transaction> transactions,
  ) {
    if (transactions.isEmpty) return [];

    // Group by category
    final Map<String, double> categoryCosts = {};
    for (final transaction in transactions) {
      final category = _getTransactionTypeName(transaction.type);
      categoryCosts[category] =
          (categoryCosts[category] ?? 0) +
          (transaction.amount?.toDouble() ?? 0.0);
    }

    // Sort by cost (descending)
    final sortedCategories = categoryCosts.keys.toList()
      ..sort((a, b) => categoryCosts[b]!.compareTo(categoryCosts[a]!));

    // Convert to BarChartGroupData format
    final barGroups = <BarChartGroupData>[];
    final colors = [
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFFF44336), // Red
      const Color(0xFF9C27B0), // Purple
    ];

    for (int i = 0; i < sortedCategories.length; i++) {
      final category = sortedCategories[i];
      final cost = categoryCosts[category]!;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: cost,
              color: colors[i % colors.length],
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return barGroups;
  }

  /// Get Ukrainian name for transaction type
  static String _getTransactionTypeName(TransactionType? type) {
    if (type == null) return 'Інше';

    switch (type) {
      case TransactionType.refueling:
        return 'Заправка';
      case TransactionType.maintenance:
        return 'Обслуговування';
      case TransactionType.insurance:
        return 'Страхування';
      case TransactionType.parking:
        return 'Парковка';
      case TransactionType.toll:
        return 'Плата за дорогу';
      case TransactionType.carWash:
        return 'Мийка';
      case TransactionType.other:
        return 'Інше';
    }
  }
}
