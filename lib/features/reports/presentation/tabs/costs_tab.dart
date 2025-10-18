import 'dart:math' as math;

import 'package:driveit_app/features/expenses/domain/expense.dart';
import 'package:driveit_app/features/expenses/domain/expense_repository.dart';
import 'package:driveit_app/features/refueling/domain/refueling_entry.dart';
import 'package:driveit_app/features/refueling/domain/refueling_repository.dart';
import 'package:driveit_app/features/refueling/domain/refueling_summary.dart';
import 'package:driveit_app/features/reports/presentation/tabs/tab_components.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_repository.dart';
import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:driveit_app/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CostsTab extends StatelessWidget {
  const CostsTab({
    super.key,
    required this.selectedVehicleId,
    required this.onVehicleChanged,
    required this.onViewFuel,
    required this.onOpenVehicleDetails,
  });

  final String? selectedVehicleId;
  final ValueChanged<String?> onVehicleChanged;
  final ValueChanged<String> onViewFuel;
  final ValueChanged<Vehicle> onOpenVehicleDetails;

  @override
  Widget build(BuildContext context) {
    final vehicleRepo = context.watch<VehicleRepository>();
    return StreamBuilder<List<Vehicle>>(
      stream: vehicleRepo.watchVehicles(),
      builder: (context, snapshot) {
        final vehicles = snapshot.data ?? const <Vehicle>[];
        if (vehicles.isEmpty) {
          return const ReportsPlaceholder(
            icon: Icons.payments_outlined,
            title: 'Track your vehicle spend',
            message:
                'Add a vehicle and log refueling plus ownership expenses to unlock monthly analytics.',
          );
        }

        final selected = resolveVehicleSelection(
          vehicles: vehicles,
          selectedVehicleId: selectedVehicleId,
          onVehicleChanged: onVehicleChanged,
        );
        if (selected == null) {
          return const SizedBox.shrink();
        }

        final refuelingRepo = context.watch<RefuelingRepository>();
        final expenseRepo = context.watch<ExpenseRepository>();
        return StreamBuilder<RefuelingSummary>(
          stream: refuelingRepo.watchSummary(selected.id),
          builder: (context, summarySnapshot) {
            final summary = summarySnapshot.data ?? RefuelingSummary.empty;
            return StreamBuilder<List<RefuelingEntry>>(
              stream: refuelingRepo.watchByVehicle(selected.id),
              builder: (context, entriesSnapshot) {
                final entries =
                    entriesSnapshot.data ?? const <RefuelingEntry>[];
                return StreamBuilder<List<Expense>>(
                  stream: expenseRepo.watchByVehicle(selected.id),
                  builder: (context, expenseSnapshot) {
                    final expenses = expenseSnapshot.data ?? const <Expense>[];
                    final metrics = _buildCostMetrics(
                      summary,
                      entries,
                      expenses,
                    );
                    final monthlyTotals = _buildMonthlyTotals(
                      entries,
                      expenses,
                    );
                    final recentFuel = entries.take(6).toList();
                    final recentExpenses = expenses.take(6).toList();

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                      children: [
                        VehicleSelectorRow(
                          vehicles: vehicles,
                          selected: selected,
                          onVehicleChanged: onVehicleChanged,
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              FilledButton.icon(
                                onPressed: () => onViewFuel(selected.id),
                                icon: const Icon(
                                  Icons.local_gas_station_outlined,
                                ),
                                label: const Text('Fuel history'),
                              ),
                              FilledButton.icon(
                                onPressed: () => onOpenVehicleDetails(selected),
                                icon: const Icon(Icons.directions_car_outlined),
                                label: const Text('View vehicle'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ReportMetricGrid(metrics: metrics),
                        const SizedBox(height: 24),
                        _MonthlyBreakdownCard(data: monthlyTotals),
                        const SizedBox(height: 24),
                        _FuelHistoryList(entries: recentFuel),
                        const SizedBox(height: 24),
                        _ExpenseHistoryList(expenses: recentExpenses),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  List<ReportMetric> _buildCostMetrics(
    RefuelingSummary summary,
    List<RefuelingEntry> entries,
    List<Expense> expenses,
  ) {
    final currency = NumberFormat.simpleCurrency();
    final now = DateTime.now();
    final fuelSpend = summary.totalCost;
    final nonFuelSpend = expenses.fold<double>(
      0,
      (acc, expense) => acc + expense.amount,
    );
    final totalVehicleSpend = fuelSpend + nonFuelSpend;
    final averageFillCost = summary.fillUps > 0
        ? fuelSpend / summary.fillUps
        : 0;
    final spendLast30Days = entries
        .where(
          (entry) =>
              !entry.date.isBefore(now.subtract(const Duration(days: 30))),
        )
        .fold<double>(0, (acc, entry) => acc + entry.totalCost);
    final spendLast30DaysNonFuel = expenses
        .where(
          (expense) =>
              !expense.date.isBefore(now.subtract(const Duration(days: 30))),
        )
        .fold<double>(0, (acc, expense) => acc + expense.amount);
    final highestFuel = entries.isEmpty
        ? 0.0
        : entries.map((entry) => entry.totalCost).reduce(math.max);
    final highestNonFuel = expenses.isEmpty
        ? 0.0
        : expenses.map((expense) => expense.amount).reduce(math.max);
    final highestOverall = math.max(highestFuel, highestNonFuel);

    return [
      ReportMetric(
        icon: Icons.payments_outlined,
        title: 'Total vehicle spend',
        value: currency.format(totalVehicleSpend),
        caption:
            'Fuel ${currency.format(fuelSpend)} • Other ${currency.format(nonFuelSpend)}',
      ),
      ReportMetric(
        icon: Icons.local_gas_station_outlined,
        title: 'Fuel spend',
        value: currency.format(fuelSpend),
        caption: summary.fillUps > 0
            ? '${summary.fillUps} recorded fill-ups'
            : 'No fuel purchases logged yet',
      ),
      ReportMetric(
        icon: Icons.build_outlined,
        title: 'Non-fuel spend',
        value: currency.format(nonFuelSpend),
        caption: expenses.isNotEmpty
            ? '${expenses.length} tracked expenses'
            : 'Log maintenance, insurance and other costs',
      ),
      ReportMetric(
        icon: Icons.calendar_month_outlined,
        title: 'Last 30 days',
        value: currency.format(spendLast30Days + spendLast30DaysNonFuel),
        caption:
            'Fuel ${currency.format(spendLast30Days)} • Other ${currency.format(spendLast30DaysNonFuel)}',
      ),
      ReportMetric(
        icon: Icons.receipt_long_outlined,
        title: 'Avg fill-up cost',
        value: currency.format(averageFillCost),
        caption: summary.fillUps > 0
            ? 'Across ${summary.fillUps} fill-ups'
            : 'Log a fill-up to calculate averages',
      ),
      ReportMetric(
        icon: Icons.trending_up_outlined,
        title: 'Highest recent expense',
        value: currency.format(highestOverall),
        caption: highestOverall == highestFuel
            ? 'Fuel purchase peak'
            : 'Non-fuel cost peak',
      ),
    ];
  }
}

class _MonthlyBreakdownCard extends StatelessWidget {
  const _MonthlyBreakdownCard({required this.data});

  final List<_MonthlyTotal> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const DriveEmptyState(
        icon: Icons.stacked_bar_chart_outlined,
        title: 'No monthly trends yet',
        message:
            'Log a few fuel and ownership expenses to see month-over-month totals.',
        alignment: CrossAxisAlignment.start,
        textAlign: TextAlign.start,
      );
    }

    final theme = Theme.of(context);
    final formatter = NumberFormat.simpleCurrency();
    final monthFormatter = DateFormat('MMM yyyy');
    final baseMax = data.map((item) => item.combined).reduce(math.max);
    final maxTotal = baseMax <= 0 ? 0.01 : baseMax;

    return DriveCard(
      color: AppColors.surface,
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly vehicle spend',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...data.take(6).map((item) {
            final share = (item.combined / maxTotal).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          monthFormatter.format(item.month),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        formatter.format(item.combined),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fuel: ${formatter.format(item.totalFuel)} \u2022 Other: ${formatter.format(item.totalNonFuel)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: share.isNaN ? 0 : share,
                      minHeight: 6,
                      color: AppColors.accent,
                      backgroundColor: AppColors.surfaceSecondary.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MonthlyTotal {
  const _MonthlyTotal({
    required this.month,
    required this.totalFuel,
    required this.totalNonFuel,
  });

  final DateTime month;
  final double totalFuel;
  final double totalNonFuel;

  double get combined => totalFuel + totalNonFuel;
}

List<_MonthlyTotal> _buildMonthlyTotals(
  List<RefuelingEntry> entries,
  List<Expense> expenses,
) {
  final monthly = <DateTime, ({double fuel, double other})>{};
  for (final entry in entries) {
    final monthKey = DateTime(entry.date.year, entry.date.month);
    final current = monthly[monthKey] ?? (fuel: 0.0, other: 0.0);
    monthly[monthKey] = (
      fuel: current.fuel + entry.totalCost,
      other: current.other,
    );
  }
  for (final expense in expenses) {
    final monthKey = DateTime(expense.date.year, expense.date.month);
    final current = monthly[monthKey] ?? (fuel: 0.0, other: 0.0);
    monthly[monthKey] = (
      fuel: current.fuel,
      other: current.other + expense.amount,
    );
  }

  final sortedKeys = monthly.keys.toList()..sort((a, b) => b.compareTo(a));
  return sortedKeys
      .map(
        (key) => _MonthlyTotal(
          month: key,
          totalFuel: monthly[key]!.fuel,
          totalNonFuel: monthly[key]!.other,
        ),
      )
      .toList();
}

class _FuelHistoryList extends StatelessWidget {
  const _FuelHistoryList({required this.entries});

  final List<RefuelingEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const DriveEmptyState(
        icon: Icons.local_gas_station_outlined,
        title: 'No fuel purchases recorded yet',
        message: 'Add a refueling to build your expense history.',
        alignment: CrossAxisAlignment.start,
        textAlign: TextAlign.start,
      );
    }

    final theme = Theme.of(context);
    final currency = NumberFormat.simpleCurrency();
    final liters = NumberFormat('0.0');
    final dateFormat = DateFormat('MMM d, yyyy');

    return DriveCard(
      color: AppColors.surface,
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent fuel purchases',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      entry.fuelType.label.substring(0, 1),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                title: Text(
                  currency.format(entry.totalCost),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${liters.format(entry.volumeLiters)} L \u2022 ${entry.station ?? 'Unknown station'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Text(
                  dateFormat.format(entry.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseHistoryList extends StatelessWidget {
  const _ExpenseHistoryList({required this.expenses});

  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const DriveEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No ownership expenses logged yet',
        message: 'Add maintenance, insurance, or other costs to see them here.',
        alignment: CrossAxisAlignment.start,
        textAlign: TextAlign.start,
      );
    }

    final theme = Theme.of(context);
    final currency = NumberFormat.simpleCurrency();
    final dateFormat = DateFormat('MMM d, yyyy');

    return DriveCard(
      color: AppColors.surface,
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent ownership expenses',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...expenses.map(
            (expense) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(
                    _expenseIcon(expense.category),
                    color: AppColors.accent,
                  ),
                ),
                title: Text(
                  currency.format(expense.amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${expense.category.label} • ${expense.description}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Text(
                  dateFormat.format(expense.date),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _expenseIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.maintenance:
        return Icons.build_outlined;
      case ExpenseCategory.insurance:
        return Icons.policy_outlined;
      case ExpenseCategory.parking:
        return Icons.local_parking_outlined;
      case ExpenseCategory.tolls:
        return Icons.alt_route_outlined;
      case ExpenseCategory.other:
        return Icons.attach_money_outlined;
    }
  }
}
