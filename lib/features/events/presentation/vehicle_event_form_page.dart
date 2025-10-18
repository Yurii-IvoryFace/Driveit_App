import 'dart:convert';

import 'package:driveit_app/features/events/domain/vehicle_event.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

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
  final _notesController = TextEditingController();
  late final TextEditingController _dateController;

  final _uuid = const Uuid();
  final _attachments = <VehicleEventAttachment>[];

  DateTime _selectedDate = DateTime.now();
  String? _serviceType;
  String _currency = 'PLN';
  bool _isSubmitting = false;
  bool get _isEditing => widget.initialEvent != null;

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
    _dateController = TextEditingController(text: _formatDate(_selectedDate));
    if (initial != null) {
      _titleController.text = initial.title;
      _locationController.text = initial.location ?? '';
      _odometerController.text = initial.odometerKm == null
          ? ''
          : initial.odometerKm.toString();
      _amountController.text = initial.amount == null
          ? ''
          : _formatAmountValue(initial.amount!);
      _notesController.text = initial.notes ?? '';
      _serviceType = initial.serviceType;
      _currency = initial.currency ?? _currency;
      _attachments.addAll(initial.attachments);
    } else {
      _titleController.text = _defaultTitleForType(widget.type);
      final odometer = widget.vehicle.odometerKm;
      if (odometer != null) {
        _odometerController.text = odometer.toString();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _odometerController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _dateController.dispose();
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _dateController.text = _formatDate(picked);
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _formatAmountValue(double value) {
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
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

    final amountText = _amountController.text.trim().replaceAll(',', '.');
    final amountValue = amountText.isEmpty ? null : double.tryParse(amountText);
    if (_requireAmount && amountValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter ${_amountLabel.toLowerCase()}')),
      );
      return;
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
                _SectionLabel(title: 'Vehicle'),
                const SizedBox(height: 8),
                TextFormField(
                  enabled: false,
                  initialValue: widget.vehicle.displayName,
                  decoration: const InputDecoration(labelText: 'Vehicle'),
                ),
                const SizedBox(height: 24),
                _SectionLabel(title: 'Details'),
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
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  onTap: _selectDate,
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          decoration: InputDecoration(
                            labelText: _amountLabel,
                            hintText: '0.00',
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      DropdownMenu<String>(
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
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                _SectionLabel(title: 'Attachments'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _addPhoto,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Add photo'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _addDocument,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Add file'),
                    ),
                  ],
                ),
                if (_attachments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _attachments
                        .map(
                          (item) => InputChip(
                            label: Text(item.name),
                            avatar: Icon(
                              item.type == VehicleEventAttachmentType.photo
                                  ? Icons.photo_outlined
                                  : Icons.insert_drive_file_outlined,
                            ),
                            onDeleted: () => _removeAttachment(item.id),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 24),
                _SectionLabel(title: 'Notes'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    hintText: 'Add any context or reminders...',
                  ),
                  maxLines: 4,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}
