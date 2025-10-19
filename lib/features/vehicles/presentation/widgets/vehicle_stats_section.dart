import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_repository.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_stat.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_stat_repository.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_stat_type.dart';
import 'package:driveit_app/features/vehicles/presentation/vehicle_form_page.dart';
import 'package:driveit_app/features/vehicles/presentation/vehicle_stat_form_page.dart';
import 'package:driveit_app/features/vehicles/presentation/widgets/interactive_stat_card.dart';
import 'package:driveit_app/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VehicleStatsSection extends StatelessWidget {
  const VehicleStatsSection({
    super.key,
    required this.vehicle,
    required this.stats,
    required this.onStatAdded,
    required this.onStatUpdated,
    required this.onStatDeleted,
  });

  final Vehicle vehicle;
  final List<VehicleStat> stats;
  final ValueChanged<VehicleStat> onStatAdded;
  final ValueChanged<VehicleStat> onStatUpdated;
  final ValueChanged<VehicleStat> onStatDeleted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => _showAddStatSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Add stat'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (stats.isEmpty)
          _buildEmptyState(context)
        else
          _buildStatsList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return DriveCard(
      color: const Color(0xFF161B1F),
      borderRadius: 20,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No statistics yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add service dates, insurance expiry, and other important information.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showAddStatSheet(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.tealAccent,
              side: const BorderSide(color: Colors.tealAccent),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add first statistic'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsList(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: stats.length,
        separatorBuilder: (context, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final stat = stats[index];
          return InteractiveStatCard(
            stat: stat,
            onTap: () => _openStatDetails(context, stat),
            onEdit: () => _editStat(context, stat),
            onDelete: () => _confirmDeleteStat(context, stat),
          );
        },
      ),
    );
  }

  Future<void> _showAddStatSheet(BuildContext context) async {
    final result = await Navigator.of(context).push<VehicleStat>(
      MaterialPageRoute(
        builder: (_) => VehicleStatFormPage(vehicle: vehicle),
        fullscreenDialog: true,
      ),
    );
    
    if (result != null && context.mounted) {
      onStatAdded(result);
    }
  }

  Future<void> _openStatDetails(BuildContext context, VehicleStat stat) async {
    // For odometer stats, open vehicle edit form instead
    if (stat.type == VehicleStatType.odometer) {
      await _editVehicleOdometer(context);
    } else {
      // For other stats, open the edit form
      await _editStat(context, stat);
    }
  }

  Future<void> _editStat(BuildContext context, VehicleStat stat) async {
    final result = await Navigator.of(context).push<VehicleStat>(
      MaterialPageRoute(
        builder: (_) => VehicleStatFormPage(
          vehicle: vehicle,
          initialStat: stat,
        ),
        fullscreenDialog: true,
      ),
    );
    
    if (result != null && context.mounted) {
      onStatUpdated(result);
    }
  }

  Future<void> _confirmDeleteStat(BuildContext context, VehicleStat stat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete statistic'),
        content: Text(
          'Are you sure you want to delete this ${stat.type.label.toLowerCase()} entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      onStatDeleted(stat);
    }
  }

  Future<void> _editVehicleOdometer(BuildContext context) async {
    final result = await Navigator.of(context).push<Vehicle>(
      MaterialPageRoute(
        builder: (_) => VehicleFormPage(initialVehicle: vehicle),
        fullscreenDialog: true,
      ),
    );
    
    if (result != null && context.mounted) {
      // Update the vehicle and sync odometer stat
      await context.read<VehicleRepository>().saveVehicle(result);
      if (result.odometerKm != null) {
        await context.read<VehicleStatRepository>().ensureOdometerStat(
          result.id, 
          result.odometerKm!,
        );
      }
    }
  }
}
