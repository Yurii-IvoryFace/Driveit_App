import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class QuickActionMenu extends StatelessWidget {
  final VoidCallback? onAddTransaction;
  final VoidCallback? onAddRefueling;
  final VoidCallback? onAddMaintenance;
  final VoidCallback? onAddExpense;
  final VoidCallback? onViewReports;

  const QuickActionMenu({
    super.key,
    this.onAddTransaction,
    this.onAddRefueling,
    this.onAddMaintenance,
    this.onAddExpense,
    this.onViewReports,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        'Add Transaction',
                        Icons.add_circle_outline,
                        AppColors.primary,
                        onAddTransaction,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        'Add Refueling',
                        Icons.local_gas_station,
                        Colors.blue,
                        onAddRefueling,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        'Add Maintenance',
                        Icons.build,
                        Colors.orange,
                        onAddMaintenance,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        'Add Expense',
                        Icons.attach_money,
                        AppColors.success,
                        onAddExpense,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  context,
                  'View Reports',
                  Icons.analytics,
                  AppColors.info,
                  onViewReports,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback? onTap, {
    bool isFullWidth = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: isFullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
