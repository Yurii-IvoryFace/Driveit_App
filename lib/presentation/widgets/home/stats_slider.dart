import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/vehicle.dart';

class StatsSlider extends StatelessWidget {
  final Vehicle vehicle;
  final Map<String, dynamic>? vehicleStats;
  final VoidCallback? onTap;

  const StatsSlider({
    super.key,
    required this.vehicle,
    this.vehicleStats,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vehicle Statistics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onTap != null)
                TextButton(onPressed: onTap, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildStatCard(
                  context,
                  'Total Distance',
                  '${vehicle.odometerKm ?? 0} km',
                  Icons.speed,
                  AppColors.primary,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  'Total Cost',
                  '${_getTotalCost()} ₴',
                  Icons.attach_money,
                  AppColors.success,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  'Transactions',
                  _getTransactionCount(),
                  Icons.receipt_long,
                  AppColors.warning,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  'Fuel Efficiency',
                  '${_getFuelEfficiency()} L/100km',
                  Icons.local_gas_station,
                  AppColors.info,
                ),
              ],
            ),
          ),
        ],
      ),
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
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: AppColors.success, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getTotalCost() {
    if (vehicleStats == null) return '0';
    final totalAmount = vehicleStats!['totalAmount'] as double? ?? 0.0;
    return totalAmount.toStringAsFixed(0);
  }

  String _getTransactionCount() {
    if (vehicleStats == null) return '0';
    final count = vehicleStats!['transactionCount'] as int? ?? 0;
    return count.toString();
  }

  String _getFuelEfficiency() {
    // This would be calculated from fuel consumption data
    // For now, return a placeholder
    return '8.5';
  }
}
