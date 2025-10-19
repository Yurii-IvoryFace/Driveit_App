import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_document.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_photo.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_repository.dart';
import 'package:driveit_app/features/vehicles/presentation/vehicle_form_page.dart';
import 'package:driveit_app/shared/widgets/widgets.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class VehicleDetailsPage extends StatefulWidget {
  const VehicleDetailsPage({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  final _uuid = const Uuid();
  VehiclePhotoCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<VehicleRepository>();
    return StreamBuilder<List<Vehicle>>(
      stream: repository.watchVehicles(),
      builder: (context, snapshot) {
        final current = _resolveVehicle(snapshot.data) ?? widget.vehicle;
        final filteredPhotos = _filteredPhotos(current.photos);
        final counts = _countsByCategory(current.photos);
        return Scaffold(
          backgroundColor: const Color(0xFF0F1418),
          body: CustomScrollView(
            slivers: [
              _VehicleHeroSection(vehicle: current),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _VehicleInfoCard(
                    vehicle: current,
                    onEdit: () => _showEditOverviewSheet(current),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: _VehicleStatRow(vehicle: current),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: _VehicleDocumentSection(
                    documents: current.documents,
                    onAddDocument: () => _showAddDocumentSheet(current),
                    onDeleteDocument: (doc) =>
                        _confirmDeleteDocument(current, doc),
                    onOpenDocument: _openDocument,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: _PhotoToolbar(
                    selected: _selectedCategory,
                    counts: counts,
                    totalCount: current.photos.length,
                    onCategorySelected: _onCategorySelected,
                    onAddPhoto: () => _showAddPhotoSheet(current),
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(top: 12)),
              _VehiclePhotoSection(
                vehicle: current,
                photos: filteredPhotos,
                onPhotoTap: _openPhotoViewer,
                onDeletePhoto: (photo) => _confirmDeletePhoto(current, photo),
                onAddPhoto: () => _showAddPhotoSheet(current),
                onSetCover: (photo) => _setCoverPhoto(current, photo),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          ),
        );
      },
    );
  }

  void _onCategorySelected(VehiclePhotoCategory? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  Vehicle? _resolveVehicle(List<Vehicle>? vehicles) {
    if (vehicles == null) return null;
    return vehicles.firstWhere(
      (item) => item.id == widget.vehicle.id,
      orElse: () => widget.vehicle,
    );
  }

  List<VehiclePhoto> _filteredPhotos(List<VehiclePhoto> photos) {
    final sorted = [...photos]..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    if (_selectedCategory == null) {
      return sorted;
    }
    return sorted
        .where((photo) => photo.category == _selectedCategory)
        .toList();
  }

  Map<VehiclePhotoCategory, int> _countsByCategory(List<VehiclePhoto> photos) {
    final counts = <VehiclePhotoCategory, int>{};
    for (final photo in photos) {
      counts.update(photo.category, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  Future<void> _showEditOverviewSheet(Vehicle vehicle) async {
    final repository = context.read<VehicleRepository>();
    final updated = await Navigator.of(context).push<Vehicle>(
      MaterialPageRoute(
        builder: (_) => VehicleFormPage(initialVehicle: vehicle),
        fullscreenDialog: true,
      ),
    );
    if (updated == null) return;
    await repository.saveVehicle(updated);
    if (!mounted) return;
    _showFloatingMessage('Vehicle overview updated');
  }

  Future<void> _showAddDocumentSheet(Vehicle vehicle) async {
    final repository = context.read<VehicleRepository>();
    final newDocument = await showModalBottomSheet<VehicleDocument>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141A1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final titleController = TextEditingController();
        final notesController = TextEditingController();
        final formKey = GlobalKey<FormState>();
        var category = VehicleDocumentCategory.other;
        String? selectedDataUrl;
        String? selectedFileName;
        int? selectedFileSize;
        var showPickerError = false;

        String formatFileSize(int bytes) {
          const units = ['B', 'KB', 'MB', 'GB'];
          var size = bytes.toDouble();
          var unitIndex = 0;
          while (size >= 1024 && unitIndex < units.length - 1) {
            size /= 1024;
            unitIndex++;
          }
          final decimals = unitIndex == 0 || size >= 10 ? 0 : 1;
          return '${size.toStringAsFixed(decimals)} ${units[unitIndex]}';
        }

        void submit(StateSetter setModalState) {
          final isValid = formKey.currentState?.validate() ?? false;
          if (!isValid) return;
          if (selectedDataUrl == null) {
            setModalState(() => showPickerError = true);
            return;
          }
          Navigator.of(context).pop(
            VehicleDocument(
              id: _uuid.v4(),
              title: titleController.text.trim(),
              category: category,
              url: selectedDataUrl!,
              uploadedAt: DateTime.now(),
              notes: notesController.text.trim().isEmpty
                  ? null
                  : notesController.text.trim(),
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                Future<void> pickDocument() async {
                  try {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: const [
                        'pdf',
                        'doc',
                        'docx',
                        'jpg',
                        'jpeg',
                        'png',
                        'heic',
                        'txt',
                      ],
                      withData: true,
                    );
                    if (result == null) return;
                    final file = result.files.single;
                    final bytes = file.bytes;
                    if (bytes == null) return;
                    final dataUrl =
                        'data:${_mimeTypeForDocument(file.extension)};base64,${base64Encode(bytes)}';
                    setModalState(() {
                      selectedDataUrl = dataUrl;
                      selectedFileName = file.name;
                      selectedFileSize = bytes.length;
                      showPickerError = false;
                    });
                  } catch (_) {}
                }

                final theme = Theme.of(context);
                final secondaryText = selectedFileName == null
                    ? 'PDF, DOC, JPG up to 15 MB'
                    : selectedFileSize == null
                    ? 'Tap to replace'
                    : '${formatFileSize(selectedFileSize!)} • Tap to replace';

                return Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Attach document',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: pickDocument,
                            icon: const Icon(
                              Icons.upload_file_outlined,
                              size: 18,
                            ),
                            label: const Text('Select file'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'e.g. Insurance policy',
                        ),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Please provide a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: pickDocument,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A2024),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: showPickerError
                                  ? theme.colorScheme.error
                                  : Colors.white24,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.tealAccent.withValues(
                                    alpha: 0.18,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.insert_drive_file_outlined,
                                  color: Colors.tealAccent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedFileName ?? 'Select a document',
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      secondaryText,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: Colors.white60),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.white38,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (showPickerError)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Please select a document',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<VehicleDocumentCategory>(
                        initialValue: category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: VehicleDocumentCategory.values
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() => category = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: () => submit(setModalState),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (!mounted || newDocument == null) return;

    final updatedVehicle = vehicle.copyWith(
      documents: [...vehicle.documents, newDocument],
    );
    await repository.saveVehicle(updatedVehicle);
    if (!mounted) return;
    _showFloatingMessage('Document attached');
  }

  Future<void> _confirmDeleteDocument(
    Vehicle vehicle,
    VehicleDocument document,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove document'),
          content: Text(
            'Remove "${document.title}" from ${vehicle.displayName}? '
            'This will only affect the local record.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await _deleteDocument(vehicle, document);
  }

  Future<void> _deleteDocument(
    Vehicle vehicle,
    VehicleDocument document,
  ) async {
    final repository = context.read<VehicleRepository>();
    final updatedDocuments = vehicle.documents
        .where((item) => item.id != document.id)
        .toList();
    final updatedVehicle = vehicle.copyWith(documents: updatedDocuments);
    await repository.saveVehicle(updatedVehicle);
    if (!mounted) return;
    _showFloatingMessage('Document removed');
  }

  String _mimeTypeForDocument(String? extension) {
    switch ((extension ?? '').toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'heic':
        return 'image/heic';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  void _openDocument(VehicleDocument document) {
    _showFloatingMessage('Opening ${document.title}');
  }

  Future<void> _showAddPhotoSheet(Vehicle vehicle) async {
    final repository = context.read<VehicleRepository>();
    final newPhotos = await showModalBottomSheet<List<VehiclePhoto>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141A1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AddPhotoSheet(uuid: _uuid),
    );

    if (!mounted || newPhotos == null || newPhotos.isEmpty) return;

    var updatedVehicle = vehicle.copyWith(
      photos: [...vehicle.photos, ...newPhotos],
    );
    if (vehicle.photoUrl == null) {
      updatedVehicle = updatedVehicle.copyWith(photoUrl: newPhotos.first.url);
    }
    await repository.saveVehicle(updatedVehicle);
    if (!mounted) return;
    final addedCount = newPhotos.length;
    _showFloatingMessage(
      addedCount == 1
          ? 'Photo added to album'
          : '$addedCount photos added to album',
    );
  }

  Future<void> _confirmDeletePhoto(Vehicle vehicle, VehiclePhoto photo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete photo'),
          content: const Text(
            'This photo will be removed from the vehicle album. '
            'This action cannot be undone.',
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
        );
      },
    );

    if (confirmed != true) return;
    await _deletePhoto(vehicle, photo);
  }

  Future<void> _deletePhoto(Vehicle vehicle, VehiclePhoto photo) async {
    final repository = context.read<VehicleRepository>();
    final updatedPhotos = vehicle.photos
        .where((item) => item.id != photo.id)
        .toList();
    var updatedVehicle = vehicle.copyWith(photos: updatedPhotos);

    if (updatedPhotos.isEmpty) {
      updatedVehicle = updatedVehicle.copyWith(photoUrl: null);
    } else if (vehicle.photoUrl == photo.url) {
      updatedVehicle = updatedVehicle.copyWith(
        photoUrl: updatedPhotos.first.url,
      );
    }

    await repository.saveVehicle(updatedVehicle);
    if (!mounted) return;
    _showFloatingMessage('Photo removed');
  }

  Future<void> _openPhotoViewer(VehiclePhoto photo) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close photo',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Material(
            color: Colors.black.withValues(alpha: 0.9),
            child: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: Hero(
                      tag: 'vehicle-photo-${photo.id}',
                      child: InteractiveViewer(
                        child: Image.network(
                          photo.url,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.broken_image_outlined,
                                size: 64,
                                color: Colors.white54,
                              ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  Future<void> _setCoverPhoto(Vehicle vehicle, VehiclePhoto photo) async {
    final repository = context.read<VehicleRepository>();
    final updatedVehicle = vehicle.copyWith(photoUrl: photo.url);
    await repository.saveVehicle(updatedVehicle);
    if (!mounted) return;
    _showFloatingMessage('Main photo updated');
  }

  void _showFloatingMessage(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.fixed,
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

class _VehicleHeroSection extends StatelessWidget {
  const _VehicleHeroSection({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final image = vehicle.photoUrl;
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF0F1418),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(vehicle.displayName),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null)
              Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _PlaceholderImage(vehicle),
              )
            else
              _PlaceholderImage(vehicle),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.make} ${vehicle.model}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Year ${vehicle.year}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleInfoCard extends StatelessWidget {
  const _VehicleInfoCard({required this.vehicle, required this.onEdit});

  final Vehicle vehicle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DriveCard(
      color: const Color(0xFF161B1F),
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Vehicle Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit overview',
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _VehicleHeadline(vehicle: vehicle),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (vehicle.vehicleType != null)
                InfoChip(
                  icon: Icons.category_outlined,
                  label: vehicle.vehicleType!,
                ),
              if (vehicle.fuelType != null)
                InfoChip(
                  icon: Icons.local_gas_station_outlined,
                  label: vehicle.fuelType!,
                ),
              if (vehicle.transmission != null)
                InfoChip(
                  icon: Icons.settings_suggest_outlined,
                  label: vehicle.transmission!,
                ),
              if (vehicle.licensePlate != null)
                InfoChip(
                  icon: Icons.confirmation_num_outlined,
                  label: vehicle.licensePlate!,
                ),
              if (vehicle.vin != null)
                InfoChip(icon: Icons.qr_code_2, label: vehicle.vin!),
            ],
          ),
        ],
      ),
    );
  }
}

class _VehicleHeadline extends StatelessWidget {
  const _VehicleHeadline({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    );
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: Colors.white70,
    );

    final makeModel = [
      vehicle.make.trim(),
      vehicle.model.trim(),
    ].where((value) => value.isNotEmpty).join(' ');
    final subtitleParts = <String>[
      if (makeModel.isNotEmpty) makeModel,
      'Year ${vehicle.year}',
    ];
    final subtitle = subtitleParts.join(' • ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _VehicleBrandBadge(vehicle: vehicle),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(vehicle.displayName, style: titleStyle),
              const SizedBox(height: 4),
              Text(subtitle, style: subtitleStyle),
            ],
          ),
        ),
      ],
    );
  }
}

class _VehicleBrandBadge extends StatelessWidget {
  const _VehicleBrandBadge({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logoUrl = vehicle.brandLogoUrl ?? vehicle.brandLogoThumbUrl;
    final background = const Color(0xFF1F2529);
    final radius = 30.0;

    if (logoUrl == null || logoUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: background,
        child: Text(
          _vehicleInitials(vehicle.make),
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: background,
      child: ClipOval(
        child: Image.network(
          logoUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Text(
            _vehicleInitials(vehicle.make),
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

String _vehicleInitials(String value) {
  final tokens = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (tokens.isEmpty) return '?';
  final first = tokens.first;
  final second = tokens.length > 1
      ? tokens[1]
      : (first.length > 1 ? first.substring(1) : '');
  final letters =
      (first.isNotEmpty ? first[0] : '') + (second.isNotEmpty ? second[0] : '');
  return letters.trim().isEmpty ? '?' : letters.toUpperCase();
}

class _VehicleStatRow extends StatelessWidget {
  const _VehicleStatRow({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final stats = <_VehicleStat>[];
    if (vehicle.odometerKm != null) {
      stats.add(
        _VehicleStat(
          icon: Icons.speed_outlined,
          label: 'Odometer',
          value: '${vehicle.odometerKm} km',
        ),
      );
    }
    if (vehicle.nextService != null) {
      stats.add(
        _VehicleStat(
          icon: Icons.build_circle_outlined,
          label: 'Next service',
          value: _formatDate(context, vehicle.nextService),
        ),
      );
    }
    if (vehicle.insuranceExpiry != null) {
      stats.add(
        _VehicleStat(
          icon: Icons.shield_outlined,
          label: 'Insurance',
          value: _formatDate(context, vehicle.insuranceExpiry),
        ),
      );
    }
    if (vehicle.registrationExpiry != null) {
      stats.add(
        _VehicleStat(
          icon: Icons.assignment_turned_in_outlined,
          label: 'Registration',
          value: _formatDate(context, vehicle.registrationExpiry),
        ),
      );
    }

    if (stats.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: stats
            .map(
              (stat) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _VehicleStatCard(stat: stat),
              ),
            )
            .toList(),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) return '—';
    return MaterialLocalizations.of(context).formatShortDate(date);
  }
}

class _VehicleStat {
  const _VehicleStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _VehicleStatCard extends StatelessWidget {
  const _VehicleStatCard({required this.stat});

  final _VehicleStat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: const Color(0xFF161B1F),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(18),
      constraints: const BoxConstraints(minHeight: 120),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(stat.icon, color: Colors.tealAccent),
          const SizedBox(height: 12),
          Text(
            stat.label,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            stat.value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleDocumentSection extends StatelessWidget {
  const _VehicleDocumentSection({
    required this.documents,
    required this.onAddDocument,
    required this.onDeleteDocument,
    required this.onOpenDocument,
  });

  final List<VehicleDocument> documents;
  final VoidCallback onAddDocument;
  final ValueChanged<VehicleDocument> onDeleteDocument;
  final ValueChanged<VehicleDocument> onOpenDocument;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DriveSectionHeader(
          title: 'Documents',
          trailing: FilledButton.icon(
            onPressed: onAddDocument,
            icon: const Icon(Icons.attach_file),
            label: const Text('Add document'),
          ),
        ),
        const SizedBox(height: 12),
        if (documents.isEmpty)
          const DriveEmptyState(
            icon: Icons.description_outlined,
            title: 'No documents yet',
            message:
                'Attach insurance, registration or service files to keep everything in one place.',
            alignment: CrossAxisAlignment.start,
            textAlign: TextAlign.start,
          )
        else
          Column(
            children: documents
                .map(
                  (document) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _VehicleDocumentTile(
                      document: document,
                      onOpen: () => onOpenDocument(document),
                      onDelete: () => onDeleteDocument(document),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

enum _DocumentMenuAction { open, delete }

class _VehicleDocumentTile extends StatelessWidget {
  const _VehicleDocumentTile({
    required this.document,
    required this.onOpen,
    required this.onDelete,
  });

  final VehicleDocument document;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uploadedOn = MaterialLocalizations.of(
      context,
    ).formatShortDate(document.uploadedAt);
    return DriveCard(
      color: const Color(0xFF161B1F),
      borderRadius: 18,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onOpen,
        leading: CircleAvatar(
          backgroundColor: Colors.tealAccent.withValues(alpha: 0.25),
          child: Icon(
            _iconForCategory(document.category),
            color: Colors.tealAccent,
          ),
        ),
        title: Text(
          document.title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${document.category.label} • Uploaded $uploadedOn',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
            ),
            if (document.notes != null) ...[
              const SizedBox(height: 4),
              Text(
                document.notes!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<_DocumentMenuAction>(
          icon: const Icon(Icons.more_vert, color: Colors.white70),
          color: const Color(0xFF1F2428),
          onSelected: (value) {
            switch (value) {
              case _DocumentMenuAction.open:
                onOpen();
                break;
              case _DocumentMenuAction.delete:
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: _DocumentMenuAction.open,
              child: Text('Open document'),
            ),
            PopupMenuItem(
              value: _DocumentMenuAction.delete,
              child: Text('Remove'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForCategory(VehicleDocumentCategory category) {
    switch (category) {
      case VehicleDocumentCategory.insurance:
        return Icons.shield_outlined;
      case VehicleDocumentCategory.registration:
        return Icons.assignment_turned_in_outlined;
      case VehicleDocumentCategory.maintenance:
        return Icons.build_outlined;
      case VehicleDocumentCategory.purchase:
        return Icons.receipt_long_outlined;
      case VehicleDocumentCategory.other:
        return Icons.insert_drive_file_outlined;
    }
  }
}

class _AddPhotoSheet extends StatefulWidget {
  const _AddPhotoSheet({required this.uuid});

  final Uuid uuid;

  @override
  State<_AddPhotoSheet> createState() => _AddPhotoSheetState();
}

class _AddPhotoSheetState extends State<_AddPhotoSheet> {
  final TextEditingController _notesController = TextEditingController();
  VehiclePhotoCategory _category = VehiclePhotoCategory.exterior;
  final List<_PendingPhoto> _pendingPhotos = [];
  final Set<String> _selectedAssetIds = <String>{};
  bool _showPickerError = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    try {
      if (kIsWeb) {
        await _pickFromFiles();
        return;
      }
      final picker = ImagePicker();
      final images = await picker.pickMultiImage();
      if (!mounted || images.isEmpty) return;
      final additions = <_PendingPhoto>[];
      for (final image in images) {
        final bytes = await image.readAsBytes();
        final isPng = image.path.toLowerCase().endsWith('.png');
        final mime = isPng ? 'image/png' : 'image/jpeg';
        additions.add(
          _PendingPhoto(dataUrl: 'data:$mime;base64,${base64Encode(bytes)}'),
        );
      }
      if (additions.isEmpty || !mounted) return;
      setState(() {
        _pendingPhotos.addAll(additions);
        _showPickerError = false;
      });
    } catch (_) {}
  }

  Future<void> _pickFromFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
        allowMultiple: true,
      );
      if (!mounted || result == null) return;
      final additions = <_PendingPhoto>[];
      for (final file in result.files) {
        final bytes = file.bytes;
        if (bytes == null) continue;
        final ext = (file.extension ?? 'jpg').toLowerCase();
        final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
        additions.add(
          _PendingPhoto(dataUrl: 'data:$mime;base64,${base64Encode(bytes)}'),
        );
      }
      if (additions.isEmpty) return;
      setState(() {
        _pendingPhotos.addAll(additions);
        _showPickerError = false;
      });
    } catch (_) {}
  }

  Future<void> _toggleAssetSelection(AssetEntity asset) async {
    try {
      final origin = await asset.originBytes;
      if (!mounted || origin == null) return;
      final mime = asset.mimeType ?? 'image/jpeg';
      setState(() {
        if (_selectedAssetIds.remove(asset.id)) {
          _pendingPhotos.removeWhere((item) => item.assetId == asset.id);
        } else {
          _selectedAssetIds.add(asset.id);
          _pendingPhotos.add(
            _PendingPhoto(
              dataUrl: 'data:$mime;base64,${base64Encode(origin)}',
              assetId: asset.id,
            ),
          );
        }
        _showPickerError = false;
      });
    } catch (_) {}
  }

  void _removePendingAt(int index) {
    setState(() {
      final removed = _pendingPhotos.removeAt(index);
      if (removed.assetId != null) {
        _selectedAssetIds.remove(removed.assetId);
      }
    });
  }

  Future<void> _showPreview(String dataUrl) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 40,
          ),
          child: InteractiveViewer(
            child: Image.network(
              dataUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                height: 240,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 48,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    if (_pendingPhotos.isEmpty) {
      setState(() => _showPickerError = true);
      return;
    }
    final note = _notesController.text.trim();
    final photos = _pendingPhotos
        .map(
          (item) => VehiclePhoto(
            id: widget.uuid.v4(),
            url: item.dataUrl,
            category: _category,
            addedAt: DateTime.now(),
            notes: note.isEmpty ? null : note,
          ),
        )
        .toList();
    Navigator.of(context).pop(photos);
  }

  @override
  Widget build(BuildContext context) {
    final galleryGrid =
        (!kIsWeb &&
            WidgetsBinding.instance.runtimeType.toString().contains('Test') ==
                false)
        ? SizedBox(
            height: 220,
            child: FutureBuilder<PermissionState>(
              future: PhotoManager.requestPermissionExtend(),
              builder: (context, permSnap) {
                if (!permSnap.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                if (!permSnap.data!.hasAccess) {
                  return Center(
                    child: TextButton(
                      onPressed: () async {
                        final state =
                            await PhotoManager.requestPermissionExtend();
                        if (state.hasAccess) {
                          if (mounted) setState(() {});
                        } else {
                          await PhotoManager.openSetting();
                        }
                      },
                      child: const Text('Allow gallery access'),
                    ),
                  );
                }
                return FutureBuilder<List<AssetPathEntity>>(
                  future: PhotoManager.getAssetPathList(
                    type: RequestType.image,
                    onlyAll: true,
                  ),
                  builder: (context, snap) {
                    if (!snap.hasData || snap.data!.isEmpty) {
                      return const Center(child: Text('No images found'));
                    }
                    final path = snap.data!.first;
                    return FutureBuilder<List<AssetEntity>>(
                      future: path.getAssetListPaged(page: 0, size: 60),
                      builder: (context, assetSnap) {
                        if (!assetSnap.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }
                        final assets = assetSnap.data!;
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                              ),
                          itemCount: assets.length,
                          itemBuilder: (context, index) {
                            final asset = assets[index];
                            return FutureBuilder<Uint8List?>(
                              future: asset.thumbnailDataWithSize(
                                const ThumbnailSize(200, 200),
                              ),
                              builder: (context, thumbSnap) {
                                final bytes = thumbSnap.data;
                                if (bytes == null) {
                                  return const ColoredBox(
                                    color: Colors.black26,
                                  );
                                }
                                final isSelected = _selectedAssetIds.contains(
                                  asset.id,
                                );
                                return InkWell(
                                  onTap: () => _toggleAssetSelection(asset),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.memory(bytes, fit: BoxFit.cover),
                                      if (isSelected)
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.tealAccent,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          )
        : null;

    final Widget preview = _pendingPhotos.isEmpty
        ? GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _pickFromGallery,
            child: Container(
              height: 160,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _showPickerError
                      ? Theme.of(context).colorScheme.error
                      : Colors.white24,
                  width: 1.1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Colors.white70,
                    size: 34,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to add photos',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select one or many from your gallery',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white54),
                  ),
                ],
              ),
            ),
          )
        : SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _pendingPhotos.length,
              separatorBuilder: (context, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final pending = _pendingPhotos[index];
                return GestureDetector(
                  onTap: () => _showPreview(pending.dataUrl),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          pending.dataUrl,
                          width: 140,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const _PhotoPlaceholder(),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: () => _removePendingAt(index),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Add photo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                ),
                TextButton.icon(
                  onPressed: _pickFromFiles,
                  icon: const Icon(Icons.insert_drive_file_outlined),
                  label: const Text('Files'),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // In-app gallery grid (mobile) - first page preview
            if (galleryGrid != null) ...[
              galleryGrid,
              const SizedBox(height: 12),
            ],
            preview,
            if (_showPickerError)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Please select at least one photo',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<VehiclePhotoCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: VehiclePhotoCategory.values
                  .map(
                    (item) =>
                        DropdownMenuItem(value: item, child: Text(item.label)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _category = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                FilledButton(onPressed: _submit, child: const Text('Save')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingPhoto {
  const _PendingPhoto({required this.dataUrl, this.assetId});

  final String dataUrl;
  final String? assetId;
}

class _PhotoToolbar extends StatelessWidget {
  const _PhotoToolbar({
    required this.selected,
    required this.counts,
    required this.totalCount,
    required this.onCategorySelected,
    required this.onAddPhoto,
  });

  final VehiclePhotoCategory? selected;
  final Map<VehiclePhotoCategory, int> counts;
  final int totalCount;
  final ValueChanged<VehiclePhotoCategory?> onCategorySelected;
  final VoidCallback onAddPhoto;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      FilterChip(
        selected: selected == null,
        onSelected: (_) => onCategorySelected(null),
        label: Text('All ($totalCount)'),
      ),
      ...counts.entries.map(
        (entry) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: FilterChip(
            selected: selected == entry.key,
            onSelected: (_) => onCategorySelected(entry.key),
            label: Text('${entry.key.label} (${entry.value})'),
          ),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Photo album',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: onAddPhoto,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Add photo'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: chips),
        ),
      ],
    );
  }
}

class _VehiclePhotoSection extends StatelessWidget {
  const _VehiclePhotoSection({
    required this.vehicle,
    required this.photos,
    required this.onPhotoTap,
    required this.onDeletePhoto,
    required this.onAddPhoto,
    required this.onSetCover,
  });

  final Vehicle vehicle;
  final List<VehiclePhoto> photos;
  final ValueChanged<VehiclePhoto> onPhotoTap;
  final ValueChanged<VehiclePhoto> onDeletePhoto;
  final VoidCallback onAddPhoto;
  final ValueChanged<VehiclePhoto> onSetCover;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: _EmptyGalleryCard(
            displayName: vehicle.displayName,
            onAddPhoto: onAddPhoto,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final photo = photos[index];
          return _VehiclePhotoTile(
            photo: photo,
            onTap: () => onPhotoTap(photo),
            onDelete: () => onDeletePhoto(photo),
            onSetCover: () => onSetCover(photo),
          );
        }, childCount: photos.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
      ),
    );
  }
}

class _VehiclePhotoTile extends StatelessWidget {
  const _VehiclePhotoTile({
    required this.photo,
    required this.onTap,
    required this.onDelete,
    required this.onSetCover,
  });

  final VehiclePhoto photo;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onSetCover;

  @override
  Widget build(BuildContext context) {
    final addedOn = MaterialLocalizations.of(
      context,
    ).formatShortDate(photo.addedAt);

    return DriveMediaTile(
      onTap: onTap,
      topLabel: photo.category.label,
      topTrailing: PopupMenuButton<_PhotoMenuAction>(
        icon: const Icon(Icons.more_vert, color: Colors.white70),
        color: const Color(0xFF1F2428),
        onSelected: (value) {
          switch (value) {
            case _PhotoMenuAction.setCover:
              onSetCover();
              break;
            case _PhotoMenuAction.delete:
              onDelete();
              break;
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: _PhotoMenuAction.setCover,
            child: Text('Set as main photo'),
          ),
          PopupMenuItem(value: _PhotoMenuAction.delete, child: Text('Delete')),
        ],
      ),
      bottomLabel: addedOn,
      child: Hero(
        tag: 'vehicle-photo-${photo.id}',
        child: Image.network(
          photo.url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const _PhotoPlaceholder(),
        ),
      ),
    );
  }
}

class _EmptyGalleryCard extends StatelessWidget {
  const _EmptyGalleryCard({
    required this.displayName,
    required this.onAddPhoto,
  });

  final String displayName;
  final VoidCallback onAddPhoto;

  @override
  Widget build(BuildContext context) {
    return DriveCard(
      color: const Color(0xFF161B1F),
      borderRadius: 20,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No photos yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first photo of $displayName to build a history of the vehicle.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onAddPhoto,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.tealAccent,
              side: const BorderSide(color: Colors.tealAccent),
            ),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Add photo'),
          ),
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E2327),
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        color: Colors.white38,
        size: 48,
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage(this.vehicle);

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E2327),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_car, color: Colors.white54, size: 48),
          const SizedBox(height: 12),
          Text(
            vehicle.displayName,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}


enum _PhotoMenuAction { setCover, delete }
