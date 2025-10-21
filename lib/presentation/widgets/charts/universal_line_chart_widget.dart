import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_colors.dart';

class UniversalLineChartWidget extends StatelessWidget {
  final List<FlSpot> spots;
  final String title;
  final String yAxisLabel;
  final String xAxisLabel;
  final Color? lineColor;
  final bool showGrid;
  final double? minY;
  final double? maxY;
  final double? height;
  final int? targetLabels;

  const UniversalLineChartWidget({
    super.key,
    required this.spots,
    required this.title,
    required this.yAxisLabel,
    required this.xAxisLabel,
    this.lineColor,
    this.showGrid = true,
    this.minY,
    this.maxY,
    this.height = 200,
    this.targetLabels = 5,
  });

  double _calculateOptimalInterval() {
    if (spots.isEmpty) return 1;

    final minYValue = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final maxYValue = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
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
            child: LineChart(
              LineChartData(
                gridData: showGrid
                    ? FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: _calculateOptimalInterval(),
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppColors.border.withValues(alpha: 0.3),
                            strokeWidth: 1,
                          );
                        },
                        getDrawingVerticalLine: (value) {
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
                      interval: spots.length <= 5
                          ? 1
                          : (spots.length / 5).ceil().toDouble(),
                      getTitlesWidget: (value, meta) {
                        if (spots.length == 1) {
                          // For single point, show meaningful labels
                          if (value == 0) {
                            return Text(
                              '1',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontSize: 10,
                                  ),
                            );
                          }
                          return const SizedBox.shrink();
                        }
                        return Text(
                          '${value.toInt() + 1}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 10,
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
                minX: spots.length == 1 ? -0.5 : 0,
                maxX: spots.isNotEmpty
                    ? (spots.length == 1 ? 0.5 : spots.last.x)
                    : 10,
                minY:
                    minY ??
                    (spots.isNotEmpty
                        ? spots
                                  .map((e) => e.y)
                                  .reduce((a, b) => a < b ? a : b) *
                              0.9
                        : 0),
                maxY:
                    maxY ??
                    (spots.isNotEmpty
                        ? spots
                                  .map((e) => e.y)
                                  .reduce((a, b) => a > b ? a : b) *
                              1.1
                        : 10),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        (lineColor ?? AppColors.primary).withValues(alpha: 0.3),
                        lineColor ?? AppColors.primary,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: lineColor ?? AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: AppColors.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          (lineColor ?? AppColors.primary).withValues(
                            alpha: 0.1,
                          ),
                          (lineColor ?? AppColors.primary).withValues(
                            alpha: 0.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                spots.length == 1 ? 'Day' : xAxisLabel,
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
