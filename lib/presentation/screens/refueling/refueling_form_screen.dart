import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/fuel_type.dart';
import '../../../domain/entities/refueling_entry.dart';
import '../../../domain/entities/vehicle.dart';
import '../../bloc/refueling/refueling_bloc.dart';
import '../../bloc/refueling/refueling_event.dart';
import '../../bloc/refueling/refueling_state.dart';
import '../../bloc/vehicle/vehicle_bloc.dart';
import '../../bloc/vehicle/vehicle_event.dart';
import '../../bloc/vehicle/vehicle_state.dart';

class RefuelingFormScreen extends StatefulWidget {
  final RefuelingEntry? entry;
  final String? vehicleId;

  const RefuelingFormScreen({super.key, this.entry, this.vehicleId});

  @override
  State<RefuelingFormScreen> createState() => _RefuelingFormScreenState();
}

class _RefuelingFormScreenState extends State<RefuelingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _volumeController = TextEditingController();
  final _pricePerLiterController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _odometerController = TextEditingController();
  final _gasStationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  FuelType _selectedFuelType = FuelType.gasoline;
  bool _isFullTank = true;
  String? _selectedVehicleId;
  List<Vehicle> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
    context.read<VehicleBloc>().add(LoadVehicles());
  }

  void _initializeForm() {
    if (widget.entry != null) {
      final entry = widget.entry!;
      _volumeController.text = entry.volumeLiters.toString();
      _pricePerLiterController.text = entry.pricePerLiter.toString();
      _totalAmountController.text = entry.totalAmount.toString();
      _odometerController.text = entry.odometerKm.toString();
      _gasStationController.text = entry.gasStation ?? '';
      _notesController.text = entry.notes ?? '';
      _selectedDate = entry.date;
      _selectedFuelType = entry.fuelType;
      _isFullTank = entry.isFullTank;
      _selectedVehicleId = entry.vehicleId;
    } else if (widget.vehicleId != null) {
      _selectedVehicleId = widget.vehicleId;
    }
  }

  @override
  void dispose() {
    _volumeController.dispose();
    _pricePerLiterController.dispose();
    _totalAmountController.dispose();
    _odometerController.dispose();
    _gasStationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'Add Refueling' : 'Edit Refueling'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
      ),
      backgroundColor: AppColors.background,
      body: BlocListener<RefuelingBloc, RefuelingState>(
        listener: (context, state) {
          if (state is RefuelingOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.of(context).pop();
          } else if (state is RefuelingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        child: BlocBuilder<VehicleBloc, VehicleState>(
          builder: (context, vehicleState) {
            if (vehicleState is VehicleLoaded) {
              _vehicles = vehicleState.vehicles;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVehicleSelector(),
                    const SizedBox(height: 16),
                    _buildDateSelector(),
                    const SizedBox(height: 16),
                    _buildFuelTypeSelector(),
                    const SizedBox(height: 16),
                    _buildVolumeField(),
                    const SizedBox(height: 16),
                    _buildPricePerLiterField(),
                    const SizedBox(height: 16),
                    _buildTotalAmountField(),
                    const SizedBox(height: 16),
                    _buildOdometerField(),
                    const SizedBox(height: 16),
                    _buildGasStationField(),
                    const SizedBox(height: 16),
                    _buildFullTankSwitch(),
                    const SizedBox(height: 16),
                    _buildNotesField(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVehicleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedVehicleId,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: AppColors.surface,
          ),
          items: _vehicles.map((vehicle) {
            return DropdownMenuItem<String>(
              value: vehicle.id,
              child: Text('${vehicle.make} ${vehicle.model} (${vehicle.year})'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedVehicleId = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a vehicle';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
              color: AppColors.surface,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFuelTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fuel Type',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<FuelType>(
          initialValue: _selectedFuelType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: AppColors.surface,
          ),
          items: FuelType.values.map((type) {
            return DropdownMenuItem<FuelType>(
              value: type,
              child: Row(
                children: [
                  Text(type.icon),
                  const SizedBox(width: 8),
                  Text(type.displayName),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedFuelType = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildVolumeField() {
    return TextFormField(
      controller: _volumeController,
      decoration: InputDecoration(
        labelText: 'Volume (${_selectedFuelType.unit})',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: AppColors.surface,
      ),
      keyboardType: TextInputType.number,
      onChanged: _calculateTotalAmount,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter volume';
        }
        if (double.tryParse(value) == null || double.parse(value) <= 0) {
          return 'Please enter a valid volume';
        }
        return null;
      },
    );
  }

  Widget _buildPricePerLiterField() {
    return TextFormField(
      controller: _pricePerLiterController,
      decoration: InputDecoration(
        labelText: 'Price per ${_selectedFuelType.unit}',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: AppColors.surface,
      ),
      keyboardType: TextInputType.number,
      onChanged: _calculateTotalAmount,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter price per liter';
        }
        if (double.tryParse(value) == null || double.parse(value) <= 0) {
          return 'Please enter a valid price';
        }
        return null;
      },
    );
  }

  Widget _buildTotalAmountField() {
    return TextFormField(
      controller: _totalAmountController,
      decoration: InputDecoration(
        labelText: 'Total Amount (₴)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: AppColors.surface,
      ),
      keyboardType: TextInputType.number,
      onChanged: _calculatePricePerLiter,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter total amount';
        }
        if (double.tryParse(value) == null || double.parse(value) <= 0) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }

  Widget _buildOdometerField() {
    return TextFormField(
      controller: _odometerController,
      decoration: InputDecoration(
        labelText: 'Odometer (km)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: AppColors.surface,
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter odometer reading';
        }
        if (int.tryParse(value) == null || int.parse(value) < 0) {
          return 'Please enter a valid odometer reading';
        }
        return null;
      },
    );
  }

  Widget _buildGasStationField() {
    return TextFormField(
      controller: _gasStationController,
      decoration: InputDecoration(
        labelText: 'Gas Station (Optional)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }

  Widget _buildFullTankSwitch() {
    return Row(
      children: [
        Switch(
          value: _isFullTank,
          onChanged: (value) {
            setState(() {
              _isFullTank = value;
            });
          },
          activeThumbColor: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          'Full Tank',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: InputDecoration(
        labelText: 'Notes (Optional)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: AppColors.surface,
      ),
      maxLines: 3,
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<RefuelingBloc, RefuelingState>(
      builder: (context, state) {
        final isLoading = state is RefuelingOperationInProgress;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    widget.entry == null ? 'Add Refueling' : 'Update Refueling',
                  ),
          ),
        );
      },
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _calculateTotalAmount(String value) {
    final volume = double.tryParse(_volumeController.text);
    final pricePerLiter = double.tryParse(_pricePerLiterController.text);

    if (volume != null && pricePerLiter != null) {
      final total = volume * pricePerLiter;
      _totalAmountController.text = total.toStringAsFixed(2);
    }
  }

  void _calculatePricePerLiter(String value) {
    final volume = double.tryParse(_volumeController.text);
    final totalAmount = double.tryParse(_totalAmountController.text);

    if (volume != null && totalAmount != null && volume > 0) {
      final pricePerLiter = totalAmount / volume;
      _pricePerLiterController.text = pricePerLiter.toStringAsFixed(2);
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a vehicle')));
      return;
    }

    final entry = RefuelingEntry(
      id: widget.entry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      vehicleId: _selectedVehicleId!,
      date: _selectedDate,
      volumeLiters: double.parse(_volumeController.text),
      pricePerLiter: double.parse(_pricePerLiterController.text),
      totalAmount: double.parse(_totalAmountController.text),
      currency: 'UAH',
      odometerKm: int.parse(_odometerController.text),
      fuelType: _selectedFuelType,
      isFullTank: _isFullTank,
      gasStation: _gasStationController.text.isNotEmpty
          ? _gasStationController.text
          : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      createdAt: widget.entry?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.entry == null) {
      context.read<RefuelingBloc>().add(AddRefuelingEntry(entry));
    } else {
      context.read<RefuelingBloc>().add(UpdateRefuelingEntry(entry));
    }
  }
}
