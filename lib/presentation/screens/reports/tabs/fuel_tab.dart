import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/chart_data_utils.dart';
import '../../../../domain/entities/refueling_entry.dart';
import '../../../bloc/reports/reports_bloc.dart';
import '../../../bloc/reports/reports_event.dart';
import '../../../bloc/reports/reports_state.dart';
import '../../../widgets/charts/universal_line_chart_widget.dart';

class FuelTab extends StatefulWidget {
  final String? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  const FuelTab({super.key, this.vehicleId, this.startDate, this.endDate});

  @override
  State<FuelTab> createState() => _FuelTabState();
}

class _FuelTabState extends State<FuelTab> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(
      LoadFuelData(
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

        if (state is FuelDataLoaded) {
          return _buildFuelContent(context, state);
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
                LoadFuelData(
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

  Widget _buildFuelContent(BuildContext context, FuelDataLoaded state) {
    final entries = state.refuelingEntries;
    final statistics = state.fuelStatistics;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ReportsBloc>().add(
          LoadFuelData(
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
            _buildFuelStatsCards(context, statistics),
            const SizedBox(height: 24),
            _buildFuelConsumptionChart(context, entries),
            const SizedBox(height: 24),
            _buildFuelVolumeChart(context, entries),
            const SizedBox(height: 24),
            _buildFuelPriceChart(context, entries),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelStatsCards(
    BuildContext context,
    Map<String, dynamic> statistics,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fuel Statistics',
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
                'Total Volume',
                '${(statistics['totalVolume'] ?? 0.0).toDouble().toStringAsFixed(1)} L',
                Icons.local_gas_station,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Total Cost',
                ChartDataUtils.formatCurrency(
                  (statistics['totalAmount'] ?? 0.0).toDouble(),
                ),
                Icons.attach_money,
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
                'Avg Price',
                '${(statistics['averagePricePerLiter'] ?? 0.0).toDouble().toStringAsFixed(2)} ₴/L',
                Icons.trending_up,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Avg Efficiency',
                ChartDataUtils.formatFuelConsumption(
                  (statistics['averageEfficiency'] ?? 0.0).toDouble(),
                ),
                Icons.speed,
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

  Widget _buildFuelConsumptionChart(
    BuildContext context,
    List<dynamic> entries,
  ) {
    final refuelingEntries = entries.cast<RefuelingEntry>();
    final spots = ChartDataUtils.getFuelConsumptionSpots(refuelingEntries);

    return UniversalLineChartWidget(
      spots: spots,
      title: 'Fuel Consumption Trend',
      yAxisLabel: 'L/100km',
      xAxisLabel: 'Refuelings',
      lineColor: AppColors.warning,
    );
  }

  Widget _buildFuelVolumeChart(BuildContext context, List<dynamic> entries) {
    final refuelingEntries = entries.cast<RefuelingEntry>();
    // Sort by date to ensure chronological order
    refuelingEntries.sort((a, b) => a.date.compareTo(b.date));
    final spots = refuelingEntries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.volumeLiters);
    }).toList();

    return UniversalLineChartWidget(
      spots: spots,
      title: 'Fuel Volume per Refueling',
      yAxisLabel: 'Liters',
      xAxisLabel: 'Refuelings',
      lineColor: AppColors.primary,
    );
  }

  Widget _buildFuelPriceChart(BuildContext context, List<dynamic> entries) {
    final refuelingEntries = entries.cast<RefuelingEntry>();
    // Sort by date to ensure chronological order
    refuelingEntries.sort((a, b) => a.date.compareTo(b.date));
    final spots = refuelingEntries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.pricePerLiter);
    }).toList();

    return UniversalLineChartWidget(
      spots: spots,
      title: 'Fuel Price Trend',
      yAxisLabel: '₴/L',
      xAxisLabel: 'Refuelings',
      lineColor: AppColors.success,
    );
  }
}
