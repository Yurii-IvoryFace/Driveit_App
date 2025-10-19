import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_stat.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_stat_type.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_stat_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class VehicleStatFormPage extends StatefulWidget {
  const VehicleStatFormPage({
    super.key,
    required this.vehicle,
    this.initialStat,
    this.statType,
  });

  final Vehicle vehicle;
  final VehicleStat? initialStat;
  final VehicleStatType? statType;

  @override
  State<VehicleStatFormPage> createState() => _VehicleStatFormPageState();
}

class _VehicleStatFormPageState extends State<VehicleStatFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _customLabelController = TextEditingController();
  final _customValueController = TextEditingController();
  final _uuid = const Uuid();

  VehicleStatType? _selectedType;
  DateTime? _selectedDate;
  int? _numericValue;
  String? _customValue;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.statType ?? widget.initialStat?.type;
    if (widget.initialStat != null) {
      _selectedDate = widget.initialStat!.dateValue;
      _numericValue = widget.initialStat!.numericValue;
      _customValue = widget.initialStat!.value?.toString();
      _notesController.text = widget.initialStat!.notes ?? '';
      if (widget.initialStat!.type == VehicleStatType.custom) {
        _customLabelController.text = widget.initialStat!.notes ?? '';
        _customValueController.text = widget.initialStat!.value?.toString() ?? '';
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _customLabelController.dispose();
    _customValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialStat != null;
    final title = isEditing ? 'Edit ${_selectedType?.label ?? 'statistic'}' : 'Add statistic';

    return Scaffold(
      backgroundColor: const Color(0xFF0F1418),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1418),
        foregroundColor: Colors.white,
        title: Text(title),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeSelector(),
              const SizedBox(height: 24),
              if (_selectedType != null) ...[
                _buildValueInput(),
                const SizedBox(height: 24),
                _buildNotesInput(),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistic type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<VehicleStatType>(
          initialValue: _selectedType,
          decoration: const InputDecoration(
            hintText: 'Select statistic type',
          ),
          items: VehicleStatType.values
              .where((type) => type.isUserEditable && type != VehicleStatType.odometer)
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(
                          type.icon,
                          color: Colors.tealAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(type.label),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedType = value;
              _selectedDate = null;
              _numericValue = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildValueInput() {
    if (_selectedType == null) return const SizedBox.shrink();

    if (_selectedType!.isDateType) {
      return _buildDateInput();
    } else if (_selectedType!.isNumericType) {
      return _buildNumericInput();
    } else if (_selectedType!.isCustomType) {
      return _buildCustomInput();
    }

    return const SizedBox.shrink();
  }

  Widget _buildDateInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2024),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.tealAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? MaterialLocalizations.of(context).formatShortDate(_selectedDate!)
                      : 'Select date',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _selectedDate != null ? Colors.white : Colors.white60,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white38,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumericInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Value',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: _numericValue?.toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter ${_selectedType!.label.toLowerCase()}',
            suffixText: _selectedType!.unit,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a value';
            }
            final numeric = int.tryParse(value.trim());
            if (numeric == null || numeric < 0) {
              return 'Please enter a valid positive number';
            }
            return null;
          },
          onChanged: (value) {
            _numericValue = int.tryParse(value.trim());
          },
        ),
      ],
    );
  }

  Widget _buildCustomInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Label',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _customLabelController,
          decoration: const InputDecoration(
            hintText: 'Enter custom label',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a label';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Value',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _customValueController,
          decoration: const InputDecoration(
            hintText: 'Enter custom value',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a value';
            }
            return null;
          },
          onChanged: (value) {
            _customValue = value.trim();
          },
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add any additional notes...',
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton(
            onPressed: _isLoading ? null : _saveStat,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.initialStat != null ? 'Update' : 'Save'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _saveStat() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) return;

    // Validate based on type
    if (_selectedType!.isDateType && _selectedDate == null) {
      _showError('Please select a date');
      return;
    }
    if (_selectedType!.isNumericType && _numericValue == null) {
      _showError('Please enter a valid value');
      return;
    }
    if (_selectedType!.isCustomType && (_customLabelController.text.trim().isEmpty || _customValueController.text.trim().isEmpty)) {
      _showError('Please enter both label and value');
      return;
    }

    // Check for duplicates (only for non-custom types)
    if (!_selectedType!.isCustomType) {
      final repository = context.read<VehicleStatRepository>();
      final existingStats = await repository.fetchStats(widget.vehicle.id);
      final duplicateExists = existingStats.any((stat) => 
        stat.type == _selectedType && 
        stat.id != widget.initialStat?.id
      );
      
      if (duplicateExists) {
        _showError('A ${_selectedType!.label.toLowerCase()} entry already exists for this vehicle');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final repository = context.read<VehicleStatRepository>();
      final now = DateTime.now();
      
      dynamic value;
      String? notes;
      
      if (_selectedType!.isCustomType) {
        value = _customValueController.text.trim();
        notes = _customLabelController.text.trim();
      } else {
        value = _selectedType!.isDateType ? _selectedDate : _numericValue;
        notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();
      }
      
      final stat = VehicleStat(
        id: widget.initialStat?.id ?? _uuid.v4(),
        vehicleId: widget.vehicle.id,
        type: _selectedType!,
        value: value,
        notes: notes,
        createdAt: widget.initialStat?.createdAt ?? now,
        updatedAt: now,
      );

      await repository.saveStat(stat);
      
      if (mounted) {
        Navigator.of(context).pop(stat);
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to save statistic: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete statistic'),
        content: Text(
          'Are you sure you want to delete this ${_selectedType?.label.toLowerCase()} entry?',
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

    if (confirmed == true && widget.initialStat != null) {
      setState(() => _isLoading = true);
      
      final repository = context.read<VehicleStatRepository>();
      try {
        await repository.deleteStat(widget.initialStat!.id);
        
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate deletion
        }
      } catch (e) {
        if (mounted) {
          _showError('Failed to delete statistic: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.fixed,
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
