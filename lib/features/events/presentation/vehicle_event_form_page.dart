import 'dart:convert';

import 'package:driveit_app/features/events/domain/vehicle_event.dart';
import 'package:driveit_app/features/events/presentation/attachment_viewer.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/shared/data/fuel_types.dart';
import 'package:driveit_app/shared/widgets/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

enum _CostField { amount, volume, price }

class VehicleEventFormPage extends StatefulWidget {
  const VehicleEventFormPage({
    super.key,
    required this.vehicle,
    required this.type,
    required this.actionLabel,
    this.initialEvent,
  });

  final Vehicle vehicle;
  final VehicleEventType type;
  final String actionLabel;
  final VehicleEvent? initialEvent;

  @override
  State<VehicleEventFormPage> createState() => _VehicleEventFormPageState();
}

class _VehicleEventFormPageState extends State<VehicleEventFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _odometerController = TextEditingController();
  final _amountController = TextEditingController();
  final _volumeController = TextEditingController();
  final _pricePerLiterController = TextEditingController();
  final _notesController = TextEditingController();

  final _uuid = const Uuid();
  final _attachments = <VehicleEventAttachment>[];

  DateTime _selectedDate = DateTime.now();
  String? _serviceType;
  String _currency = 'PLN';
  bool _isFullTank = true;
  bool _isUpdatingCostFields = false;
  bool _isSubmitting = false;
  bool get _isEditing => widget.initialEvent != null;

  static const int _volumeFractionDigits = 3;
  static const int _priceFractionDigits = 3;
  static const int _amountFractionDigits = 2;

  late final List<String> _availableFuelTypes;
  String? _selectedFuelType;
  bool _titleManuallyEdited = false;
  bool _isUpdatingTitle = false;

  List<String> get _serviceTypes => const [
    'Maintenance',
    'Inspection',
    'Oil change',
    'Tires',
    'Repair',
  ];
  @override
  void initState() {
    super.initState();
    final initial = widget.initialEvent;
    _selectedDate = initial?.occurredAt ?? DateTime.now();
    _availableFuelTypes = FuelTypes.optionsForVehicle(
      widget.vehicle,
      initial: initial?.fuelType,
    );
    _selectedFuelType = initial?.fuelType ?? _availableFuelTypes.firstOrNull;
    if (initial != null) {
      _isUpdatingTitle = true;
      _titleController.text = initial.title;
      _isUpdatingTitle = false;
      _locationController.text = initial.location ?? '';
      _odometerController.text = initial.odometerKm == null
          ? ''
          : initial.odometerKm.toString();
      _amountController.text = initial.amount == null
          ? ''
          : _formatAmountValue(
              initial.amount!,
              fractionDigits: _amountFractionDigits,
            );
      _volumeController.text = initial.volumeLiters == null
          ? ''
          : _formatAmountValue(
              initial.volumeLiters!,
              fractionDigits: _volumeFractionDigits,
            );
      _pricePerLiterController.text = initial.pricePerLiter == null
          ? ''
          : _formatAmountValue(
              initial.pricePerLiter!,
              fractionDigits: _priceFractionDigits,
            );
      _isFullTank = initial.isFullTank ?? _isFullTank;
      _notesController.text = initial.notes ?? '';
      _serviceType = initial.serviceType;
      _currency = initial.currency ?? _currency;
      _attachments.addAll(initial.attachments);

      if (widget.type == VehicleEventType.refuel) {
        final fuel = _selectedFuelType?.trim();
        final autoTitle = (fuel != null && fuel.isNotEmpty)
            ? fuel
            : (widget.vehicle.fuelType ?? _defaultTitleForType(widget.type));
        _titleManuallyEdited =
            initial.title.trim().toLowerCase() != autoTitle.toLowerCase();
      }
    } else {
      if (widget.type == VehicleEventType.refuel) {
        _setTitleFromFuel(force: true);
      } else {
        _titleController.text = _defaultTitleForType(widget.type);
      }
      final odometer = widget.vehicle.odometerKm;
      if (odometer != null) {
        _odometerController.text = odometer.toString();
      }
    }
    _titleController.addListener(_handleTitleChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_handleTitleChanged);
    _titleController.dispose();
    _locationController.dispose();
    _odometerController.dispose();
    _amountController.dispose();
    _volumeController.dispose();
    _pricePerLiterController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _showServiceType => widget.type == VehicleEventType.service;

  bool get _showAmount =>
      widget.type == VehicleEventType.expense ||
      widget.type == VehicleEventType.income ||
      widget.type == VehicleEventType.refuel ||
      widget.type == VehicleEventType.service;

  bool get _requireAmount =>
      widget.type == VehicleEventType.expense ||
      widget.type == VehicleEventType.income ||
      widget.type == VehicleEventType.refuel;

  bool get _requireOdometer =>
      widget.type == VehicleEventType.odometer ||
      widget.type == VehicleEventType.service ||
      widget.type == VehicleEventType.refuel;

  String get _amountLabel => switch (widget.type) {
    VehicleEventType.income => 'Amount received',
    VehicleEventType.refuel => 'Fuel cost',
    VehicleEventType.service => 'Service cost',
    _ => 'Amount',
  };

  String _defaultTitleForType(VehicleEventType type) {
    return switch (type) {
      VehicleEventType.odometer => 'Odometer update',
      VehicleEventType.note => 'Add note',
      VehicleEventType.income => 'Income entry',
      VehicleEventType.service => 'Service visit',
      VehicleEventType.expense => 'Expense entry',
      VehicleEventType.refuel => 'Refuel stop',
    };
  }

  void _handleCostFieldChanged(_CostField source) {
    if (_isUpdatingCostFields) return;
    _isUpdatingCostFields = true;
    try {
      final amount = _parseDecimal(_amountController.text);
      final volume = _parseDecimal(_volumeController.text);
      final price = _parseDecimal(_pricePerLiterController.text);

      switch (source) {
        case _CostField.amount:
          if (amount != null && volume != null && volume > 0) {
            final computedPrice = amount / volume;
            if (computedPrice.isFinite) {
              _setControllerValue(
                _pricePerLiterController,
                computedPrice,
                fractionDigits: _priceFractionDigits,
              );
            }
          } else if (amount != null && price != null && price > 0) {
            final computedVolume = amount / price;
            if (computedVolume.isFinite) {
              _setControllerValue(
                _volumeController,
                computedVolume,
                fractionDigits: _volumeFractionDigits,
              );
            }
          }
          break;
        case _CostField.volume:
          if (volume != null && price != null && price > 0) {
            final computedAmount = price * volume;
            if (computedAmount.isFinite) {
              _setControllerValue(
                _amountController,
                computedAmount,
                fractionDigits: _amountFractionDigits,
              );
            }
          } else if (volume != null && volume > 0 && amount != null) {
            final computedPrice = amount / volume;
            if (computedPrice.isFinite) {
              _setControllerValue(
                _pricePerLiterController,
                computedPrice,
                fractionDigits: _priceFractionDigits,
              );
            }
          }
          break;
        case _CostField.price:
          if (price != null && volume != null && volume > 0) {
            final computedAmount = price * volume;
            if (computedAmount.isFinite) {
              _setControllerValue(
                _amountController,
                computedAmount,
                fractionDigits: _amountFractionDigits,
              );
            }
          } else if (price != null && price > 0 && amount != null) {
            final computedVolume = amount / price;
            if (computedVolume.isFinite) {
              _setControllerValue(
                _volumeController,
                computedVolume,
                fractionDigits: _volumeFractionDigits,
              );
            }
          }
          break;
      }
    } finally {
      _isUpdatingCostFields = false;
    }
  }

  void _setTitleFromFuel({bool force = false}) {
    if (widget.type != VehicleEventType.refuel) return;
    final fuel = _selectedFuelType?.trim();
    final autoTitle = (fuel != null && fuel.isNotEmpty)
        ? fuel
        : (widget.vehicle.fuelType ?? FuelTypes.defaults.first);
    if (_titleManuallyEdited && !force) return;
    if (force) {
      _titleManuallyEdited = false;
    }
    _isUpdatingTitle = true;
    _titleController.text = autoTitle;
    _titleController.selection = TextSelection.collapsed(
      offset: autoTitle.length,
    );
    _isUpdatingTitle = false;
  }

  void _handleTitleChanged() {
    if (_isUpdatingTitle) return;
    _titleManuallyEdited = true;
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _formatAmountValue(double value, {int? fractionDigits}) {
    if (fractionDigits != null) {
      return value.toStringAsFixed(fractionDigits);
    }
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  }

  double? _parseDecimal(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed.replaceAll(',', '.'));
  }

  void _setControllerValue(
    TextEditingController controller,
    double value, {
    int? fractionDigits,
  }) {
    if (value.isNaN || value.isInfinite) return;
    final formatted = _formatAmountValue(value, fractionDigits: fractionDigits);
    if (controller.text.trim() != formatted) {
      controller.text = formatted;
    }
  }

  Future<void> _addPhoto() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2400,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final mime = _inferImageMime(file.name);
      final attachment = VehicleEventAttachment(
        id: _uuid.v4(),
        type: VehicleEventAttachmentType.photo,
        name: file.name,
        dataUrl: 'data:$mime;base64,${base64Encode(bytes)}',
        sizeBytes: bytes.length,
      );
      setState(() => _attachments.add(attachment));
    } catch (_) {}
  }

  Future<void> _addDocument() async {
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
        ],
        withData: true,
      );
      final file = result?.files.single;
      if (file == null || file.bytes == null) return;
      final mime = _mimeTypeForExtension(file.extension);
      final attachment = VehicleEventAttachment(
        id: _uuid.v4(),
        type: VehicleEventAttachmentType.document,
        name: file.name,
        dataUrl: 'data:$mime;base64,${base64Encode(file.bytes!)}',
        sizeBytes: file.bytes!.length,
      );
      setState(() => _attachments.add(attachment));
    } catch (_) {}
  }

  void _removeAttachment(String id) {
    setState(() {
      _attachments.removeWhere((item) => item.id == id);
    });
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    final odometerText = _odometerController.text.trim();
    final odometerValue = odometerText.isEmpty
        ? null
        : int.tryParse(odometerText);
    if (_requireOdometer && odometerValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a valid odometer value.')),
      );
      return;
    }

    double? amountValue = _parseDecimal(_amountController.text);
    if (_requireAmount && amountValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter ${_amountLabel.toLowerCase()}')),
      );
      return;
    }

    double? volumeValue;
    double? pricePerLiterValue;
    if (widget.type == VehicleEventType.refuel) {
      volumeValue = _parseDecimal(_volumeController.text);
      if (volumeValue == null || volumeValue <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter refueled volume in liters')),
        );
        return;
      }

      final priceText = _pricePerLiterController.text.trim();
      if (priceText.isNotEmpty) {
        pricePerLiterValue = _parseDecimal(priceText);
        if (pricePerLiterValue == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Enter a valid price per liter or leave empty'),
            ),
          );
          return;
        }
      }
      if (pricePerLiterValue == null && amountValue != null) {
        final computed = amountValue / volumeValue;
        pricePerLiterValue = double.parse(
          computed.toStringAsFixed(_priceFractionDigits),
        );
      }
      if (amountValue == null && pricePerLiterValue != null) {
        final computed = pricePerLiterValue * volumeValue;
        amountValue = double.parse(
          computed.toStringAsFixed(_amountFractionDigits),
        );
        _setControllerValue(
          _amountController,
          amountValue,
          fractionDigits: _amountFractionDigits,
        );
      }
    }

    if (_showServiceType && (_serviceType == null || _serviceType!.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a service type')));
      return;
    }

    setState(() => _isSubmitting = true);
    final event = VehicleEvent(
      id: _isEditing ? widget.initialEvent!.id : _uuid.v4(),
      vehicleId: widget.vehicle.id,
      type: widget.type,
      title: _titleController.text.trim(),
      occurredAt: _selectedDate,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      odometerKm: odometerValue,
      amount: amountValue,
      currency: amountValue == null ? null : _currency,
      serviceType: _showServiceType ? _serviceType : null,
      fuelType: widget.type == VehicleEventType.refuel
          ? _selectedFuelType
          : null,
      volumeLiters: widget.type == VehicleEventType.refuel ? volumeValue : null,
      pricePerLiter: widget.type == VehicleEventType.refuel
          ? pricePerLiterValue
          : null,
      isFullTank: widget.type == VehicleEventType.refuel ? _isFullTank : null,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      attachments: List<VehicleEventAttachment>.unmodifiable(_attachments),
      createdAt: widget.initialEvent?.createdAt,
    );

    Navigator.of(context).pop(event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Edit ${widget.actionLabel.toLowerCase()}'
              : 'Log ${widget.actionLabel.toLowerCase()}',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DriveVehicleSummary(vehicle: widget.vehicle),
                const SizedBox(height: 24),
                const DriveSectionHeader(title: 'Details'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Give this entry a short title',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DriveDatePickerChip(
                  date: _selectedDate,
                  color: Theme.of(context).colorScheme.secondary,
                  onDateChanged: (value) =>
                      setState(() => _selectedDate = value),
                  icon: Icons.calendar_today_outlined,
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  firstDate: DateTime(2000),
                  labelBuilder: _formatDate,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Where did this happen?',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _odometerController,
                  decoration: const InputDecoration(labelText: 'Odometer (km)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (!_requireOdometer) return null;
                    final trimmed = (value ?? '').trim();
                    if (trimmed.isEmpty) {
                      return 'Required';
                    }
                    final parsed = int.tryParse(trimmed);
                    if (parsed == null || parsed < 0) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                if (_showServiceType) ...[
                  const SizedBox(height: 16),
                  DropdownMenu<String>(
                    initialSelection: _serviceType,
                    label: const Text('Service type'),
                    onSelected: (value) => setState(() => _serviceType = value),
                    dropdownMenuEntries: _serviceTypes
                        .map(
                          (item) => DropdownMenuEntry(value: item, label: item),
                        )
                        .toList(),
                  ),
                ],
                if (_showAmount) ...[
                  if (widget.type == VehicleEventType.refuel &&
                      _availableFuelTypes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    DropdownMenu<String>(
                      initialSelection:
                          _selectedFuelType ?? _availableFuelTypes.firstOrNull,
                      label: const Text('Fuel type'),
                      onSelected: (value) {
                        setState(() {
                          _selectedFuelType = value;
                          _setTitleFromFuel();
                        });
                      },
                      dropdownMenuEntries: _availableFuelTypes
                          .map(
                            (item) =>
                                DropdownMenuEntry(value: item, label: item),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  DriveFuelCostInputs(
                    amountController: _amountController,
                    volumeController: _volumeController,
                    priceController: _pricePerLiterController,
                    amountLabel: _amountLabel,
                    amountHint: '0.00',
                    volumeLabel: 'Volume (L)',
                    volumeHint: '0.0',
                    priceLabel: 'Price per liter',
                    priceHint: '0.00',
                    priceSuffix: '/L',
                    amountTrailing: DropdownMenu<String>(
                      initialSelection: _currency,
                      label: const Text('Currency'),
                      width: 110,
                      onSelected: (value) {
                        if (value == null) return;
                        setState(() => _currency = value);
                      },
                      dropdownMenuEntries: const ['PLN', 'EUR', 'USD']
                          .map(
                            (code) =>
                                DropdownMenuEntry(value: code, label: code),
                          )
                          .toList(),
                    ),
                    onAmountChanged: (_) =>
                        _handleCostFieldChanged(_CostField.amount),
                    onVolumeChanged: (_) =>
                        _handleCostFieldChanged(_CostField.volume),
                    onPriceChanged: (_) =>
                        _handleCostFieldChanged(_CostField.price),
                  ),
                  if (widget.type == VehicleEventType.refuel) ...[
                    const SizedBox(height: 12),
                    DriveFullTankSwitch(
                      value: _isFullTank,
                      onChanged: (value) => setState(() => _isFullTank = value),
                    ),
                  ],
                ],
                const SizedBox(height: 24),
                const DriveSectionHeader(title: 'Attachments'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    DriveActionChip(
                      icon: Icons.photo_camera_outlined,
                      label: 'Add photo',
                      color: Theme.of(context).colorScheme.primary,
                      onTap: _addPhoto,
                    ),
                    DriveActionChip(
                      icon: Icons.attach_file,
                      label: 'Add file',
                      color: Theme.of(context).colorScheme.secondary,
                      onTap: _addDocument,
                    ),
                  ],
                ),
                DriveAttachmentChipList(
                  attachments: _attachments,
                  spacing: 8,
                  runSpacing: 8,
                  emptyIndicator: const SizedBox.shrink(),
                  onTap: (attachment) =>
                      showVehicleAttachment(context, attachment),
                  onDeleted: (attachment) => _removeAttachment(attachment.id),
                ),
                const SizedBox(height: 24),
                const DriveSectionHeader(title: 'Notes'),
                const SizedBox(height: 12),
                DriveNotesField(
                  controller: _notesController,
                  hint: 'Add any context or reminders...',
                  minLines: 3,
                  maxLines: 6,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save event'),
          ),
        ),
      ),
    );
  }

  String _inferImageMime(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }

  String _mimeTypeForExtension(String? extension) {
    final lower = (extension ?? '').toLowerCase();
    return switch (lower) {
      'pdf' => 'application/pdf',
      'doc' => 'application/msword',
      'docx' =>
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'jpg' => 'image/jpeg',
      'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'heic' => 'image/heic',
      _ => 'application/octet-stream',
    };
  }
}

extension _FirstOrNullListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : this[0];
}
