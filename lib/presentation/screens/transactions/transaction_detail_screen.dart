import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/vehicle.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../bloc/transaction/transaction_event.dart';
import '../../bloc/transaction/transaction_state.dart';
import '../../bloc/vehicle/vehicle_bloc.dart';
import '../../bloc/vehicle/vehicle_state.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(
      LoadTransactionEvent(widget.transactionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editTransaction),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTransaction,
          ),
        ],
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
            if (state.operation == 'Delete') {
              Navigator.of(context).pop();
            }
          } else if (state is TransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TransactionDetailLoaded) {
              return _buildTransactionDetails(state.transaction);
            } else if (state is TransactionError) {
              return _buildErrorState(state.message);
            } else {
              return const Center(child: Text('Transaction not found'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildTransactionDetails(Transaction transaction) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(transaction),
          const SizedBox(height: 16),
          _buildDetailsCard(transaction),
          const SizedBox(height: 16),
          _buildConditionalDetails(transaction),
          if (transaction.notes != null) ...[
            const SizedBox(height: 16),
            _buildNotesCard(transaction.notes!),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Transaction transaction) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getTypeColor(
                      transaction.type,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(transaction.type),
                    color: _getTypeColor(transaction.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.type.displayName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        _formatDate(transaction.date),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (transaction.amount != null)
                  Text(
                    '${transaction.amount!.toStringAsFixed(2)} ${transaction.currency}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(Transaction transaction) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Vehicle', _getVehicleName(transaction.vehicleId)),
            if (transaction.odometerKm != null)
              _buildDetailRow('Odometer', '${transaction.odometerKm} km'),
            _buildDetailRow('Date', _formatDateTime(transaction.date)),
            _buildDetailRow('Created', _formatDateTime(transaction.createdAt)),
            _buildDetailRow('Updated', _formatDateTime(transaction.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionalDetails(Transaction transaction) {
    switch (transaction.type) {
      case TransactionType.refueling:
        return _buildRefuelingDetails(transaction);
      case TransactionType.maintenance:
        return _buildMaintenanceDetails(transaction);
      case TransactionType.insurance:
      case TransactionType.parking:
      case TransactionType.toll:
      case TransactionType.carWash:
      case TransactionType.other:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRefuelingDetails(Transaction transaction) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            if (transaction.volumeLiters != null)
              _buildDetailRow('Volume', '${transaction.volumeLiters} L'),
            if (transaction.pricePerLiter != null)
              _buildDetailRow(
                'Price per Liter',
                '${transaction.pricePerLiter} ${transaction.currency}/L',
              ),
            if (transaction.fuelType != null)
              _buildDetailRow(
                'Fuel Type',
                _formatFuelType(transaction.fuelType!),
              ),
            _buildDetailRow(
              'Full Tank',
              transaction.isFullTank == true ? 'Yes' : 'No',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceDetails(Transaction transaction) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (transaction.serviceType != null)
              _buildDetailRow(
                'Service Type',
                _formatServiceType(transaction.serviceType!),
              ),
            if (transaction.serviceProvider != null)
              _buildDetailRow('Service Provider', transaction.serviceProvider!),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(String notes) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notes,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.danger),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<TransactionBloc>().add(
                LoadTransactionEvent(widget.transactionId),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _editTransaction() {
    // TODO: Navigate to edit form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon')),
    );
  }

  void _deleteTransaction() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TransactionBloc>().add(
                DeleteTransactionEvent(widget.transactionId),
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

  String _getVehicleName(String vehicleId) {
    final vehicleState = context.read<VehicleBloc>().state;
    if (vehicleState is VehicleLoaded) {
      final vehicle = vehicleState.vehicles.firstWhere(
        (v) => v.id == vehicleId,
        orElse: () => Vehicle(
          id: vehicleId,
          name: 'Unknown Vehicle',
          make: '',
          model: '',
          year: 0,
          isPrimary: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      return '${vehicle.make} ${vehicle.model} (${vehicle.year})';
    }
    return 'Unknown Vehicle';
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.refueling:
        return Colors.blue;
      case TransactionType.maintenance:
        return Colors.orange;
      case TransactionType.insurance:
        return Colors.green;
      case TransactionType.parking:
        return Colors.purple;
      case TransactionType.toll:
        return Colors.teal;
      case TransactionType.carWash:
        return Colors.cyan;
      case TransactionType.other:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.refueling:
        return Icons.local_gas_station;
      case TransactionType.maintenance:
        return Icons.build;
      case TransactionType.insurance:
        return Icons.security;
      case TransactionType.parking:
        return Icons.local_parking;
      case TransactionType.toll:
        return Icons.toll;
      case TransactionType.carWash:
        return Icons.wash;
      case TransactionType.other:
        return Icons.receipt;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatFuelType(String fuelType) {
    switch (fuelType) {
      case 'gasoline':
        return 'Gasoline';
      case 'diesel':
        return 'Diesel';
      case 'electric':
        return 'Electric';
      case 'hybrid':
        return 'Hybrid';
      default:
        return fuelType;
    }
  }

  String _formatServiceType(String serviceType) {
    switch (serviceType) {
      case 'oil_change':
        return 'Oil Change';
      case 'brake_service':
        return 'Brake Service';
      case 'tire_rotation':
        return 'Tire Rotation';
      case 'inspection':
        return 'Inspection';
      case 'repair':
        return 'Repair';
      case 'other':
        return 'Other';
      default:
        return serviceType;
    }
  }
}
