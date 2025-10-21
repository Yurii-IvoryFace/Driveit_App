import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_colors.dart';

class UniversalBarChartWidget extends StatelessWidget {
  final List<BarChartGroupData> barGroups;
  final String title;
  final String yAxisLabel;
  final String xAxisLabel;
  final Color? barColor;
  final bool showGrid;
  final double? minY;
  final double? maxY;
  final double? height;
  final int? targetLabels;

  const UniversalBarChartWidget({
    super.key,
    required this.barGroups,
    required this.title,
    required this.yAxisLabel,
    required this.xAxisLabel,
    this.barColor,
    this.showGrid = true,
    this.minY,
    this.maxY,
    this.height = 200,
    this.targetLabels = 5,
  });

  double _calculateOptimalInterval() {
    if (barGroups.isEmpty) return 1;

    final maxYValue = barGroups
        .map((e) => e.barRods.first.toY)
        .reduce((a, b) => a > b ? a : b);
    final minYValue = minY ?? 0;
    final range = maxYValue - minYValue;

    // Handle edge case where range is 0 (all values are the same)
    if (range == 0) {
      // For single value, show labels at 20%, 40%, 60%, 80%, 100% of the value
      return _roundToNiceNumber(maxYValue * 0.2);
    }

    // Calculate optimal interval to show target number of labels
    final rawInterval = range / targetLabels!;

    // Round to nice numbers using logarithmic scaling
    return _roundToNiceNumber(rawInterval);
  }

  /// Rounds a number to a nice, human-readable interval
  double _roundToNiceNumber(double value) {
    if (value <= 0) return 1;

    // Calculate the order of magnitude
    final magnitude = _getMagnitude(value);
    final normalized = value / magnitude;

    // Round to nice numbers: 1, 2, 5, 10, 20, 50, 100, etc.
    double niceNumber;
    if (normalized <= 1.5) {
      niceNumber = 1;
    } else if (normalized <= 3) {
      niceNumber = 2;
    } else if (normalized <= 7) {
      niceNumber = 5;
    } else {
      niceNumber = 10;
    }

    return niceNumber * magnitude;
  }

  /// Gets the order of magnitude (10^n) for a given value
  double _getMagnitude(double value) {
    if (value == 0) return 1;
    return math.pow(10, math.log(value) / math.ln10).floor().toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: height,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    maxY ??
                    (barGroups.isNotEmpty
                        ? barGroups
                                  .map((e) => e.barRods.first.toY)
                                  .reduce((a, b) => a > b ? a : b) *
                              1.1
                        : 10),
                gridData: showGrid
                    ? FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _calculateOptimalInterval(),
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppColors.border.withValues(alpha: 0.3),
                            strokeWidth: 1,
                          );
                        },
                      )
                    : FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt() + 1}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _calculateOptimalInterval(),
                      reservedSize:
                          50, // Increased to give more space for labels
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Text(
                            value.toStringAsFixed(0),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize:
                                      10, // Smaller font to reduce crowding
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                barGroups: barGroups,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                xAxisLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                yAxisLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
