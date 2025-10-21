import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/chart_data_utils.dart';
import '../../../bloc/reports/reports_bloc.dart';
import '../../../bloc/reports/reports_event.dart';
import '../../../bloc/reports/reports_state.dart';
import '../../../widgets/charts/universal_pie_chart_widget.dart';

class OwnershipTab extends StatefulWidget {
  final String? vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  const OwnershipTab({super.key, this.vehicleId, this.startDate, this.endDate});

  @override
  State<OwnershipTab> createState() => _OwnershipTabState();
}

class _OwnershipTabState extends State<OwnershipTab> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(
      LoadOwnershipData(
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

        if (state is OwnershipDataLoaded) {
          return _buildOwnershipContent(context, state);
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
                LoadOwnershipData(
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

  Widget _buildOwnershipContent(
    BuildContext context,
    OwnershipDataLoaded state,
  ) {
    final data = state.ownershipData;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ReportsBloc>().add(
          LoadOwnershipData(
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
            _buildOwnershipStatsCards(context, data),
            const SizedBox(height: 24),
            _buildCostBreakdownChart(context, data),
            const SizedBox(height: 24),
            _buildOwnershipSummary(context, data),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnershipStatsCards(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ownership Statistics',
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
                ChartDataUtils.formatCurrency(data['totalCost'] ?? 0.0),
                Icons.attach_money,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Total Distance',
                ChartDataUtils.formatDistance(data['totalDistance'] ?? 0.0),
                Icons.speed,
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
                'Cost per km',
                '${(data['costPerKm'] ?? 0.0).toStringAsFixed(2)} ₴/km',
                Icons.trending_up,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Fuel Cost per km',
                '${(data['refuelingCostPerKm'] ?? 0.0).toStringAsFixed(2)} ₴/km',
                Icons.local_gas_station,
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

  Widget _buildCostBreakdownChart(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final totalCost = data['totalCost'] ?? 0.0;
    final refuelingCost = data['totalRefuelingCost'] ?? 0.0;
    final otherCost = totalCost - refuelingCost;

    final sections = <PieChartSectionData>[];

    if (refuelingCost > 0) {
      final refuelingPercentage = (refuelingCost / totalCost) * 100;
      sections.add(
        PieChartSectionData(
          color: AppColors.primary,
          value: refuelingPercentage,
          title: 'Fuel\n${refuelingPercentage.toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    if (otherCost > 0) {
      final otherPercentage = (otherCost / totalCost) * 100;
      sections.add(
        PieChartSectionData(
          color: AppColors.success,
          value: otherPercentage,
          title: 'Other\n${otherPercentage.toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return UniversalPieChartWidget(
      sections: sections,
      title: 'Cost Breakdown',
      totalValue: totalCost,
      totalLabel: 'Total Cost',
    );
  }

  Widget _buildOwnershipSummary(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
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
            'Ownership Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            context,
            'Total Distance Driven',
            ChartDataUtils.formatDistance(data['totalDistance'] ?? 0.0),
            Icons.speed,
          ),
          _buildSummaryRow(
            context,
            'Total Cost of Ownership',
            ChartDataUtils.formatCurrency(data['totalCost'] ?? 0.0),
            Icons.attach_money,
          ),
          _buildSummaryRow(
            context,
            'Fuel Costs',
            ChartDataUtils.formatCurrency(data['totalRefuelingCost'] ?? 0.0),
            Icons.local_gas_station,
          ),
          _buildSummaryRow(
            context,
            'Other Costs',
            ChartDataUtils.formatCurrency(
              (data['totalCost'] ?? 0.0) - (data['totalRefuelingCost'] ?? 0.0),
            ),
            Icons.receipt_long,
          ),
          const Divider(),
          _buildSummaryRow(
            context,
            'Cost per Kilometer',
            '${(data['costPerKm'] ?? 0.0).toStringAsFixed(2)} ₴/km',
            Icons.trending_up,
            isHighlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: isHighlighted
                ? AppColors.primary
                : AppColors.onSurface.withValues(alpha: 0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isHighlighted ? AppColors.primary : AppColors.onSurface,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
