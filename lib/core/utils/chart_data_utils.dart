import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/entities/refueling_entry.dart';

class ChartDataUtils {
  /// Convert transactions to line chart data for cost trends
  static List<FlSpot> getCostTrendSpots(List<Transaction> transactions) {
    if (transactions.isEmpty) return [];

    // Group by date and sum amounts
    final Map<String, double> dailyCosts = {};
    for (final transaction in transactions) {
      final dateKey =
          '${transaction.date.year}-${transaction.date.month}-${transaction.date.day}';
      dailyCosts[dateKey] =
          (dailyCosts[dateKey] ?? 0) + (transaction.amount?.toDouble() ?? 0.0);
    }

    // Convert to FlSpot format
    final spots = <FlSpot>[];
    int index = 0;
    for (final entry in dailyCosts.entries) {
      spots.add(FlSpot(index.toDouble(), entry.value));
      index++;
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

  /// Convert transactions to pie chart data by type
  static List<PieChartSectionData> getTransactionTypePieData(
    List<Transaction> transactions,
  ) {
    if (transactions.isEmpty) return [];

    // Group by type and sum amounts
    final Map<TransactionType, double> typeAmounts = {};
    for (final transaction in transactions) {
      if (transaction.amount != null) {
        typeAmounts[transaction.type] =
            (typeAmounts[transaction.type] ?? 0) +
            transaction.amount!.toDouble();
      }
    }

    final total = typeAmounts.values.fold(0.0, (sum, amount) => sum + amount);
    if (total == 0) return [];

    final colors = [
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFF44336), // Red
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF795548), // Brown
    ];

    final sections = <PieChartSectionData>[];
    int colorIndex = 0;

    for (final entry in typeAmounts.entries) {
      final percentage = (entry.value / total) * 100;
      if (percentage > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[colorIndex % colors.length],
            value: percentage,
            title:
                '${entry.key.displayName}\n${percentage.toStringAsFixed(1)}%',
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
        colorIndex++;
      }
    }

    return sections;
  }

  /// Convert transactions to bar chart data for monthly costs
  static List<BarChartGroupData> getMonthlyCostBars(
    List<Transaction> transactions,
  ) {
    if (transactions.isEmpty) return [];

    // Group by month
    final Map<String, double> monthlyCosts = {};
    for (final transaction in transactions) {
      final monthKey = '${transaction.date.year}-${transaction.date.month}';
      monthlyCosts[monthKey] =
          (monthlyCosts[monthKey] ?? 0) +
          (transaction.amount?.toDouble() ?? 0.0);
    }

    // Convert to BarChartGroupData
    final bars = <BarChartGroupData>[];
    int index = 0;
    for (final entry in monthlyCosts.entries) {
      bars.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: entry.value,
              color: const Color(0xFF2196F3),
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
      index++;
    }

    return bars;
  }

  /// Get fuel efficiency trend data
  static List<FlSpot> getFuelEfficiencyTrend(List<RefuelingEntry> entries) {
    if (entries.length < 2) return [];

    final sortedEntries = List<RefuelingEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    for (int i = 1; i < sortedEntries.length; i++) {
      final current = sortedEntries[i];
      final previous = sortedEntries[i - 1];

      final distance = current.odometerKm - previous.odometerKm;
      if (distance > 0 && current.volumeLiters > 0) {
        final efficiency = (current.volumeLiters / distance) * 100; // L/100km
        spots.add(FlSpot(i.toDouble(), efficiency));
      }
    }

    return spots;
  }

  /// Get odometer reading trend
  static List<FlSpot> getOdometerTrend(List<RefuelingEntry> entries) {
    if (entries.isEmpty) return [];

    final sortedEntries = List<RefuelingEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    for (int i = 0; i < sortedEntries.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedEntries[i].odometerKm.toDouble()));
    }

    return spots;
  }

  /// Calculate average fuel consumption
  static double calculateAverageFuelConsumption(List<RefuelingEntry> entries) {
    if (entries.length < 2) return 0.0;

    final sortedEntries = List<RefuelingEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    double totalConsumption = 0.0;
    int validEntries = 0;

    for (int i = 1; i < sortedEntries.length; i++) {
      final current = sortedEntries[i];
      final previous = sortedEntries[i - 1];

      final distance = current.odometerKm - previous.odometerKm;
      if (distance > 0 && current.volumeLiters > 0) {
        final consumption = (current.volumeLiters / distance) * 100; // L/100km
        totalConsumption += consumption;
        validEntries++;
      }
    }

    return validEntries > 0 ? totalConsumption / validEntries : 0.0;
  }

  /// Calculate total costs by category
  static Map<TransactionType, double> getCostsByCategory(
    List<Transaction> transactions,
  ) {
    final Map<TransactionType, double> costs = {};

    for (final transaction in transactions) {
      if (transaction.amount != null) {
        costs[transaction.type] =
            (costs[transaction.type] ?? 0) + transaction.amount!.toDouble();
      }
    }

    return costs;
  }

  /// Get monthly cost summary
  static Map<String, double> getMonthlyCostSummary(
    List<Transaction> transactions,
  ) {
    final Map<String, double> monthlyCosts = {};

    for (final transaction in transactions) {
      final monthKey =
          '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
      monthlyCosts[monthKey] =
          (monthlyCosts[monthKey] ?? 0) +
          (transaction.amount?.toDouble() ?? 0.0);
    }

    return monthlyCosts;
  }

  /// Format currency for display
  static String formatCurrency(double amount, {String currency = '₴'}) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M $currency';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K $currency';
    } else {
      return '${amount.toStringAsFixed(0)} $currency';
    }
  }

  /// Format fuel consumption for display
  static String formatFuelConsumption(double consumption) {
    return '${consumption.toStringAsFixed(1)} L/100km';
  }

  /// Format distance for display
  static String formatDistance(double distance) {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)}K km';
    } else {
      return '${distance.toStringAsFixed(0)} km';
    }
  }
}
