import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/chart_data_utils.dart';
import '../../../../domain/entities/refueling_entry.dart';
import '../../../bloc/reports/reports_bloc.dart';
import '../../../bloc/reports/reports_event.dart';
import '../../../bloc/reports/reports_state.dart';
import '../../../widgets/charts/improved_line_chart_widget.dart';

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
  void didUpdateWidget(FuelTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vehicleId != widget.vehicleId ||
        oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      context.read<ReportsBloc>().add(
        LoadFuelData(
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
          'Статистика палива',
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
                'Загальний об\'єм',
                '${(statistics['totalVolume'] ?? 0.0).toDouble().toStringAsFixed(1)} л',
                Icons.local_gas_station,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Загальна вартість',
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
                'Середня ціна',
                '${(statistics['averagePricePerLiter'] ?? 0.0).toDouble().toStringAsFixed(2)} ₴/л',
                Icons.trending_up,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Середня ефективність',
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

    return ImprovedLineChartWidget(
      spots: ChartDataUtils.getFuelConsumptionSpots(refuelingEntries),
      title: 'Динаміка витрати палива',
      yAxisLabel: 'л/100км',
      xAxisLabel: 'Заправки',
      lineColor: AppColors.warning,
    );
  }

  Widget _buildFuelVolumeChart(BuildContext context, List<dynamic> entries) {
    final refuelingEntries = entries.cast<RefuelingEntry>();

    return ImprovedLineChartWidget(
      spots: ChartDataUtils.getFuelVolumeSpots(refuelingEntries),
      title: 'Об\'єм заправки',
      yAxisLabel: 'Літри',
      xAxisLabel: 'Заправки',
      lineColor: AppColors.primary,
    );
  }

  Widget _buildFuelPriceChart(BuildContext context, List<dynamic> entries) {
    final refuelingEntries = entries.cast<RefuelingEntry>();

    return ImprovedLineChartWidget(
      spots: ChartDataUtils.getFuelPriceSpots(refuelingEntries),
      title: 'Ціна палива',
      yAxisLabel: '₴/л',
      xAxisLabel: 'Заправки',
      lineColor: AppColors.success,
    );
  }
}
