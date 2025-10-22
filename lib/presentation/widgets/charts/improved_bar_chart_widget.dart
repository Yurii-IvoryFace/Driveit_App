import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';

class ImprovedBarChartWidget extends StatelessWidget {
  final List<BarChartGroupData> barGroups;
  final String title;
  final String yAxisLabel;
  final String xAxisLabel;
  final Color? barColor;
  final bool showGrid;
  final double? minY;
  final double? maxY;
  final double? height;
  final double? targetLabels;

  const ImprovedBarChartWidget({
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

  @override
  Widget build(BuildContext context) {
    if (barGroups.isEmpty) {
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
              child: Center(
                child: Text(
                  'No data available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

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
          Row(
            children: [
              // Y-axis label (vertical)
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  yAxisLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Chart
              Expanded(
                child: SizedBox(
                  height: height,
                  child: BarChart(
                    BarChartData(
                      gridData: showGrid
                          ? FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              horizontalInterval: _calculateOptimalInterval(),
                              verticalInterval: 1,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: AppColors.border.withValues(
                                    alpha: 0.3,
                                  ),
                                  strokeWidth: 1,
                                );
                              },
                              getDrawingVerticalLine: (value) {
                                return FlLine(
                                  color: AppColors.border.withValues(
                                    alpha: 0.3,
                                  ),
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
                            interval: barGroups.length <= 5
                                ? 1
                                : (barGroups.length / 5).ceil().toDouble(),
                            getTitlesWidget: (value, meta) {
                              if (barGroups.length == 1) {
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
                            reservedSize: 50,
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
                                        fontSize: 10,
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
                        ),
                      ),
                      groupsSpace: 4,
                      minY: minY,
                      maxY: maxY,
                      barGroups: barGroups,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              rod.toY.toStringAsFixed(0),
                              TextStyle(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ), // закриває Row
          const SizedBox(height: 8),
          // X-axis label (centered below chart)
          Center(
            child: Text(
              barGroups.length == 1 ? 'Item' : xAxisLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateOptimalInterval() {
    if (barGroups.isEmpty) return 1;

    final maxYValue = barGroups
        .map((group) => group.barRods.map((rod) => rod.toY).reduce(math.max))
        .reduce(math.max);
    final minYValue = barGroups
        .map((group) => group.barRods.map((rod) => rod.toY).reduce(math.min))
        .reduce(math.min);
    final range = maxYValue - minYValue;

    if (range == 0) {
      return _roundToNiceNumber(maxYValue * 0.2);
    }

    final rawInterval = range / targetLabels!;
    return _roundToNiceNumber(rawInterval);
  }

  double _roundToNiceNumber(double value) {
    if (value <= 0) return 1;
    final magnitude = _getMagnitude(value);
    final normalized = value / magnitude;
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

  double _getMagnitude(double value) {
    if (value == 0) return 1;
    return math.pow(10, (math.log(value) / math.ln10).floor()).toDouble();
  }
}
