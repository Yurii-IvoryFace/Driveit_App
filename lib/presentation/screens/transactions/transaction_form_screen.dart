import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/usecases/validate_odometer.dart';
import '../../../core/di/injection_container.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../bloc/transaction/transaction_event.dart';
import '../../bloc/transaction/transaction_state.dart';
import '../../bloc/vehicle/vehicle_bloc.dart';
import '../../bloc/vehicle/vehicle_state.dart';

class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction;
  final String? vehicleId;

  const TransactionFormScreen({super.key, this.transaction, this.vehicleId});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _amountController = TextEditingController();
  final _odometerController = TextEditingController();
  final _volumeController = TextEditingController();
  final _pricePerLiterController = TextEditingController();
  final _serviceProviderController = TextEditingController();

  TransactionType _selectedType = TransactionType.refueling;
  String? _selectedVehicleId;
  DateTime _selectedDate = DateTime.now();
  String _currency = 'UAH';
  String? _fuelType;
  String? _serviceType;
  bool _isFullTank = false;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _loadTransactionData();
    }
    if (widget.vehicleId != null) {
      _selectedVehicleId = widget.vehicleId;
    }
  }

  void _loadTransactionData() {
    final transaction = widget.transaction!;
    _selectedType = transaction.type;
    _selectedVehicleId = transaction.vehicleId;
    _selectedDate = transaction.date;
    _currency = transaction.currency ?? 'UAH';
    _notesController.text = transaction.notes ?? '';
    _amountController.text = transaction.amount?.toString() ?? '';
    _odometerController.text = transaction.odometerKm?.toString() ?? '';
    _volumeController.text = transaction.volumeLiters?.toString() ?? '';
    _pricePerLiterController.text = transaction.pricePerLiter?.toString() ?? '';
    _serviceProviderController.text = transaction.serviceProvider ?? '';
    _fuelType = transaction.fuelType;
    _serviceType = transaction.serviceType;
    _isFullTank = transaction.isFullTank ?? false;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _amountController.dispose();
    _odometerController.dispose();
    _volumeController.dispose();
    _pricePerLiterController.dispose();
    _serviceProviderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? 'Add Transaction' : 'Edit Transaction',
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is TransactionError) {
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
            if (vehicleState is VehicleLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            List<Vehicle> vehicles = [];
            if (vehicleState is VehicleLoaded) {
              vehicles = vehicleState.vehicles;
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelector(),
                    const SizedBox(height: 16),
                    _buildVehicleSelector(vehicles),
                    const SizedBox(height: 16),
                    _buildDateSelector(),
                    const SizedBox(height: 16),
                    _buildAmountField(),
                    const SizedBox(height: 16),
                    _buildOdometerField(),
                    const SizedBox(height: 16),
                    _buildConditionalFields(),
                    const SizedBox(height: 16),
                    _buildNotesField(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Type',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: TransactionType.values.map((type) {
            return ChoiceChip(
              label: Text(type.displayName),
              selected: _selectedType == type,
              onSelected: (selected) {
                setState(() {
                  _selectedType = type;
                });
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVehicleSelector(List<Vehicle> vehicles) {
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
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Select vehicle',
          ),
          items: vehicles.map((vehicle) {
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
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'Amount',
        border: OutlineInputBorder(),
        prefixText: '₴ ',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter amount';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter valid amount';
        }
        return null;
      },
    );
  }

  Widget _buildOdometerField() {
    return TextFormField(
      controller: _odometerController,
      decoration: const InputDecoration(
        labelText: 'Odometer (km)',
        border: OutlineInputBorder(),
        suffixText: 'km',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (int.tryParse(value) == null) {
            return 'Please enter valid odometer reading';
          }
        }
        return null;
      },
    );
  }

  Widget _buildConditionalFields() {
    switch (_selectedType) {
      case TransactionType.refueling:
        return _buildRefuelingFields();
      case TransactionType.maintenance:
        return _buildMaintenanceFields();
      case TransactionType.insurance:
      case TransactionType.parking:
      case TransactionType.toll:
      case TransactionType.carWash:
      case TransactionType.other:
        return _buildOtherFields();
    }
  }

  Widget _buildRefuelingFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _volumeController,
                decoration: const InputDecoration(
                  labelText: 'Volume (L)',
                  border: OutlineInputBorder(),
                  suffixText: 'L',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _pricePerLiterController,
                decoration: const InputDecoration(
                  labelText: 'Price per Liter',
                  border: OutlineInputBorder(),
                  prefixText: '₴ ',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _fuelType,
          decoration: const InputDecoration(
            labelText: 'Fuel Type',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'gasoline', child: Text('Gasoline')),
            DropdownMenuItem(value: 'diesel', child: Text('Diesel')),
            DropdownMenuItem(value: 'electric', child: Text('Electric')),
            DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
          ],
          onChanged: (value) {
            setState(() {
              _fuelType = value;
            });
          },
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          title: const Text('Full Tank'),
          value: _isFullTank,
          onChanged: (value) {
            setState(() {
              _isFullTank = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  Widget _buildMaintenanceFields() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: _serviceType,
          decoration: const InputDecoration(
            labelText: 'Service Type',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'oil_change', child: Text('Oil Change')),
            DropdownMenuItem(
              value: 'brake_service',
              child: Text('Brake Service'),
            ),
            DropdownMenuItem(
              value: 'tire_rotation',
              child: Text('Tire Rotation'),
            ),
            DropdownMenuItem(value: 'inspection', child: Text('Inspection')),
            DropdownMenuItem(value: 'repair', child: Text('Repair')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: (value) {
            setState(() {
              _serviceType = value;
            });
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _serviceProviderController,
          decoration: const InputDecoration(
            labelText: 'Service Provider',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherFields() {
    return const SizedBox.shrink();
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notes',
        border: OutlineInputBorder(),
        hintText: 'Additional notes...',
      ),
      maxLines: 3,
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final isLoading = state is TransactionOperationInProgress;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _saveTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    widget.transaction == null
                        ? 'Add Transaction'
                        : 'Update Transaction',
                  ),
          ),
        );
      },
    );
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicleId == null) return;

    final odometerKm = int.tryParse(_odometerController.text);

    // Validate odometer if provided
    if (odometerKm != null) {
      final validateOdometer = getIt<ValidateOdometer>();

      // Get the selected vehicle to get its current odometer
      final vehicles = context.read<VehicleBloc>().state;
      Vehicle? selectedVehicle;
      if (vehicles is VehicleLoaded) {
        selectedVehicle = vehicles.vehicles.firstWhere(
          (v) => v.id == _selectedVehicleId,
          orElse: () => throw StateError('Vehicle not found'),
        );
      }

      final validationResult = await validateOdometer.call(
        vehicleId: _selectedVehicleId!,
        transactionId: widget.transaction?.id,
        date: _selectedDate,
        odometerKm: odometerKm,
        vehicleOdometerKm: selectedVehicle?.odometerKm,
      );

      if (!validationResult.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              validationResult.errorMessage ?? 'Invalid odometer reading',
            ),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
    }

    final transaction = Transaction(
      id: widget.transaction?.id ?? const Uuid().v4(),
      vehicleId: _selectedVehicleId!,
      type: _selectedType,
      date: _selectedDate,
      amount: double.tryParse(_amountController.text),
      currency: _currency,
      odometerKm: odometerKm,
      volumeLiters: double.tryParse(_volumeController.text),
      pricePerLiter: double.tryParse(_pricePerLiterController.text),
      fuelType: _fuelType,
      isFullTank: _isFullTank,
      serviceType: _serviceType,
      serviceProvider: _serviceProviderController.text.isNotEmpty
          ? _serviceProviderController.text
          : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      createdAt: widget.transaction?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.transaction == null) {
      context.read<TransactionBloc>().add(AddTransactionEvent(transaction));
    } else {
      context.read<TransactionBloc>().add(UpdateTransactionEvent(transaction));
    }
  }
}
