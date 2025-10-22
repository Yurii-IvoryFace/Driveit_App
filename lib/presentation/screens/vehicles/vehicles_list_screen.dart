import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../widgets/vehicle/vehicle_card.dart';
import '../../bloc/vehicle/vehicle_bloc.dart';
import '../../bloc/vehicle/vehicle_event.dart';
import '../../bloc/vehicle/vehicle_state.dart';
import 'vehicle_form_screen.dart';
import 'vehicle_detail_screen.dart';

class VehiclesListScreen extends StatefulWidget {
  const VehiclesListScreen({super.key});

  @override
  State<VehiclesListScreen> createState() => _VehiclesListScreenState();
}

class _VehiclesListScreenState extends State<VehiclesListScreen>
    with WidgetsBindingObserver {
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    Logger.logNavigation('INIT', 'VehiclesListScreen');
    WidgetsBinding.instance.addObserver(this);
    context.read<VehicleBloc>().add(LoadVehicles());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      // Reload vehicles when app resumes
      context.read<VehicleBloc>().add(LoadVehicles());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Logger.logNavigation('MANUAL_REFRESH', 'VehiclesListScreen');
              context.read<VehicleBloc>().add(LoadVehicles());
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            tooltip: _isGridView ? 'List view' : 'Grid view',
          ),
        ],
      ),
      body: BlocListener<VehicleBloc, VehicleState>(
        listener: (context, state) {
          // Handle state changes if needed
        },
        child: BlocBuilder<VehicleBloc, VehicleState>(
          builder: (context, state) {
            if (state is VehicleLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is VehicleError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.0,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Error loading vehicles',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        context.read<VehicleBloc>().add(LoadVehicles());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is VehicleLoaded) {
              if (state.vehicles.isEmpty) {
                return _buildEmptyState();
              }

              return _buildVehiclesList(state.vehicles);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "vehicle_add_button",
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const VehicleFormScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80.0,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 24.0),
          Text(
            'No vehicles yet',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Add your first vehicle to get started',
            style: TextStyle(fontSize: 16.0, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32.0),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const VehicleFormScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Vehicle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesList(List<Vehicle> vehicles) {
    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          return VehicleCard(
            vehicle: vehicle,
            onTap: () {
              Logger.logNavigation(
                'NAVIGATE_TO_DETAIL',
                'VehicleDetailScreen',
                data: 'Vehicle ID: ${vehicle.id}',
              );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      VehicleDetailScreen(vehicleId: vehicle.id),
                ),
              );
            },
            onEdit: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VehicleFormScreen(vehicle: vehicle),
                ),
              );
            },
            onDelete: () => _showDeleteDialog(vehicle),
            onSetPrimary: () => _setPrimaryVehicle(vehicle),
          );
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          return VehicleCard(
            vehicle: vehicle,
            onTap: () {
              Logger.logNavigation(
                'NAVIGATE_TO_DETAIL',
                'VehicleDetailScreen',
                data: 'Vehicle ID: ${vehicle.id}',
              );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      VehicleDetailScreen(vehicleId: vehicle.id),
                ),
              );
            },
            onEdit: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VehicleFormScreen(vehicle: vehicle),
                ),
              );
            },
            onDelete: () => _showDeleteDialog(vehicle),
            onSetPrimary: () => _setPrimaryVehicle(vehicle),
          );
        },
      );
    }
  }

  void _setPrimaryVehicle(Vehicle vehicle) {
    context.read<VehicleBloc>().add(SetPrimaryVehicleEvent(vehicle.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${vehicle.name} is now your primary vehicle'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showDeleteDialog(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Are you sure you want to delete "${vehicle.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<VehicleBloc>().add(DeleteVehicleEvent(vehicle.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
