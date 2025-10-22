import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/chart_data_utils.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../bloc/reports/reports_bloc.dart';
import '../../../bloc/reports/reports_event.dart';
import '../../../bloc/reports/reports_state.dart';
import '../../../widgets/charts/improved_line_chart_widget.dart';

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
  void didUpdateWidget(OdometerTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vehicleId != widget.vehicleId ||
        oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      context.read<ReportsBloc>().add(
        LoadOdometerData(
          vehicleId: widget.vehicleId,
          startDate: widget.startDate,
          endDate: widget.endDate,
        ),
      );
    }
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
          'Статистика пробігу',
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
                'Загальна відстань',
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
                'Середня відстань',
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
                'Заправки',
                '${statistics['totalRefuelings'] ?? 0}',
                Icons.local_gas_station,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Середня на заправку',
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
    final transactions = entries.cast<Transaction>();

    return ImprovedLineChartWidget(
      spots: ChartDataUtils.getOdometerTrendSpotsFromTransactions(transactions),
      title: 'Зміна пробігу',
      yAxisLabel: 'Кілометри',
      xAxisLabel: 'Дата',
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

    return ImprovedLineChartWidget(
      spots: ChartDataUtils.getDistanceSpotsFromTransactions(
        sortedEntries.cast<Transaction>(),
      ),
      title: 'Відстань між заправками',
      yAxisLabel: 'Кілометри',
      xAxisLabel: 'Заправки',
      lineColor: AppColors.success,
    );
  }
}
