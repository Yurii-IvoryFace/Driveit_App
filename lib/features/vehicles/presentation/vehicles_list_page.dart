import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_repository.dart';
import 'package:driveit_app/features/vehicles/presentation/vehicle_create_page.dart';
import 'package:driveit_app/features/vehicles/presentation/vehicle_details_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class VehiclesListPage extends StatefulWidget {
  const VehiclesListPage({super.key});

  @override
  VehiclesListPageState createState() => VehiclesListPageState();
}

class VehiclesListPageState extends State<VehiclesListPage> {
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<VehicleRepository>();
    return Stack(
      fit: StackFit.expand,
      children: [
        StreamBuilder<List<Vehicle>>(
          stream: repository.watchVehicles(),
          builder: (context, snapshot) {
            final vehicles = snapshot.data ?? const <Vehicle>[];
            if (vehicles.isEmpty) {
              return const _EmptyGarage();
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: vehicles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
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
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            onPressed: showAddVehicleDialog,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Future<void> showAddVehicleDialog() async {
    final vehicle = await Navigator.of(context).push<Vehicle>(
      MaterialPageRoute(
        builder: (_) => const VehicleCreatePage(),
        fullscreenDialog: true,
      ),
    );
    if (vehicle == null || !mounted) return;
    await context.read<VehicleRepository>().saveVehicle(vehicle);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${vehicle.displayName} added to your garage')),
    );
  }

  Future<Vehicle?> _showVehicleForm({Vehicle? initial}) async {
    final displayNameController = TextEditingController(
      text: initial?.displayName ?? '',
    );
    final makeController = TextEditingController(text: initial?.make ?? '');
    final modelController = TextEditingController(text: initial?.model ?? '');
    final yearController = TextEditingController(
      text: initial != null ? initial.year.toString() : '',
    );
    final licenseController = TextEditingController(
      text: initial?.licensePlate ?? '',
    );

    Vehicle? result;

    await showDialog<void>(
      context: context,
      builder: (context) {
        final isEditing = initial != null;
        return AlertDialog(
          title: Text(isEditing ? 'Edit vehicle' : 'New vehicle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    hintText: 'e.g. Family SUV',
                  ),
                ),
                TextField(
                  controller: makeController,
                  decoration: const InputDecoration(labelText: 'Make'),
                ),
                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(labelText: 'Model'),
                ),
                TextField(
                  controller: yearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Year'),
                ),
                TextField(
                  controller: licenseController,
                  decoration: const InputDecoration(
                    labelText: 'License plate (optional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final year = int.tryParse(yearController.text);
                if (displayNameController.text.isEmpty ||
                    makeController.text.isEmpty ||
                    modelController.text.isEmpty ||
                    year == null) {
                  return;
                }

                if (initial case Vehicle existing) {
                  result = existing.copyWith(
                    displayName: displayNameController.text,
                    make: makeController.text,
                    model: modelController.text,
                    year: year,
                    licensePlate: licenseController.text.isEmpty
                        ? null
                        : licenseController.text,
                  );
                } else {
                  result = Vehicle(
                    id: _uuid.v4(),
                    displayName: displayNameController.text,
                    make: makeController.text,
                    model: modelController.text,
                    year: year,
                    licensePlate: licenseController.text.isEmpty
                        ? null
                        : licenseController.text,
                  );
                }

                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    return result;
  }

  Future<void> _showVehicleActions(Vehicle vehicle) async {
    final action = await showModalBottomSheet<_VehicleAction>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFF161B1F),
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
              const Divider(height: 0),
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
    final updated = await _showVehicleForm(initial: vehicle);
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
            title: const Text('Delete vehicle'),
            content: Text(
              'Are you sure you want to delete ${vehicle.displayName}? '
              'This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
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
            title: const Text('Delete vehicle'),
            content: Text(
              'Delete ${vehicle.displayName}? This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
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
                        errorBuilder: (_, __, ___) => Container(
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_car_filled, size: 72, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Add your first vehicle to get started.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'The current stub stores everything in memory.\nWe will hook up your local server or SQLite backend later.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

enum _VehicleAction { edit, photos, setPrimary, delete }
