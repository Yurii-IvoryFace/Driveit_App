import 'package:flutter/material.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../core/theme/app_colors.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isSelected;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: isSelected ? 8.0 : 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: isSelected
            ? BorderSide(color: AppColors.primary, width: 2.0)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with primary indicator
              Row(
                children: [
                  if (vehicle.isPrimary)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Text(
                        'PRIMARY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const Spacer(),
                  PopupMenuButton<String>(
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
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8.0),

              // Vehicle photo or placeholder
              Container(
                height: 80.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: AppColors.surface,
                ),
                child: vehicle.photoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          vehicle.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(),
                        ),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(height: 8.0),

              // Vehicle name and year
              Text(
                vehicle.name,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2.0),

              // Make, model, year
              Text(
                '${vehicle.make} ${vehicle.model} ${vehicle.year}',
                style: TextStyle(
                  fontSize: 12.0,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6.0),

              // Odometer and fuel type
              Row(
                children: [
                  if (vehicle.odometerKm != null) ...[
                    Icon(
                      Icons.speed,
                      size: 16.0,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      '${vehicle.odometerKm!.toStringAsFixed(0)} km',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (vehicle.fuelType != null) ...[
                    const SizedBox(width: 16.0),
                    Icon(
                      Icons.local_gas_station,
                      size: 16.0,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: Text(
                        vehicle.fuelType!,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Center(
        child: Icon(
          Icons.directions_car,
          size: 32.0,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
