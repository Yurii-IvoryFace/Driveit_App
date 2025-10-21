import 'package:flutter/material.dart';
import '../../../domain/entities/vehicle_stat.dart' as vehicle_stat;
import '../../../core/theme/app_colors.dart';
import 'interactive_stat_card.dart';

class VehicleStatsSection extends StatelessWidget {
  final List<vehicle_stat.VehicleStat> stats;
  final VoidCallback? onAddStat;
  final Function(vehicle_stat.VehicleStat)? onEditStat;
  final Function(vehicle_stat.VehicleStat)? onDeleteStat;
  final bool isEditable;

  const VehicleStatsSection({
    super.key,
    required this.stats,
    this.onAddStat,
    this.onEditStat,
    this.onDeleteStat,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const Text(
                'Statistics',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (isEditable && onAddStat != null)
                IconButton(
                  onPressed: onAddStat,
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),

        // Stats list
        if (stats.isEmpty)
          _buildEmptyState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              return InteractiveStatCard(
                stat: stat,
                onEdit: onEditStat != null ? () => onEditStat!(stat) : null,
                onDelete: onDeleteStat != null
                    ? () => onDeleteStat!(stat)
                    : null,
                isEditable: isEditable,
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 48.0,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16.0),
          Text(
            'No statistics yet',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Add statistics to track your vehicle\'s performance',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.0, color: AppColors.textSecondary),
          ),
          if (isEditable && onAddStat != null) ...[
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: onAddStat,
              icon: const Icon(Icons.add),
              label: const Text('Add Statistic'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
