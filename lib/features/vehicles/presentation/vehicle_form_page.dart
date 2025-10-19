import 'dart:convert';
import 'dart:typed_data';
import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_brand.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_document.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_photo.dart';
import 'package:driveit_app/features/vehicles/presentation/widgets/brand_selector_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:driveit_app/shared/data/fuel_types.dart';
import 'package:driveit_app/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class VehicleFormPage extends StatefulWidget {
  const VehicleFormPage({super.key, this.initialVehicle});

  final Vehicle? initialVehicle;

  @override
  State<VehicleFormPage> createState() => _VehicleFormPageState();
}

class _VehicleFormPageState extends State<VehicleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  final ScrollController _scrollController = ScrollController();

  bool get _isEditing => widget.initialVehicle != null;

  late final TextEditingController _nameController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _odometerController;
  late final TextEditingController _licenseController;
  late final TextEditingController _vinController;
  late final TextEditingController _fuelCapacityPrimaryController;
  late final TextEditingController _fuelCapacitySecondaryController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _purchaseOdometerController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _saleOdometerController;
  late final TextEditingController _notesController;

  VehicleBrand? _selectedBrand;
  String? _brandError;
  String? _primaryFuelType = FuelTypes.defaults.first;
  bool _hasSecondaryTank = false;
  String? _secondaryFuelType = 'LPG';
  String _volumeUnit = _volumeUnits.first;
  DateTime? _purchaseDate;
  DateTime? _saleDate;
  bool _includeSale = false;
  bool _isSaving = false;

  String? _coverPhotoDataUrl;
  Uint8List? _coverPhotoBytes;
  String? _existingCoverUrl;

  late final List<VehicleDocument> _initialDocuments;
  final List<_PendingDocument> _pendingDocuments = [];
  late final List<VehiclePhoto> _initialPhotos;
  final List<_PendingPhoto> _pendingPhotos = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupInitialData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _modelController = TextEditingController();
    _yearController = TextEditingController();
    _odometerController = TextEditingController();
    _licenseController = TextEditingController();
    _vinController = TextEditingController();
    _fuelCapacityPrimaryController = TextEditingController();
    _fuelCapacitySecondaryController = TextEditingController();
    _purchasePriceController = TextEditingController();
    _purchaseOdometerController = TextEditingController();
    _salePriceController = TextEditingController();
    _saleOdometerController = TextEditingController();
    _notesController = TextEditingController();
  }

  void _setupInitialData() {
    if (_isEditing) {
      for (final controller in [
        _nameController,
        _modelController,
        _yearController,
        _licenseController,
        _odometerController,
      ]) {
        controller.addListener(_handleSummaryChanged);
      }
    }

    final initial = widget.initialVehicle;
    if (initial != null) {
      _hydrateFromInitial(initial);
    } else {
      _initialDocuments = const [];
      _initialPhotos = const [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _odometerController.dispose();
    _licenseController.dispose();
    _vinController.dispose();
    _fuelCapacityPrimaryController.dispose();
    _fuelCapacitySecondaryController.dispose();
    _purchasePriceController.dispose();
    _purchaseOdometerController.dispose();
    _salePriceController.dispose();
    _saleOdometerController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _hydrateFromInitial(Vehicle vehicle) {
    _nameController.text = vehicle.displayName;
    _modelController.text = vehicle.model;
    _yearController.text = vehicle.year.toString();
    _odometerController.text = vehicle.odometerKm == null
        ? ''
        : vehicle.odometerKm.toString();
    _licenseController.text = vehicle.licensePlate ?? '';
    _vinController.text = vehicle.vin ?? '';
    _primaryFuelType = vehicle.fuelType ?? FuelTypes.defaults.first;
    _hasSecondaryTank = vehicle.secondaryFuelType != null;
    _secondaryFuelType = vehicle.secondaryFuelType ?? _secondaryFuelType;
    _fuelCapacityPrimaryController.text =
        vehicle.fuelCapacityPrimary?.toString() ?? '';
    _fuelCapacitySecondaryController.text =
        vehicle.fuelCapacitySecondary?.toString() ?? '';
    _volumeUnit = _volumeUnitFromVehicle(vehicle.fuelCapacityUnit);
    _purchaseDate = vehicle.purchaseDate;
    _purchasePriceController.text = vehicle.purchasePrice?.toString() ?? '';
    _purchaseOdometerController.text =
        vehicle.purchaseOdometerKm?.toString() ?? '';
    _includeSale =
        vehicle.saleDate != null ||
        vehicle.salePrice != null ||
        vehicle.saleOdometerKm != null;
    _saleDate = vehicle.saleDate;
    _salePriceController.text = vehicle.salePrice?.toString() ?? '';
    _saleOdometerController.text = vehicle.saleOdometerKm?.toString() ?? '';
    _notesController.text = vehicle.notes ?? '';
    _existingCoverUrl = vehicle.photoUrl;
    _initialDocuments = List<VehicleDocument>.from(vehicle.documents);
    _initialPhotos = List<VehiclePhoto>.from(vehicle.photos);
    _selectedBrand = VehicleBrand(
      name: vehicle.make,
      slug: vehicle.brandSlug ?? _slugify(vehicle.make),
      logoUrl: vehicle.brandLogoUrl,
      thumbLogoUrl: vehicle.brandLogoThumbUrl ?? vehicle.brandLogoUrl,
      isCustom: vehicle.brandSlug == null,
    );
  }

  void _handleSummaryChanged() {
    if (!_isEditing) return;
    setState(() {});
  }

  Vehicle _buildSummaryVehicle(Vehicle base) {
    final name = _nameController.text.trim();
    final model = _modelController.text.trim();
    final license = _licenseController.text.trim();
    final odometerText = _odometerController.text.trim();
    final yearText = _yearController.text.trim();

    final odometer = int.tryParse(odometerText);
    final year = int.tryParse(yearText);

    return base.copyWith(
      displayName: name.isEmpty ? null : name,
      make: _selectedBrand?.name ?? base.make,
      model: model.isEmpty ? null : model,
      year: year ?? base.year,
      licensePlate: license.isEmpty ? null : license,
      odometerKm: odometer ?? base.odometerKm,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleText = _isEditing ? 'Edit vehicle' : 'Add vehicle';
    final actionText = _isEditing ? 'Save changes' : 'Create vehicle';
    final summaryVehicle = _isEditing && widget.initialVehicle != null
        ? _buildSummaryVehicle(widget.initialVehicle!)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1418),
      appBar: AppBar(
        title: Text(titleText),
        backgroundColor: const Color(0xFF0F1418),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Scrollbar(
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCoverSection(theme),
                  if (summaryVehicle != null) ...[
                    const SizedBox(height: 32),
                    const DriveSectionHeader(
                      title: 'Vehicle overview',
                      subtitle: 'Current details for quick reference.',
                    ),
                    const SizedBox(height: 12),
                    DriveVehicleSummary(
                      vehicle: summaryVehicle,
                      showHeader: false,
                    ),
                  ],
                  const SizedBox(height: 32),
                  _buildGeneralSection(theme),
                  const SizedBox(height: 32),
                  _buildFuelSection(theme),
                  const SizedBox(height: 32),
                  _buildOwnershipSection(theme),
                  const SizedBox(height: 32),
                  _buildNotesSection(theme),
                  const SizedBox(height: 32),
                  _buildDocumentsSection(theme),
                  const SizedBox(height: 32),
                  _buildPhotosSection(theme),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(actionText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverSection(ThemeData theme) {
    final hasCover = _coverPhotoBytes != null || _existingCoverUrl != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DriveSectionHeader(
          title: 'Cover photo',
          subtitle: 'Pick a hero image for your vehicle overview.',
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showCoverPhotoSheet,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF1A2024),
                border: Border.all(color: Colors.white12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_coverPhotoBytes != null)
                    Image.memory(_coverPhotoBytes!, fit: BoxFit.cover)
                  else if (_existingCoverUrl != null)
                    Image.network(
                      _existingCoverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 42,
                          color: theme.hintColor,
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 42,
                            color: theme.hintColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to add cover photo',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo_library_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              hasCover ? 'Change' : 'Add',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasCover)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _isSaving
                  ? null
                  : () {
                      setState(() {
                        _coverPhotoBytes = null;
                        _coverPhotoDataUrl = null;
                        _existingCoverUrl = null;
                      });
                    },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove photo'),
            ),
          ),
      ],
    );
  }

  Widget _buildGeneralSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DriveSectionHeader(
          title: 'Vehicle details',
          subtitle: 'Basics we use to reference the vehicle across the app.',
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Vehicle name',
            hintText: 'e.g. Family SUV',
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if ((value ?? '').trim().isEmpty) {
              return 'Name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        BrandSelectorField(
          value: _selectedBrand,
          onChanged: (brand) {
            setState(() {
              _selectedBrand = brand;
              _brandError = null;
            });
          },
          errorText: _brandError,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _modelController,
          decoration: const InputDecoration(labelText: 'Model'),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if ((value ?? '').trim().isEmpty) {
              return 'Model is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final trimmed = (value ?? '').trim();
                  if (trimmed.isEmpty) {
                    return 'Enter a year';
                  }
                  final parsed = int.tryParse(trimmed);
                  final currentYear = DateTime.now().year + 1;
                  if (parsed == null || parsed < 1886 || parsed > currentYear) {
                    return 'Year must be between 1886 and $currentYear';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _odometerController,
                decoration: const InputDecoration(
                  labelText: 'Current odometer (km)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final trimmed = (value ?? '').trim();
                  if (trimmed.isEmpty) {
                    return null;
                  }
                  final parsed = int.tryParse(trimmed);
                  if (parsed == null || parsed < 0) {
                    return 'Enter a positive number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _licenseController,
                decoration: const InputDecoration(
                  labelText: 'License plate',
                  helperText: 'Optional',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _vinController,
                decoration: const InputDecoration(
                  labelText: 'VIN',
                  helperText: 'Optional',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFuelSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DriveSectionHeader(
          title: 'Fuel & capacity',
          subtitle: 'Track how you refuel and calculate refueling costs later.',
        ),
        const SizedBox(height: 16),
        DropdownMenu<String>(
          initialSelection: _primaryFuelType,
          label: const Text('Primary fuel type'),
          dropdownMenuEntries: FuelTypes.menuEntries(),
          onSelected: (value) {
            setState(() {
              _primaryFuelType = value;
              if (value == null) {
                _hasSecondaryTank = false;
                _secondaryFuelType = null;
                _fuelCapacitySecondaryController.clear();
              }
            });
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _fuelCapacityPrimaryController,
                decoration: InputDecoration(
                  labelText: 'Tank capacity',
                  suffixText: _volumeUnit.toUpperCase(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final trimmed = (value ?? '').trim();
                  if (trimmed.isEmpty) return null;
                  final parsed = double.tryParse(trimmed.replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a positive number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownMenu<String>(
                initialSelection: _volumeUnit,
                label: const Text('Unit'),
                dropdownMenuEntries: _volumeUnits
                    .map(
                      (unit) => DropdownMenuEntry<String>(
                        value: unit,
                        label: unit.toUpperCase(),
                      ),
                    )
                    .toList(),
                onSelected: (value) {
                  if (value == null) return;
                  setState(() => _volumeUnit = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SwitchListTile.adaptive(
          value: _hasSecondaryTank,
          onChanged: (_primaryFuelType == null || _isSaving)
              ? null
              : (value) {
                  setState(() {
                    _hasSecondaryTank = value;
                    if (!value) {
                      _fuelCapacitySecondaryController.clear();
                    } else {
                      _secondaryFuelType ??= 'LPG';
                    }
                  });
                },
          title: const Text('Add secondary fuel tank'),
          subtitle: const Text('Useful for Petrol + LPG combinations'),
        ),
        if (_hasSecondaryTank) ...[
          const SizedBox(height: 12),
          DropdownMenu<String>(
            initialSelection: _secondaryFuelType,
            label: const Text('Secondary fuel type'),
            dropdownMenuEntries: FuelTypes.menuEntries(),
            onSelected: (value) => setState(() => _secondaryFuelType = value),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _fuelCapacitySecondaryController,
            decoration: InputDecoration(
              labelText: 'Secondary tank capacity',
              suffixText: _volumeUnit.toUpperCase(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (!_hasSecondaryTank) return null;
              final trimmed = (value ?? '').trim();
              if (trimmed.isEmpty) {
                return 'Enter a capacity';
              }
              final parsed = double.tryParse(trimmed.replaceAll(',', '.'));
              if (parsed == null || parsed <= 0) {
                return 'Enter a positive number';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildOwnershipSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DriveSectionHeader(
          title: 'Ownership',
          subtitle: 'Keep purchase and sale history in one place.',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _DateField(
                label: 'Purchase date',
                value: _purchaseDate,
                onTap: _selectPurchaseDate,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _purchasePriceController,
                decoration: const InputDecoration(
                  labelText: 'Purchase price',
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final trimmed = (value ?? '').trim();
                  if (trimmed.isEmpty) return null;
                  final parsed = double.tryParse(trimmed.replaceAll(',', '.'));
                  if (parsed == null || parsed < 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _purchaseOdometerController,
          decoration: const InputDecoration(
            labelText: 'Odometer at purchase (km)',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            final trimmed = (value ?? '').trim();
            if (trimmed.isEmpty) return null;
            final parsed = int.tryParse(trimmed);
            if (parsed == null || parsed < 0) {
              return 'Enter a positive number';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        SwitchListTile.adaptive(
          value: _includeSale,
          onChanged: _isSaving
              ? null
              : (value) {
                  setState(() {
                    _includeSale = value;
                    if (!value) {
                      _saleDate = null;
                      _salePriceController.clear();
                      _saleOdometerController.clear();
                    }
                  });
                },
          title: const Text('Vehicle has been sold'),
        ),
        if (_includeSale) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'Sale date',
                  value: _saleDate,
                  onTap: _selectSaleDate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _salePriceController,
                  decoration: const InputDecoration(
                    labelText: 'Sale price',
                    prefixText: '\$ ',
                  ),
                  enabled: _includeSale,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (!_includeSale) return null;
                    final trimmed = (value ?? '').trim();
                    if (trimmed.isEmpty) {
                      return 'Enter sale price';
                    }
                    final parsed = double.tryParse(
                      trimmed.replaceAll(',', '.'),
                    );
                    if (parsed == null || parsed < 0) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _saleOdometerController,
            decoration: const InputDecoration(
              labelText: 'Odometer at sale (km)',
            ),
            enabled: _includeSale,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (!_includeSale) return null;
              final trimmed = (value ?? '').trim();
              if (trimmed.isEmpty) {
                return 'Enter sale odometer';
              }
              final parsed = int.tryParse(trimmed);
              if (parsed == null || parsed < 0) {
                return 'Enter a positive number';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildNotesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DriveSectionHeader(
          title: 'Notes',
          subtitle: 'Anything special about the vehicle worth remembering.',
        ),
        const SizedBox(height: 16),
        DriveNotesField(
          controller: _notesController,
          label: 'Notes',
          minLines: 4,
          maxLines: 8,
        ),
      ],
    );
  }

  Widget _buildDocumentsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DriveSectionHeader(
          title: 'Documents',
          subtitle: 'Attach insurance, registration and other paperwork.',
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isSaving ? null : _addDocument,
          icon: const Icon(Icons.attach_file_outlined),
          label: const Text('Add document'),
        ),
        const SizedBox(height: 16),
        if (_initialDocuments.isEmpty && _pendingDocuments.isEmpty)
          Text(
            'No documents attached yet.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          )
        else
          Column(
            children: [
              ..._initialDocuments.map(_buildExistingDocumentTile),
              ..._pendingDocuments.map(_buildPendingDocumentTile),
            ],
          ),
      ],
    );
  }

  Widget _buildExistingDocumentTile(VehicleDocument document) {
    return Card(
      color: const Color(0xFF1A2024),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.description_outlined),
        title: Text(document.title),
        subtitle: Text('${document.category.label} - Existing attachment'),
      ),
    );
  }

  Widget _buildPendingDocumentTile(_PendingDocument item) {
    return Card(
      color: const Color(0xFF1A2024),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.description_outlined),
        title: Text(item.document.title),
        subtitle: Text(
          '${item.document.category.label} - ${_formatFileSize(item.fileSize)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: _isSaving ? null : () => _removeDocument(item.document.id),
        ),
      ),
    );
  }

  Widget _buildPhotosSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DriveSectionHeader(
          title: 'Album photos',
          subtitle: 'Populate the gallery with shots you already have.',
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isSaving ? null : _addPhotos,
          icon: const Icon(Icons.add_a_photo_outlined),
          label: const Text('Add photos'),
        ),
        const SizedBox(height: 16),
        if (_initialPhotos.isEmpty && _pendingPhotos.isEmpty)
          Text(
            'No album photos yet.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ..._initialPhotos.map(_buildExistingPhotoTile),
              ..._pendingPhotos.map(_buildPendingPhotoTile),
            ],
          ),
      ],
    );
  }

  Widget _buildExistingPhotoTile(VehiclePhoto photo) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        photo.url,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 96,
          height: 96,
          color: Colors.black12,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined, color: Colors.white54),
        ),
      ),
    );
  }

  Widget _buildPendingPhotoTile(_PendingPhoto item) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(
            item.bytes,
            width: 96,
            height: 96,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _isSaving ? null : () => _removePhoto(item.photo.id),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showCoverPhotoSheet() async {
    final action = await showModalBottomSheet<_CoverAction>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () =>
                    Navigator.of(context).pop(_CoverAction.pickGallery),
              ),
              if (_coverPhotoBytes != null || _existingCoverUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Remove photo'),
                  onTap: () => Navigator.of(context).pop(_CoverAction.remove),
                ),
            ],
          ),
        );
      },
    );
    switch (action) {
      case _CoverAction.pickGallery:
        await _pickCoverPhoto();
        break;
      case _CoverAction.remove:
        setState(() {
          _coverPhotoBytes = null;
          _coverPhotoDataUrl = null;
          _existingCoverUrl = null;
        });
        break;
      case null:
        break;
    }
  }

  Future<void> _pickCoverPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2400,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final mime = _inferImageMime(file.name);
    setState(() {
      _coverPhotoBytes = bytes;
      _coverPhotoDataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
      _existingCoverUrl = null;
    });
  }

  Future<void> _addDocument() async {
    final pending = await showModalBottomSheet<_PendingDocument>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141A1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _DocumentSheet(uuid: _uuid),
    );
    if (pending == null) return;
    setState(() => _pendingDocuments.add(pending));
  }

  Future<void> _addPhotos() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 85, maxWidth: 2400);
    if (files.isEmpty) return;
    final now = DateTime.now();
    final additions = <_PendingPhoto>[];
    for (final file in files) {
      final bytes = await file.readAsBytes();
      final mime = _inferImageMime(file.name);
      additions.add(
        _PendingPhoto(
          photo: VehiclePhoto(
            id: _uuid.v4(),
            url: 'data:$mime;base64,${base64Encode(bytes)}',
            category: VehiclePhotoCategory.exterior,
            addedAt: now,
          ),
          bytes: bytes,
        ),
      );
    }
    if (additions.isEmpty) return;
    setState(() => _pendingPhotos.addAll(additions));
  }

  void _removeDocument(String id) {
    setState(() {
      _pendingDocuments.removeWhere((item) => item.document.id == id);
    });
  }

  void _removePhoto(String id) {
    setState(() {
      _pendingPhotos.removeWhere((item) => item.photo.id == id);
    });
  }

  Future<void> _selectPurchaseDate() async {
    final now = DateTime.now();
    final initial = _purchaseDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked == null) return;
    setState(() => _purchaseDate = picked);
  }

  Future<void> _selectSaleDate() async {
    final now = DateTime.now();
    final initial = _saleDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (picked == null) return;
    setState(() => _saleDate = picked);
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;
    if (_selectedBrand == null) {
      setState(() => _brandError = 'Select a brand');
      return;
    }
    if (_includeSale && _saleDate != null && _purchaseDate != null) {
      if (_saleDate!.isBefore(_purchaseDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.fixed,
            content: Text('Sale date cannot be before purchase date'),
          ),
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
      _brandError = null;
    });

    final displayName = _nameController.text.trim();
    final model = _modelController.text.trim();
    final year = int.parse(_yearController.text.trim());
    final odometer = int.tryParse(_odometerController.text.trim());
    final license = _nullableText(_licenseController);
    final vin = _nullableText(_vinController);
    final primaryCapacity = double.tryParse(
      _fuelCapacityPrimaryController.text.trim().replaceAll(',', '.'),
    );
    final secondaryCapacity = _hasSecondaryTank
        ? double.tryParse(
            _fuelCapacitySecondaryController.text.trim().replaceAll(',', '.'),
          )
        : null;
    final purchasePrice = double.tryParse(
      _purchasePriceController.text.trim().replaceAll(',', '.'),
    );
    final purchaseOdometer = int.tryParse(
      _purchaseOdometerController.text.trim(),
    );
    final salePrice = _includeSale
        ? double.tryParse(_salePriceController.text.trim().replaceAll(',', '.'))
        : null;
    final saleOdometer = _includeSale
        ? int.tryParse(_saleOdometerController.text.trim())
        : null;
    final notes = _nullableText(_notesController);

    final brand = _selectedBrand!;
    final brandLogo = brand.logoUrl ?? brand.thumbLogoUrl;
    final brandThumb = brand.thumbLogoUrl ?? brand.logoUrl;
    final documents = [
      ..._initialDocuments,
      ..._pendingDocuments.map((item) => item.document),
    ];
    final newPhotos = _pendingPhotos.map((item) => item.photo).toList();
    final photos = [..._initialPhotos, ...newPhotos];
    final resolvedCover =
        _coverPhotoDataUrl ??
        _existingCoverUrl ??
        (photos.isNotEmpty ? photos.first.url : null);

    Vehicle result;
    if (_isEditing) {
      final base = widget.initialVehicle!;
      result = base.copyWith(
        displayName: displayName,
        make: brand.name,
        model: model,
        year: year,
        licensePlate: license,
        vin: vin,
        photoUrl: resolvedCover ?? base.photoUrl,
        brandSlug: brand.slug,
        brandLogoUrl: brandLogo,
        brandLogoThumbUrl: brandThumb,
        fuelType: _primaryFuelType,
        secondaryFuelType: _hasSecondaryTank ? _secondaryFuelType : null,
        fuelCapacityPrimary: primaryCapacity,
        fuelCapacitySecondary: secondaryCapacity,
        fuelCapacityUnit: _mapVolumeUnit(_volumeUnit),
        odometerKm: odometer,
        purchaseDate: _purchaseDate,
        purchasePrice: purchasePrice,
        purchaseOdometerKm: purchaseOdometer,
        saleDate: _includeSale ? _saleDate : null,
        salePrice: salePrice,
        saleOdometerKm: saleOdometer,
        notes: notes,
        documents: documents,
        photos: photos,
      );
    } else {
      result = Vehicle(
        id: _uuid.v4(),
        displayName: displayName,
        make: brand.name,
        brandSlug: brand.slug,
        brandLogoUrl: brandLogo,
        brandLogoThumbUrl: brandThumb,
        model: model,
        year: year,
        licensePlate: license,
        vin: vin,
        photoUrl: resolvedCover,
        fuelType: _primaryFuelType,
        secondaryFuelType: _hasSecondaryTank ? _secondaryFuelType : null,
        fuelCapacityPrimary: primaryCapacity,
        fuelCapacitySecondary: secondaryCapacity,
        fuelCapacityUnit: _mapVolumeUnit(_volumeUnit),
        odometerKm: odometer,
        purchaseDate: _purchaseDate,
        purchasePrice: purchasePrice,
        purchaseOdometerKm: purchaseOdometer,
        saleDate: _includeSale ? _saleDate : null,
        salePrice: salePrice,
        saleOdometerKm: saleOdometer,
        notes: notes,
        documents: documents,
        photos: photos,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  String? _nullableText(TextEditingController controller) {
    final trimmed = controller.text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _mapVolumeUnit(String unit) {
    switch (unit) {
      case 'gal':
        return 'gallons';
      default:
        return 'liters';
    }
  }

  String _volumeUnitFromVehicle(String? unit) {
    switch (unit) {
      case 'gallons':
        return 'gal';
      case 'liters':
        return 'l';
      default:
        return 'l';
    }
  }

  String _slugify(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'(^-)|(-\$)'), '');
  }

  String _formatFileSize(int bytes) {
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

  String _inferImageMime(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(
          value == null ? 'Select date' : _formatDate(value!),
          style: value == null
              ? theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)
              : theme.textTheme.bodyMedium,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[date.month - 1];
    return '${date.day} $month ${date.year}';
  }
}

class _DocumentSheet extends StatefulWidget {
  const _DocumentSheet({required this.uuid});

  final Uuid uuid;

  @override
  State<_DocumentSheet> createState() => _DocumentSheetState();
}

class _DocumentSheetState extends State<_DocumentSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  VehicleDocumentCategory _category = VehicleDocumentCategory.other;
  String? _dataUrl;
  String? _fileName;
  int? _fileSize;
  bool _showPickerError = false;
  bool _isPicking = false;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: viewInsets + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Attach document',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              errorText: _titleError,
            ),
          ),
          const SizedBox(height: 12),
          DropdownMenu<VehicleDocumentCategory>(
            initialSelection: _category,
            label: const Text('Category'),
            dropdownMenuEntries: VehicleDocumentCategory.values
                .map(
                  (item) => DropdownMenuEntry(value: item, label: item.label),
                )
                .toList(),
            onSelected: (value) {
              if (value == null) return;
              setState(() => _category = value);
            },
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _isPicking ? null : _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2024),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _showPickerError
                      ? Theme.of(context).colorScheme.error
                      : Colors.white24,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.tealAccent.withAlpha(36),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.upload_file_outlined,
                      color: Colors.tealAccent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fileName ?? 'Select file',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          _fileSize == null
                              ? 'PDF, JPG, PNG up to 15 MB'
                              : _formatFileSize(_fileSize!),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          DriveNotesField(
            controller: _notesController,
            label: 'Notes (optional)',
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isPicking ? null : _submit,
              child: const Text('Attach document'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    setState(() {
      _isPicking = true;
      _showPickerError = false;
    });
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
      if (file.bytes == null) return;
      final extension = file.extension ?? '';
      final mime = _mimeTypeForExtension(extension);
      setState(() {
        _dataUrl = 'data:$mime;base64,${base64Encode(file.bytes!)}';
        _fileName = file.name;
        _fileSize = file.bytes!.length;
        _showPickerError = false;
      });
    } finally {
      setState(() => _isPicking = false);
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Provide a title');
      return;
    }
    if (_dataUrl == null) {
      setState(() => _showPickerError = true);
      return;
    }
    final document = VehicleDocument(
      id: widget.uuid.v4(),
      title: title,
      category: _category,
      url: _dataUrl!,
      uploadedAt: DateTime.now(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    Navigator.of(context).pop(
      _PendingDocument(
        document: document,
        fileName: _fileName ?? document.title,
        fileSize: _fileSize ?? 0,
      ),
    );
  }

  String _formatFileSize(int bytes) {
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

  String _mimeTypeForExtension(String extension) {
    switch (extension.toLowerCase()) {
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
}

class _PendingDocument {
  const _PendingDocument({
    required this.document,
    required this.fileName,
    required this.fileSize,
  });

  final VehicleDocument document;
  final String fileName;
  final int fileSize;
}

class _PendingPhoto {
  const _PendingPhoto({required this.photo, required this.bytes});

  final VehiclePhoto photo;
  final Uint8List bytes;
}

enum _CoverAction { pickGallery, remove }

const List<String> _volumeUnits = ['l', 'gal'];
