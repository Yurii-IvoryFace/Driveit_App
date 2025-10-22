import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/transaction.dart';

class TimelineCard extends StatelessWidget {
  final List<Transaction> recentTransactions;
  final VoidCallback? onViewAll;

  const TimelineCard({
    super.key,
    required this.recentTransactions,
    this.onViewAll,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (recentTransactions.isEmpty)
            _buildEmptyState(context)
          else
            ListView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Let parent scroll
              itemCount: recentTransactions.length,
              itemBuilder: (context, index) {
                final transaction = recentTransactions[index];
                return _buildTimelineItem(context, transaction);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.timeline,
            size: 48,
            color: AppColors.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No recent activity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first transaction',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, Transaction transaction) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getTypeColor(transaction.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getTypeIcon(transaction.type),
              color: _getTypeColor(transaction.type),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.type.displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(transaction.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (transaction.amount != null)
            Text(
              '${transaction.amount!.toStringAsFixed(0)} ₴',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.refueling:
        return Colors.blue;
      case TransactionType.maintenance:
        return Colors.orange;
      case TransactionType.insurance:
        return Colors.green;
      case TransactionType.parking:
        return Colors.purple;
      case TransactionType.toll:
        return Colors.teal;
      case TransactionType.carWash:
        return Colors.cyan;
      case TransactionType.other:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.refueling:
        return Icons.local_gas_station;
      case TransactionType.maintenance:
        return Icons.build;
      case TransactionType.insurance:
        return Icons.security;
      case TransactionType.parking:
        return Icons.local_parking;
      case TransactionType.toll:
        return Icons.toll;
      case TransactionType.carWash:
        return Icons.wash;
      case TransactionType.other:
        return Icons.receipt;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
