import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../widgets/vehicle/vehicle_stats_section.dart';
import '../../bloc/vehicle/vehicle_bloc.dart';
import '../../bloc/vehicle/vehicle_event.dart';
import '../../bloc/vehicle/vehicle_state.dart';
import 'vehicle_form_screen.dart';
import 'vehicle_photo_album_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String vehicleId;

  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    Logger.logNavigation(
      'INIT',
      'VehicleDetailScreen',
      data: 'Vehicle ID: ${widget.vehicleId}',
    );
    _tabController = TabController(length: 3, vsync: this);
    context.read<VehicleBloc>().add(LoadVehicleDetails(widget.vehicleId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<VehicleBloc, VehicleState>(
        builder: (context, state) {
          if (state is VehicleDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VehicleDetailsError) {
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
                    'Error loading vehicle',
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
                      context.read<VehicleBloc>().add(
                        LoadVehicleDetails(widget.vehicleId),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is VehicleDetailsLoaded) {
            return _buildVehicleDetails(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildVehicleDetails(VehicleDetailsLoaded state) {
    final vehicle = state.vehicle;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Logger.logNavigation('BACK_BUTTON', 'VehicleDetailScreen');
                Navigator.of(context).pop();
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                vehicle.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Vehicle photo or placeholder
                  if (vehicle.photoUrl != null)
                    Image.network(
                      vehicle.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(),
                    )
                  else
                    _buildPlaceholder(),

                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),

                  // Vehicle info overlay
                  Positioned(
                    bottom: 16.0,
                    left: 16.0,
                    right: 16.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vehicle.make} ${vehicle.model} ${vehicle.year}',
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (vehicle.odometerKm != null) ...[
                          const SizedBox(height: 4.0),
                          Row(
                            children: [
                              const Icon(
                                Icons.speed,
                                size: 16.0,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                '${vehicle.odometerKm!.toStringAsFixed(0)} km',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VehicleFormScreen(vehicle: vehicle),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
        ];
      },
      body: Column(
        children: [
          // Tab bar
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Photos'),
                Tab(text: 'Documents'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(state),
                _buildPhotosTab(state),
                _buildDocumentsTab(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(
          Icons.directions_car,
          size: 80.0,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildOverviewTab(VehicleDetailsLoaded state) {
    final vehicle = state.vehicle;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information
          _buildInfoSection('Basic Information', [
            _buildInfoRow('Make', vehicle.make),
            _buildInfoRow('Model', vehicle.model),
            _buildInfoRow('Year', vehicle.year.toString()),
            if (vehicle.vin != null) _buildInfoRow('VIN', vehicle.vin!),
            if (vehicle.licensePlate != null)
              _buildInfoRow('License Plate', vehicle.licensePlate!),
            if (vehicle.fuelType != null)
              _buildInfoRow('Fuel Type', vehicle.fuelType!),
            if (vehicle.odometerKm != null)
              _buildInfoRow(
                'Odometer',
                '${vehicle.odometerKm!.toStringAsFixed(0)} km',
              ),
          ]),

          // Purchase Information
          if (vehicle.purchaseDate != null || vehicle.purchasePrice != null)
            _buildInfoSection('Purchase Information', [
              if (vehicle.purchaseDate != null)
                _buildInfoRow(
                  'Purchase Date',
                  '${vehicle.purchaseDate!.day}/${vehicle.purchaseDate!.month}/${vehicle.purchaseDate!.year}',
                ),
              if (vehicle.purchasePrice != null)
                _buildInfoRow(
                  'Purchase Price',
                  '\$${vehicle.purchasePrice!.toStringAsFixed(2)}',
                ),
              if (vehicle.purchaseOdometerKm != null)
                _buildInfoRow(
                  'Purchase Odometer',
                  '${vehicle.purchaseOdometerKm!.toStringAsFixed(0)} km',
                ),
            ]),

          // Notes
          if (vehicle.notes != null && vehicle.notes!.isNotEmpty)
            _buildInfoSection('Notes', [_buildInfoRow('', vehicle.notes!)]),

          // Statistics
          VehicleStatsSection(
            stats: state.stats,
            onAddStat: () {
              // TODO: Navigate to add stat screen
            },
            onEditStat: (stat) {
              // TODO: Navigate to edit stat screen
            },
            onDeleteStat: (stat) {
              context.read<VehicleBloc>().add(DeleteVehicleStatEvent(stat.id));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosTab(VehicleDetailsLoaded state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (state.photos.isEmpty)
            _buildEmptyState(
              icon: Icons.photo_library_outlined,
              title: 'No photos yet',
              subtitle: 'Add photos to your vehicle',
              actionText: 'Add Photo',
              onAction: () {
                // TODO: Navigate to add photo screen
              },
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: state.photos.length,
              itemBuilder: (context, index) {
                final photo = state.photos[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => VehiclePhotoAlbumScreen(
                            vehicleId: widget.vehicleId,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      photo.filePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.broken_image,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(VehicleDetailsLoaded state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (state.documents.isEmpty)
            _buildEmptyState(
              icon: Icons.description_outlined,
              title: 'No documents yet',
              subtitle: 'Add documents to your vehicle',
              actionText: 'Add Document',
              onAction: () {
                // TODO: Navigate to add document screen
              },
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.documents.length,
              itemBuilder: (context, index) {
                final document = state.documents[index];
                return ListTile(
                  leading: Icon(
                    _getDocumentIcon(document.type ?? ''),
                    color: AppColors.primary,
                  ),
                  title: Text(document.name),
                  subtitle: Text(document.type ?? ''),
                  trailing: IconButton(
                    onPressed: () {
                      // TODO: Open document
                    },
                    icon: const Icon(Icons.open_in_new),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8.0),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.0,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Container(
      margin: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Icon(icon, size: 64.0, color: AppColors.textSecondary),
          const SizedBox(height: 16.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.0, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24.0),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add),
            label: Text(actionText),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'insurance':
        return Icons.security;
      case 'registration':
        return Icons.description;
      case 'warranty':
        return Icons.verified;
      case 'manual':
        return Icons.menu_book;
      default:
        return Icons.description;
    }
  }
}
