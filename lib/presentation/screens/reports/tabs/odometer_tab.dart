import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/chart_data_utils.dart';
import '../../../bloc/reports/reports_bloc.dart';
import '../../../bloc/reports/reports_event.dart';
import '../../../bloc/reports/reports_state.dart';
import '../../../widgets/charts/line_chart_widget.dart';

class OdometerTab extends StatefulWidget {
  final String? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  const OdometerTab({super.key, this.vehicleId, this.startDate, this.endDate});

  @override
  State<OdometerTab> createState() => _OdometerTabState();
}

class _OdometerTabState extends State<OdometerTab> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(
      LoadOdometerData(
        vehicleId: widget.vehicleId,
        startDate: widget.startDate,
        endDate: widget.endDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is ReportsError) {
          return _buildErrorState(context, state.message);
        }

        if (state is OdometerDataLoaded) {
          return _buildOdometerContent(context, state);
        }

        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.danger),
          const SizedBox(height: 16),
          Text(
            'Error: $message',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ReportsBloc>().add(
                LoadOdometerData(
                  vehicleId: widget.vehicleId,
                  startDate: widget.startDate,
                  endDate: widget.endDate,
                ),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOdometerContent(BuildContext context, OdometerDataLoaded state) {
    final entries = state.odometerEntries;
    final statistics = state.odometerStatistics;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ReportsBloc>().add(
          LoadOdometerData(
            vehicleId: widget.vehicleId,
            startDate: widget.startDate,
            endDate: widget.endDate,
          ),
        );
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOdometerStatsCards(context, statistics),
            const SizedBox(height: 24),
            _buildOdometerTrendChart(context, entries),
            const SizedBox(height: 24),
            _buildDistanceChart(context, entries),
          ],
        ),
      ),
    );
  }

  Widget _buildOdometerStatsCards(
    BuildContext context,
    Map<String, dynamic> statistics,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Odometer Statistics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Distance',
                ChartDataUtils.formatDistance(
                  statistics['totalDistance'] ?? 0.0,
                ),
                Icons.speed,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Avg Distance',
                ChartDataUtils.formatDistance(
                  statistics['averageDistance'] ?? 0.0,
                ),
                Icons.trending_up,
                AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Refuelings',
                '${statistics['totalRefuelings'] ?? 0}',
                Icons.local_gas_station,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Avg per Refueling',
                ChartDataUtils.formatDistance(
                  (statistics['totalDistance'] ?? 0.0) /
                      (statistics['totalRefuelings'] ?? 1),
                ),
                Icons.calculate,
                AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOdometerTrendChart(BuildContext context, entries) {
    final spots = ChartDataUtils.getOdometerTrend(entries);

    return LineChartWidget(
      spots: spots,
      title: 'Odometer Reading Trend',
      yAxisLabel: 'Kilometers',
      xAxisLabel: 'Refuelings',
      lineColor: AppColors.primary,
    );
  }

  Widget _buildDistanceChart(BuildContext context, entries) {
    if (entries.length < 2) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            'Not enough data to show distance chart',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Calculate distance between refuelings
    final sortedEntries = List.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    for (int i = 1; i < sortedEntries.length; i++) {
      final distance =
          sortedEntries[i].odometerKm - sortedEntries[i - 1].odometerKm;
      spots.add(FlSpot(i.toDouble(), distance.toDouble()));
    }

    return LineChartWidget(
      spots: spots,
      title: 'Distance Between Refuelings',
      yAxisLabel: 'Kilometers',
      xAxisLabel: 'Refuelings',
      lineColor: AppColors.success,
    );
  }
}
