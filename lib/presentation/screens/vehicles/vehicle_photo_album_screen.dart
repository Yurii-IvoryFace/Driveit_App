import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../core/theme/app_colors.dart';
import '../../bloc/vehicle/vehicle_bloc.dart';
import '../../bloc/vehicle/vehicle_event.dart';
import '../../bloc/vehicle/vehicle_state.dart';

class VehiclePhotoAlbumScreen extends StatefulWidget {
  final String vehicleId;
  final int initialIndex;

  const VehiclePhotoAlbumScreen({
    super.key,
    required this.vehicleId,
    this.initialIndex = 0,
  });

  @override
  State<VehiclePhotoAlbumScreen> createState() =>
      _VehiclePhotoAlbumScreenState();
}

class _VehiclePhotoAlbumScreenState extends State<VehiclePhotoAlbumScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    context.read<VehicleBloc>().add(LoadVehiclePhotosEvent(widget.vehicleId));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Album'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add photo
            },
            icon: const Icon(Icons.add_photo_alternate),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: BlocBuilder<VehicleBloc, VehicleState>(
        builder: (context, state) {
          if (state is VehiclePhotosLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (state is VehiclePhotosError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64.0,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Error loading photos',
                    style: TextStyle(fontSize: 18.0, color: Colors.white70),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      context.read<VehicleBloc>().add(
                        LoadVehiclePhotosEvent(widget.vehicleId),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is VehiclePhotosLoaded) {
            if (state.photos.isEmpty) {
              return _buildEmptyState();
            }

            return _buildPhotoViewer(state.photos);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.photo_library_outlined,
            size: 80.0,
            color: Colors.white70,
          ),
          const SizedBox(height: 24.0),
          const Text(
            'No photos yet',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Add photos to your vehicle',
            style: TextStyle(fontSize: 16.0, color: Colors.white70),
          ),
          const SizedBox(height: 32.0),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Add photo
            },
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Add Photo'),
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

  Widget _buildPhotoViewer(List<VehiclePhoto> photos) {
    return Stack(
      children: [
        // Photo viewer
        PageView.builder(
          controller: _pageController,
          itemCount: photos.length,
          onPageChanged: (index) {
            setState(() {});
          },
          itemBuilder: (context, index) {
            final photo = photos[index];
            return InteractiveViewer(
              child: Center(
                child: Image.network(
                  photo.filePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surface,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 64.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Photo counter
        Positioned(
          top: 16.0,
          left: 16.0,
          right: 16.0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              '${_getCurrentIndex() + 1} of ${photos.length}',
              style: const TextStyle(color: Colors.white, fontSize: 14.0),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Photo info
        Positioned(
          bottom: 16.0,
          left: 16.0,
          right: 16.0,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photos[_getCurrentIndex()].name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (photos[_getCurrentIndex()].description != null) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    photos[_getCurrentIndex()].description ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14.0,
                    ),
                  ),
                ],
                const SizedBox(height: 8.0),
                Text(
                  'Added ${_formatDate(photos[_getCurrentIndex()].createdAt)}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12.0),
                ),
              ],
            ),
          ),
        ),

        // Action buttons
        Positioned(
          bottom: 100.0,
          right: 16.0,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: "photo_edit_button",
                onPressed: () {
                  // TODO: Edit photo
                },
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                child: const Icon(Icons.edit, color: Colors.white),
              ),
              const SizedBox(height: 8.0),
              FloatingActionButton(
                heroTag: "photo_delete_button",
                onPressed: () {
                  _showDeleteDialog(photos[_getCurrentIndex()]);
                },
                backgroundColor: Colors.red.withValues(alpha: 0.8),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _getCurrentIndex() {
    return _pageController.hasClients ? _pageController.page?.round() ?? 0 : 0;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteDialog(VehiclePhoto photo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: Text('Are you sure you want to delete "${photo.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<VehicleBloc>().add(
                DeleteVehiclePhotoEvent(photo.id),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
