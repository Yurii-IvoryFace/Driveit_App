import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/chart_data_utils.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../bloc/reports/reports_bloc.dart';
import '../../../bloc/reports/reports_event.dart';
import '../../../bloc/reports/reports_state.dart';
import '../../../widgets/charts/line_chart_widget.dart';
import '../../../widgets/charts/bar_chart_widget.dart';
import '../../../widgets/charts/pie_chart_widget.dart';

class CostsTab extends StatefulWidget {
  final String? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  const CostsTab({super.key, this.vehicleId, this.startDate, this.endDate});

  @override
  State<CostsTab> createState() => _CostsTabState();
}

class _CostsTabState extends State<CostsTab> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(
      LoadCostsData(
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

        if (state is CostsDataLoaded) {
          return _buildCostsContent(context, state);
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
                LoadCostsData(
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

  Widget _buildCostsContent(BuildContext context, CostsDataLoaded state) {
    final transactions = state.transactions;
    final statistics = state.costStatistics;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ReportsBloc>().add(
          LoadCostsData(
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
            _buildCostsStatsCards(context, statistics),
            const SizedBox(height: 24),
            _buildCostTrendChart(context, transactions),
            const SizedBox(height: 24),
            _buildMonthlyCostsChart(context, transactions),
            const SizedBox(height: 24),
            _buildCostsByCategoryChart(context, transactions),
          ],
        ),
      ),
    );
  }

  Widget _buildCostsStatsCards(
    BuildContext context,
    Map<String, dynamic> statistics,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cost Statistics',
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
                'Total Cost',
                ChartDataUtils.formatCurrency(statistics['totalAmount'] ?? 0.0),
                Icons.attach_money,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Transactions',
                '${statistics['totalTransactions'] ?? 0}',
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
                'Avg Cost',
                ChartDataUtils.formatCurrency(
                  statistics['averageAmount'] ?? 0.0,
                ),
                Icons.trending_up,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'This Month',
                ChartDataUtils.formatCurrency(
                  statistics['monthlyAmount'] ?? 0.0,
                ),
                Icons.calendar_month,
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

  Widget _buildCostTrendChart(
    BuildContext context,
    List<dynamic> transactions,
  ) {
    final transactionList = transactions.cast<Transaction>();
    final spots = ChartDataUtils.getCostTrendSpots(transactionList);

    return LineChartWidget(
      spots: spots,
      title: 'Cost Trend Over Time',
      yAxisLabel: 'Cost (₴)',
      xAxisLabel: 'Days',
      lineColor: AppColors.primary,
    );
  }

  Widget _buildMonthlyCostsChart(
    BuildContext context,
    List<dynamic> transactions,
  ) {
    final transactionList = transactions.cast<Transaction>();
    final bars = ChartDataUtils.getMonthlyCostBars(transactionList);

    return BarChartWidget(
      barGroups: bars,
      title: 'Monthly Costs',
      yAxisLabel: 'Cost (₴)',
      xAxisLabel: 'Months',
      barColor: AppColors.success,
    );
  }

  Widget _buildCostsByCategoryChart(
    BuildContext context,
    List<dynamic> transactions,
  ) {
    final transactionList = transactions.cast<Transaction>();
    final sections = ChartDataUtils.getTransactionTypePieData(transactionList);
    final totalCost = transactionList.fold(
      0.0,
      (sum, t) => sum + (t.amount?.toDouble() ?? 0.0),
    );

    return PieChartWidget(
      sections: sections,
      title: 'Costs by Category',
      totalValue: totalCost,
      totalLabel: 'Total Cost',
    );
  }
}
