import 'package:driveit_app/features/vehicles/domain/vehicle_stat.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_stat_type.dart';
import 'package:flutter/material.dart';

class InteractiveStatCard extends StatelessWidget {
  const InteractiveStatCard({
    super.key,
    required this.stat,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  final VehicleStat stat;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: const Color(0xFF161B1F),
          borderRadius: BorderRadius.circular(20),
          border: onTap != null 
              ? Border.all(
                  color: stat.type == VehicleStatType.odometer 
                    ? Colors.orange.withValues(alpha: 0.3)
                    : Colors.tealAccent.withValues(alpha: 0.3), 
                  width: 1
                )
              : null,
        ),
        padding: const EdgeInsets.all(18),
        constraints: const BoxConstraints(minHeight: 140),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  stat.type.icon,
                  color: Colors.tealAccent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child:             Text(
              stat.type.isCustomType ? (stat.notes ?? 'Custom') : stat.type.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
                ),
                if (showActions && (onEdit != null || onDelete != null))
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.white38,
                      size: 18,
                    ),
                    color: const Color(0xFF1F2428),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (onEdit != null && stat.type != VehicleStatType.odometer)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _formatValue(context, stat),
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (stat.notes != null && stat.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  stat.notes!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else if (stat.type == VehicleStatType.odometer) ...[
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  'Tap to edit vehicle odometer',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.orange.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatValue(BuildContext context, VehicleStat stat) {
    if (stat.type.isDateType && stat.dateValue != null) {
      return MaterialLocalizations.of(context).formatShortDate(stat.dateValue!);
    }
    if (stat.type.isNumericType && stat.numericValue != null) {
      final value = stat.numericValue!;
      final formatted = value.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      return '$formatted ${stat.type.unit ?? ''}';
    }
    if (stat.type.isCustomType) {
      return stat.value?.toString() ?? '—';
    }
    return stat.value?.toString() ?? '—';
  }
}
