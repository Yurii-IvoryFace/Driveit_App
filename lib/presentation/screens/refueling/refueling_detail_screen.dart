import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../bloc/refueling/refueling_bloc.dart';
import '../../bloc/refueling/refueling_event.dart';
import '../../bloc/refueling/refueling_state.dart';
import 'refueling_form_screen.dart';

class RefuelingDetailScreen extends StatefulWidget {
  final String entryId;

  const RefuelingDetailScreen({super.key, required this.entryId});

  @override
  State<RefuelingDetailScreen> createState() => _RefuelingDetailScreenState();
}

class _RefuelingDetailScreenState extends State<RefuelingDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RefuelingBloc>().add(LoadRefuelingEntryDetail(widget.entryId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refueling Details'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editRefuelingEntry,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteRefuelingEntry,
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

          if (state is RefuelingEntryDetailLoaded) {
            return _buildRefuelingDetail(context, state.entry);
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
            onPressed: () {
              context.read<RefuelingBloc>().add(
                LoadRefuelingEntryDetail(widget.entryId),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildRefuelingDetail(BuildContext context, entry) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(context, entry),
          const SizedBox(height: 16),
          _buildDetailsCard(context, entry),
          const SizedBox(height: 16),
          _buildFuelInfoCard(context, entry),
          if (entry.gasStation != null || entry.notes != null) ...[
            const SizedBox(height: 16),
            _buildAdditionalInfoCard(context, entry),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, entry) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_gas_station,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.volumeLiters.toStringAsFixed(1)} ${entry.fuelType.unit}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        entry.fuelType.displayName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${entry.totalAmount.toStringAsFixed(0)} ₴',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${entry.pricePerLiter.toStringAsFixed(2)} ₴/${entry.fuelType.unit}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildInfoChip(
                  context,
                  'Date',
                  '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                  Icons.calendar_today,
                ),
                const SizedBox(width: 16),
                _buildInfoChip(
                  context,
                  'Odometer',
                  '${entry.odometerKm} km',
                  Icons.speed,
                ),
                if (entry.isFullTank) ...[
                  const SizedBox(width: 16),
                  _buildInfoChip(
                    context,
                    'Full Tank',
                    'Yes',
                    Icons.check_circle,
                    color: AppColors.success,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, entry) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Refueling Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              'Volume',
              '${entry.volumeLiters.toStringAsFixed(2)} ${entry.fuelType.unit}',
            ),
            _buildDetailRow(
              context,
              'Price per ${entry.fuelType.unit}',
              '${entry.pricePerLiter.toStringAsFixed(2)} ₴',
            ),
            _buildDetailRow(
              context,
              'Total Amount',
              '${entry.totalAmount.toStringAsFixed(2)} ₴',
            ),
            _buildDetailRow(
              context,
              'Odometer Reading',
              '${entry.odometerKm} km',
            ),
            _buildDetailRow(context, 'Fuel Type', entry.fuelType.displayName),
            _buildDetailRow(
              context,
              'Full Tank',
              entry.isFullTank ? 'Yes' : 'No',
            ),
            _buildDetailRow(
              context,
              'Date',
              '${entry.date.day}/${entry.date.month}/${entry.date.year}',
            ),
            _buildDetailRow(
              context,
              'Time',
              '${entry.date.hour.toString().padLeft(2, '0')}:${entry.date.minute.toString().padLeft(2, '0')}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelInfoCard(BuildContext context, entry) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fuel Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Volume',
                    '${entry.volumeLiters.toStringAsFixed(1)} ${entry.fuelType.unit}',
                    Icons.local_gas_station,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Price',
                    '${entry.pricePerLiter.toStringAsFixed(2)} ₴/${entry.fuelType.unit}',
                    Icons.attach_money,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total',
                    '${entry.totalAmount.toStringAsFixed(0)} ₴',
                    Icons.receipt,
                    AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Odometer',
                    '${entry.odometerKm} km',
                    Icons.speed,
                    AppColors.info,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoCard(BuildContext context, entry) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (entry.gasStation != null)
              _buildDetailRow(context, 'Gas Station', entry.gasStation!),
            if (entry.notes != null) ...[
              const SizedBox(height: 12),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry.notes!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color ?? AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editRefuelingEntry() {
    // TODO: Get entry from state and pass to form
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RefuelingFormScreen()),
    );
  }

  void _deleteRefuelingEntry() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Refueling Entry'),
        content: const Text(
          'Are you sure you want to delete this refueling entry?',
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
              context.read<RefuelingBloc>().add(
                DeleteRefuelingEntry(widget.entryId),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
