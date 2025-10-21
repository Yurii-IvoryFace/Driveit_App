import 'package:flutter/material.dart';
import '../../../domain/entities/vehicle_stat.dart' as vehicle_stat;
import '../../../core/theme/app_colors.dart';

class InteractiveStatCard extends StatelessWidget {
  final vehicle_stat.VehicleStat stat;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isEditable;

  const InteractiveStatCard({
    super.key,
    required this.stat,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon based on stat type
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: _getIconColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Icon(_getIcon(), color: _getIconColor(), size: 24.0),
              ),
              const SizedBox(width: 16.0),

              // Stat content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.type.displayName,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '${stat.value}${stat.unit != null ? ' ${stat.unit}' : ''}',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (stat.notes != null && stat.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4.0),
                      Text(
                        stat.notes!,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Action buttons
              if (isEditable) ...[
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit,
                    size: 20.0,
                    color: AppColors.textSecondary,
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 20.0, color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (stat.type) {
      case vehicle_stat.VehicleStatType.odometer:
        return Icons.speed;
      case vehicle_stat.VehicleStatType.lastService:
        return Icons.build;
      case vehicle_stat.VehicleStatType.nextService:
        return Icons.schedule;
      case vehicle_stat.VehicleStatType.insuranceExpiry:
        return Icons.security;
      case vehicle_stat.VehicleStatType.registrationExpiry:
        return Icons.description;
      case vehicle_stat.VehicleStatType.purchaseDate:
        return Icons.shopping_cart;
      case vehicle_stat.VehicleStatType.saleDate:
        return Icons.sell;
      case vehicle_stat.VehicleStatType.custom:
        return Icons.info;
    }
  }

  Color _getIconColor() {
    switch (stat.type) {
      case vehicle_stat.VehicleStatType.odometer:
        return AppColors.primary;
      case vehicle_stat.VehicleStatType.lastService:
        return Colors.green;
      case vehicle_stat.VehicleStatType.nextService:
        return Colors.orange;
      case vehicle_stat.VehicleStatType.insuranceExpiry:
        return Colors.blue;
      case vehicle_stat.VehicleStatType.registrationExpiry:
        return Colors.purple;
      case vehicle_stat.VehicleStatType.purchaseDate:
        return Colors.green;
      case vehicle_stat.VehicleStatType.saleDate:
        return Colors.red;
      case vehicle_stat.VehicleStatType.custom:
        return AppColors.textSecondary;
    }
  }
}
