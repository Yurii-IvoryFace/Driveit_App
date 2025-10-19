import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_repository.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_stat_repository.dart';
import 'package:driveit_app/features/vehicles/presentation/vehicle_form_page.dart';
import 'package:driveit_app/features/vehicles/presentation/vehicle_details_page.dart';
import 'package:driveit_app/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VehiclesListPage extends StatefulWidget {
  const VehiclesListPage({super.key});

  @override
  VehiclesListPageState createState() => VehiclesListPageState();
}

class VehiclesListPageState extends State<VehiclesListPage> {
  @override
  Widget build(BuildContext context) {
    final repository = context.watch<VehicleRepository>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1418),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: StreamBuilder<List<Vehicle>>(
              stream: repository.watchVehicles(),
              builder: (context, snapshot) {
                final vehicles = snapshot.data ?? const <Vehicle>[];
                if (vehicles.isEmpty) {
                  return const _EmptyGarage();
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  itemCount: vehicles.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return _VehicleTile(
                      vehicle: vehicle,
                      onManage: () => _showVehicleActions(vehicle),
                      onSetPrimary: vehicle.isPrimary
                          ? null
                          : () => _setPrimaryVehicle(vehicle),
                      onConfirmDismiss: () => _confirmDeleteVehicle(vehicle),
                      onViewDetails: () => _openVehicleDetails(vehicle),
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            right: 20,
            bottom: 90,
            child: _AddVehicleButton(onPressed: showAddVehicleDialog),
          ),
        ],
      ),
    );
  }

  Future<void> showAddVehicleDialog() async {
    final vehicle = await Navigator.of(context).push<Vehicle>(
      MaterialPageRoute(
        builder: (_) => const VehicleFormPage(),
        fullscreenDialog: true,
      ),
    );
    if (vehicle == null || !mounted) return;
    await context.read<VehicleRepository>().saveVehicle(vehicle);
    
    // Automatically create odometer stat if vehicle has odometer reading
    if (vehicle.odometerKm != null) {
      await context.read<VehicleStatRepository>().ensureOdometerStat(
        vehicle.id, 
        vehicle.odometerKm!,
      );
    }
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${vehicle.displayName} added to your garage')),
    );
  }

  Future<void> _showVehicleActions(Vehicle vehicle) async {
    final action = await showModalBottomSheet<_VehicleAction>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFF161B1F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.white70),
                title: Text(
                  'Edit details',
                  style: textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
                onTap: () => Navigator.of(context).pop(_VehicleAction.edit),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.white70,
                ),
                title: Text(
                  'Manage photos',
                  style: textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
                onTap: () => Navigator.of(context).pop(_VehicleAction.photos),
              ),
              ListTile(
                enabled: !vehicle.isPrimary,
                leading: Icon(
                  Icons.star_outline,
                  color: vehicle.isPrimary ? Colors.white24 : Colors.white70,
                ),
                title: Text(
                  vehicle.isPrimary ? 'Already primary' : 'Set as primary',
                  style: textTheme.bodyLarge?.copyWith(
                    color: vehicle.isPrimary ? Colors.white38 : Colors.white,
                  ),
                ),
                onTap: vehicle.isPrimary
                    ? null
                    : () =>
                          Navigator.of(context).pop(_VehicleAction.setPrimary),
              ),
              const Divider(height: 0, color: Color(0xFF22303A)),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                title: Text(
                  'Delete vehicle',
                  style: textTheme.bodyLarge?.copyWith(color: Colors.redAccent),
                ),
                onTap: () => Navigator.of(context).pop(_VehicleAction.delete),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    switch (action) {
      case _VehicleAction.edit:
        await _editVehicle(vehicle);
        break;
      case _VehicleAction.setPrimary:
        await _setPrimaryVehicle(vehicle);
        break;
      case _VehicleAction.photos:
        _openVehicleDetails(vehicle);
        break;
      case _VehicleAction.delete:
        await _deleteVehicle(vehicle);
        break;
      case null:
        break;
    }
  }

  Future<void> _editVehicle(Vehicle vehicle) async {
    final updated = await Navigator.of(context).push<Vehicle>(
      MaterialPageRoute(
        builder: (_) => VehicleFormPage(initialVehicle: vehicle),
        fullscreenDialog: true,
      ),
    );
    if (updated == null || !mounted) return;
    await context.read<VehicleRepository>().saveVehicle(updated);
    _showSnackBar('Vehicle updated');
  }

  Future<void> _setPrimaryVehicle(Vehicle vehicle) async {
    await context.read<VehicleRepository>().setPrimaryVehicle(vehicle.id);
    if (!mounted) return;
    _showSnackBar('${vehicle.displayName} is now primary');
  }

  Future<void> _deleteVehicle(Vehicle vehicle) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF161B1F),
            title: const Text('Delete vehicle', style: TextStyle(color: Colors.white)),
            content: Text(
              'Are you sure you want to delete ${vehicle.displayName}? '
              'This action cannot be undone.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    await context.read<VehicleRepository>().deleteVehicle(vehicle.id);
    if (!mounted) return;
    _showSnackBar('${vehicle.displayName} deleted');
  }

  Future<bool> _confirmDeleteVehicle(Vehicle vehicle) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF161B1F),
            title: const Text('Delete vehicle', style: TextStyle(color: Colors.white)),
            content: Text(
              'Delete ${vehicle.displayName}? This cannot be undone.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !mounted) return false;
    await context.read<VehicleRepository>().deleteVehicle(vehicle.id);
    if (!mounted) return true;
    _showSnackBar('${vehicle.displayName} deleted');
    return true;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.fixed, content: Text(message)),
      );
  }

  void _openVehicleDetails(Vehicle vehicle) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VehicleDetailsPage(vehicle: vehicle),
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  const _VehicleTile({
    required this.vehicle,
    required this.onManage,
    required this.onSetPrimary,
    required this.onConfirmDismiss,
    required this.onViewDetails,
  });

  final Vehicle vehicle;
  final VoidCallback onManage;
  final VoidCallback? onSetPrimary;
  final Future<bool> Function() onConfirmDismiss;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final image = vehicle.photoUrl;
    return Dismissible(
      key: ValueKey(vehicle.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => onConfirmDismiss(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: GestureDetector(
          onTap: onViewDetails,
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              SizedBox(
                height: 220,
                width: double.infinity,
                child: image != null
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF161B1F),
                          alignment: Alignment.center,
                          child: const Icon(Icons.directions_car, size: 48),
                        ),
                      )
                    : Container(
                        color: const Color(0xFF161B1F),
                        alignment: Alignment.center,
                        child: const Icon(Icons.directions_car, size: 48),
                      ),
              ),
              Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.displayName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vehicle.make} ${vehicle.model}',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: vehicle.isPrimary ? null : onSetPrimary,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          vehicle.isPrimary
                              ? Icons.star
                              : Icons.star_border_outlined,
                          color: vehicle.isPrimary
                              ? Colors.amber
                              : Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          vehicle.isPrimary ? 'Primary' : 'Set primary',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white70),
                  onPressed: onViewDetails,
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white12,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onManage,
                  child: const Text('Manage'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyGarage extends StatelessWidget {
  const _EmptyGarage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: DriveEmptyState(
        icon: Icons.directions_car_filled,
        title: 'Add your first vehicle to get started.',
        message:
            'The current stub stores everything in memory.\nWe will hook up your local server or SQLite backend later.',
        useCard: false,
      ),
    );
  }
}

enum _VehicleAction { edit, photos, setPrimary, delete }

class _AddVehicleButton extends StatelessWidget {
  const _AddVehicleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Icon(Icons.add, size: 22),
      ),
    );
  }
}
