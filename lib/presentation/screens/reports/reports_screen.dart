import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../bloc/reports/reports_bloc.dart';
import '../../bloc/reports/reports_event.dart';
import '../../bloc/vehicle/vehicle_bloc.dart';
import '../../bloc/vehicle/vehicle_state.dart';
import '../../../domain/usecases/vehicle_usecases.dart' as vehicle_usecases;
import '../../../core/di/injection_container.dart';
import 'tabs/overview_tab.dart';
import 'tabs/fuel_tab.dart';
import 'tabs/costs_tab.dart';
import 'tabs/odometer_tab.dart';
import 'tabs/ownership_tab.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedVehicleId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeDateRange();
    _loadPrimaryVehicleAndData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeDateRange() {
    final now = DateTime.now();
    _endDate = now;
    _startDate = DateTime(now.year, now.month - 2, now.day); // Last 3 months
  }

  Future<void> _loadPrimaryVehicleAndData() async {
    try {
      // Get primary vehicle
      final getPrimaryVehicle = getIt<vehicle_usecases.GetPrimaryVehicle>();
      final primaryVehicle = await getPrimaryVehicle();

      if (primaryVehicle != null) {
        setState(() {
          _selectedVehicleId = primaryVehicle.id;
        });
      }

      // Load initial data
      _loadInitialData();
    } catch (e) {
      // If error getting primary vehicle, still load data without vehicle filter
      _loadInitialData();
    }
  }

  void _loadInitialData() {
    context.read<ReportsBloc>().add(
      LoadOverviewData(
        vehicleId: _selectedVehicleId,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabAlignment: TabAlignment.fill,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurface.withValues(alpha: 0.6),
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Fuel', icon: Icon(Icons.local_gas_station)),
            Tab(text: 'Costs', icon: Icon(Icons.attach_money)),
            Tab(text: 'Odometer', icon: Icon(Icons.speed)),
            Tab(text: 'Ownership', icon: Icon(Icons.directions_car)),
          ],
        ),
      ),
      backgroundColor: AppColors.background,
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          OverviewTab(
            vehicleId: _selectedVehicleId,
            startDate: _startDate,
            endDate: _endDate,
          ),
          FuelTab(
            vehicleId: _selectedVehicleId,
            startDate: _startDate,
            endDate: _endDate,
          ),
          CostsTab(
            vehicleId: _selectedVehicleId,
            startDate: _startDate,
            endDate: _endDate,
          ),
          OdometerTab(
            vehicleId: _selectedVehicleId,
            startDate: _startDate,
            endDate: _endDate,
          ),
          OwnershipTab(
            vehicleId: _selectedVehicleId,
            startDate: _startDate,
            endDate: _endDate,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Reports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<VehicleBloc, VehicleState>(
              builder: (context, state) {
                if (state is VehicleLoaded) {
                  return DropdownButtonFormField<String?>(
                    initialValue: _selectedVehicleId,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Vehicles'),
                      ),
                      ...state.vehicles.map((vehicle) {
                        return DropdownMenuItem<String?>(
                          value: vehicle.id,
                          child: Text(
                            '${vehicle.make} ${vehicle.model} (${vehicle.year})',
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedVehicleId = value;
                      });
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectStartDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            _startDate != null
                                ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                : 'Start Date',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: _selectEndDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            _endDate != null
                                ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                : 'End Date',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _applyFilters();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: _endDate ?? DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  void _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      // Update the selected vehicle and date range
    });

    // Reload all data with new filters
    context.read<ReportsBloc>().add(
      RefreshReportsData(
        vehicleId: _selectedVehicleId,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
  }

  void _refreshData() {
    context.read<ReportsBloc>().add(
      RefreshReportsData(
        vehicleId: _selectedVehicleId,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
  }
}
