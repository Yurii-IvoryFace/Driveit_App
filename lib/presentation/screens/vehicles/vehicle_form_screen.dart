import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/vehicle/brand_selector_field.dart';
import '../../bloc/vehicle/vehicle_bloc.dart';
import '../../bloc/vehicle/vehicle_event.dart';
import '../../bloc/vehicle/vehicle_state.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const VehicleFormScreen({super.key, this.vehicle});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _vinController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _odometerController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _purchaseOdometerController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedBrand;
  String? _selectedFuelType;
  DateTime? _purchaseDate;
  bool _isPrimary = false;

  final List<String> _fuelTypes = [
    'Gasoline',
    'Diesel',
    'Electric',
    'Hybrid',
    'LPG',
    'CNG',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final vehicle = widget.vehicle!;
    _nameController.text = vehicle.name;
    _makeController.text = vehicle.make;
    _modelController.text = vehicle.model;
    _yearController.text = vehicle.year.toString();
    _vinController.text = vehicle.vin ?? '';
    _licensePlateController.text = vehicle.licensePlate ?? '';
    _odometerController.text = vehicle.odometerKm?.toString() ?? '';
    _purchasePriceController.text = vehicle.purchasePrice?.toString() ?? '';
    _purchaseOdometerController.text =
        vehicle.purchaseOdometerKm?.toString() ?? '';
    _notesController.text = vehicle.notes ?? '';
    _selectedBrand = vehicle.make;
    _selectedFuelType = vehicle.fuelType;
    _purchaseDate = vehicle.purchaseDate;
    _isPrimary = vehicle.isPrimary;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _vinController.dispose();
    _licensePlateController.dispose();
    _odometerController.dispose();
    _purchasePriceController.dispose();
    _purchaseOdometerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle == null ? 'Add Vehicle' : 'Edit Vehicle'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveVehicle,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: BlocListener<VehicleBloc, VehicleState>(
        listener: (context, state) {
          if (state is VehicleLoaded) {
            Navigator.of(context).pop();
          } else if (state is VehicleError) {
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
                // Basic Information
                _buildSectionHeader('Basic Information'),
                const SizedBox(height: 16.0),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Name *',
                    hintText: 'e.g., My Car',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a vehicle name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                BrandSelectorField(
                  selectedBrand: _selectedBrand,
                  onChanged: (value) {
                    setState(() {
                      _selectedBrand = value;
                      _makeController.text = value ?? '';
                    });
                  },
                  label: 'Brand *',
                ),
                const SizedBox(height: 16.0),

                TextFormField(
                  controller: _modelController,
                  decoration: const InputDecoration(
                    labelText: 'Model *',
                    hintText: 'e.g., Camry',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a model';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(
                    labelText: 'Year *',
                    hintText: 'e.g., 2020',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a year';
                    }
                    final year = int.tryParse(value);
                    if (year == null ||
                        year < 1900 ||
                        year > DateTime.now().year + 1) {
                      return 'Please enter a valid year';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),

                // Additional Information
                _buildSectionHeader('Additional Information'),
                const SizedBox(height: 16.0),

                TextFormField(
                  controller: _vinController,
                  decoration: const InputDecoration(
                    labelText: 'VIN',
                    hintText: 'Vehicle Identification Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),

                TextFormField(
                  controller: _licensePlateController,
                  decoration: const InputDecoration(
                    labelText: 'License Plate',
                    hintText: 'e.g., ABC-123',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),

                DropdownButtonFormField<String>(
                  initialValue: _selectedFuelType,
                  onChanged: (value) {
                    setState(() {
                      _selectedFuelType = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Fuel Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _fuelTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16.0),

                TextFormField(
                  controller: _odometerController,
                  decoration: const InputDecoration(
                    labelText: 'Current Odometer (km)',
                    hintText: 'e.g., 50000',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24.0),

                // Purchase Information
                _buildSectionHeader('Purchase Information'),
                const SizedBox(height: 16.0),

                TextFormField(
                  controller: _purchasePriceController,
                  decoration: const InputDecoration(
                    labelText: 'Purchase Price',
                    hintText: 'e.g., 25000',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16.0),

                TextFormField(
                  controller: _purchaseOdometerController,
                  decoration: const InputDecoration(
                    labelText: 'Purchase Odometer (km)',
                    hintText: 'e.g., 10000',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16.0),

                InkWell(
                  onTap: _selectPurchaseDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Purchase Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _purchaseDate != null
                          ? '${_purchaseDate!.day}/${_purchaseDate!.month}/${_purchaseDate!.year}'
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
                    hintText: 'Additional information about your vehicle',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24.0),

                // Primary Vehicle
                CheckboxListTile(
                  title: const Text('Set as primary vehicle'),
                  subtitle: const Text('This will be your main vehicle'),
                  value: _isPrimary,
                  onChanged: (value) {
                    setState(() {
                      _isPrimary = value ?? false;
                    });
                  },
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

  void _selectPurchaseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _purchaseDate = date;
      });
    }
  }

  void _saveVehicle() {
    if (_formKey.currentState!.validate()) {
      final vehicle = Vehicle(
        id: widget.vehicle?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text),
        vin: _vinController.text.trim().isEmpty
            ? null
            : _vinController.text.trim(),
        licensePlate: _licensePlateController.text.trim().isEmpty
            ? null
            : _licensePlateController.text.trim(),
        fuelType: _selectedFuelType,
        odometerKm: _odometerController.text.trim().isEmpty
            ? null
            : int.tryParse(_odometerController.text.trim()),
        purchaseDate: _purchaseDate,
        purchasePrice: _purchasePriceController.text.trim().isEmpty
            ? null
            : double.tryParse(_purchasePriceController.text.trim()),
        purchaseOdometerKm: _purchaseOdometerController.text.trim().isEmpty
            ? null
            : int.tryParse(_purchaseOdometerController.text.trim()),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        isPrimary: _isPrimary,
        createdAt: widget.vehicle?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.vehicle == null) {
        context.read<VehicleBloc>().add(AddVehicle(vehicle));
      } else {
        context.read<VehicleBloc>().add(UpdateVehicle(vehicle));
      }
    }
  }
}
