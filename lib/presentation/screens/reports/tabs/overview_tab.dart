import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/chart_data_utils.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../../domain/entities/refueling_entry.dart';
import '../../../bloc/reports/reports_bloc.dart';
import '../../../bloc/reports/reports_event.dart';
import '../../../bloc/reports/reports_state.dart';
import '../../../widgets/charts/improved_line_chart_widget.dart';

class OverviewTab extends StatefulWidget {
  final String? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  const OverviewTab({super.key, this.vehicleId, this.startDate, this.endDate});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(
      LoadOverviewData(
        vehicleId: widget.vehicleId,
        startDate: widget.startDate,
        endDate: widget.endDate,
      ),
    );
  }

  @override
  void didUpdateWidget(OverviewTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vehicleId != widget.vehicleId ||
        oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      context.read<ReportsBloc>().add(
        LoadOverviewData(
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

        if (state is OverviewDataLoaded) {
          return _buildOverviewContent(context, state);
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
                LoadOverviewData(
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

  Widget _buildOverviewContent(BuildContext context, OverviewDataLoaded state) {
    final data = state.overviewData;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ReportsBloc>().add(
          LoadOverviewData(
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
            _buildStatsCards(context, data),
            const SizedBox(height: 24),
            _buildCostTrendChart(context, data),
            const SizedBox(height: 24),
            _buildFuelConsumptionChart(context, data),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Загальна статистика',
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
                'Загальні витрати',
                ChartDataUtils.formatCurrency(data['totalCost'] ?? 0.0),
                Icons.attach_money,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Транзакції',
                '${data['totalTransactions'] ?? 0}',
                Icons.receipt_long,
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
                '${data['totalRefuelings'] ?? 0}',
                Icons.local_gas_station,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Середня ефективність',
                ChartDataUtils.formatFuelConsumption(
                  data['averageEfficiency'] ?? 0.0,
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

  Widget _buildCostTrendChart(BuildContext context, Map<String, dynamic> data) {
    final transactions = data['transactions'] as List<dynamic>? ?? [];

    return ImprovedLineChartWidget(
      spots: ChartDataUtils.getCostTrendSpots(transactions.cast<Transaction>()),
      title: 'Динаміка витрат',
      yAxisLabel: 'Витрати (₴)',
      xAxisLabel: 'Дні',
      lineColor: AppColors.primary,
    );
  }

  Widget _buildFuelConsumptionChart(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final refuelingEntries = data['refuelingEntries'] as List<dynamic>? ?? [];

    return ImprovedLineChartWidget(
      spots: ChartDataUtils.getFuelConsumptionSpots(
        refuelingEntries.cast<RefuelingEntry>(),
      ),
      title: 'Витрата палива',
      yAxisLabel: 'л/100км',
      xAxisLabel: 'Заправки',
      lineColor: AppColors.warning,
    );
  }
}
