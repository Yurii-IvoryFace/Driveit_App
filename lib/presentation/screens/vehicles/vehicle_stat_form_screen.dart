import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/vehicle_stat.dart' as vehicle_stat;
import '../../../core/theme/app_colors.dart';
import '../../bloc/vehicle/vehicle_bloc.dart';
import '../../bloc/vehicle/vehicle_event.dart';
import '../../bloc/vehicle/vehicle_state.dart';

class VehicleStatFormScreen extends StatefulWidget {
  final String vehicleId;
  final vehicle_stat.VehicleStat? stat;

  const VehicleStatFormScreen({super.key, required this.vehicleId, this.stat});

  @override
  State<VehicleStatFormScreen> createState() => _VehicleStatFormScreenState();
}

class _VehicleStatFormScreenState extends State<VehicleStatFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _unitController = TextEditingController();
  final _notesController = TextEditingController();

  vehicle_stat.VehicleStatType _selectedType =
      vehicle_stat.VehicleStatType.custom;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.stat != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final stat = widget.stat!;
    _valueController.text = stat.value;
    _unitController.text = stat.unit ?? '';
    _notesController.text = stat.notes ?? '';
    _selectedType = stat.type;
    _selectedDate = stat.createdAt;
  }

  @override
  void dispose() {
    _valueController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stat == null ? 'Add Statistic' : 'Edit Statistic'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveStat,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: BlocListener<VehicleBloc, VehicleState>(
        listener: (context, state) {
          if (state is VehicleStatsLoaded) {
            Navigator.of(context).pop();
          } else if (state is VehicleStatsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stat Type
                _buildSectionHeader('Statistic Type'),
                const SizedBox(height: 16.0),

                DropdownButtonFormField<vehicle_stat.VehicleStatType>(
                  initialValue: _selectedType,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Type *',
                    border: OutlineInputBorder(),
                  ),
                  items: vehicle_stat.VehicleStatType.values.map((type) {
                    return DropdownMenuItem<vehicle_stat.VehicleStatType>(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),

                // Value and Unit
                _buildSectionHeader('Value'),
                const SizedBox(height: 16.0),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _valueController,
                        decoration: const InputDecoration(
                          labelText: 'Value *',
                          hintText: 'e.g., 50000',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a value';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          hintText: 'km',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // Date
                _buildSectionHeader('Date'),
                const SizedBox(height: 16.0),

                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date *',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Select date',
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Notes
                _buildSectionHeader('Notes'),
                const SizedBox(height: 16.0),

                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Additional information about this statistic',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _saveStat() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final stat = vehicle_stat.VehicleStat(
        id: widget.stat?.id ?? const Uuid().v4(),
        vehicleId: widget.vehicleId,
        type: _selectedType,
        value: _valueController.text.trim(),
        unit: _unitController.text.trim().isEmpty
            ? null
            : _unitController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: _selectedDate!,
      );

      if (widget.stat == null) {
        context.read<VehicleBloc>().add(AddVehicleStatEvent(stat));
      } else {
        context.read<VehicleBloc>().add(UpdateVehicleStatEvent(stat));
      }
    }
  }
}
