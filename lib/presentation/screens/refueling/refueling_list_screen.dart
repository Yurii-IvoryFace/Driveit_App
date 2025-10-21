import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/refueling_entry.dart';
import '../../../domain/entities/fuel_type.dart';
import '../../bloc/refueling/refueling_bloc.dart';
import '../../bloc/refueling/refueling_event.dart';
import '../../bloc/refueling/refueling_state.dart';
import '../../bloc/vehicle/vehicle_bloc.dart';
import '../../bloc/vehicle/vehicle_state.dart';
import 'refueling_form_screen.dart';
import 'refueling_detail_screen.dart';

class RefuelingListScreen extends StatefulWidget {
  final String? vehicleId;

  const RefuelingListScreen({super.key, this.vehicleId});

  @override
  State<RefuelingListScreen> createState() => _RefuelingListScreenState();
}

class _RefuelingListScreenState extends State<RefuelingListScreen> {
  String? _selectedVehicleId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedVehicleId = widget.vehicleId;
    _loadRefuelingEntries();
  }

  void _loadRefuelingEntries() {
    if (_selectedVehicleId != null) {
      context.read<RefuelingBloc>().add(
        LoadRefuelingEntriesByVehicle(_selectedVehicleId!),
      );
    } else {
      context.read<RefuelingBloc>().add(LoadRefuelingEntries());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vehicleId != null
              ? 'Vehicle Refueling'
              : 'All Refueling Entries',
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addRefuelingEntry,
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: BlocBuilder<RefuelingBloc, RefuelingState>(
        builder: (context, state) {
          if (state is RefuelingLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is RefuelingError) {
            return _buildErrorState(context, state.message);
          }

          if (state is RefuelingEmpty) {
            return _buildEmptyState(context, state.message);
          }

          if (state is RefuelingEntriesLoaded ||
              state is RefuelingEntriesFiltered) {
            final entries = state is RefuelingEntriesLoaded
                ? state.entries
                : (state as RefuelingEntriesFiltered).entries;

            return _buildRefuelingList(context, entries);
          }

          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.danger),
          const SizedBox(height: 16),
          Text(
            'Error: $message',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRefuelingEntries,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_gas_station, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addRefuelingEntry,
            icon: const Icon(Icons.add),
            label: const Text('Add First Refueling'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefuelingList(
    BuildContext context,
    List<RefuelingEntry> entries,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadRefuelingEntries();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _buildRefuelingCard(context, entry);
        },
      ),
    );
  }

  Widget _buildRefuelingCard(BuildContext context, RefuelingEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            Icons.local_gas_station,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          '${entry.volumeLiters.toStringAsFixed(1)} ${entry.fuelType.unit} • ${entry.fuelType.displayName}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${entry.date.day}/${entry.date.month}/${entry.date.year}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            if (entry.gasStation != null) ...[
              const SizedBox(height: 2),
              Text(
                entry.gasStation!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${entry.odometerKm} km',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 16),
                if (entry.isFullTank)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Full Tank',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.totalAmount.toStringAsFixed(0)} ₴',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${entry.pricePerLiter.toStringAsFixed(2)} ₴/${entry.fuelType.unit}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RefuelingDetailScreen(entryId: entry.id),
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Refueling Entries'),
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
      lastDate: DateTime.now(),
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
    if (_selectedVehicleId != null && _startDate != null && _endDate != null) {
      context.read<RefuelingBloc>().add(
        LoadRefuelingEntriesByDateRange(
          vehicleId: _selectedVehicleId!,
          startDate: _startDate!,
          endDate: _endDate!,
        ),
      );
    } else if (_selectedVehicleId != null) {
      context.read<RefuelingBloc>().add(
        LoadRefuelingEntriesByVehicle(_selectedVehicleId!),
      );
    } else {
      context.read<RefuelingBloc>().add(LoadRefuelingEntries());
    }
  }

  void _addRefuelingEntry() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            RefuelingFormScreen(vehicleId: _selectedVehicleId),
      ),
    );
  }
}
