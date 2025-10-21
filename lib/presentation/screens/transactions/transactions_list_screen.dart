import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/vehicle.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../bloc/transaction/transaction_event.dart';
import '../../bloc/transaction/transaction_state.dart';
import '../../bloc/vehicle/vehicle_bloc.dart';
import '../../bloc/vehicle/vehicle_state.dart';
import 'transaction_form_screen.dart';
import 'transaction_detail_screen.dart';

class TransactionsListScreen extends StatefulWidget {
  final String? vehicleId;

  const TransactionsListScreen({super.key, this.vehicleId});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen>
    with WidgetsBindingObserver {
  TransactionType? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedVehicleId;

  @override
  void initState() {
    super.initState();
    Logger.logNavigation('INIT', 'TransactionsListScreen');
    WidgetsBinding.instance.addObserver(this);
    _selectedVehicleId = widget.vehicleId;
    _loadTransactions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      // Reload transactions when app resumes
      _loadTransactions();
    }
  }

  void _loadTransactions() {
    if (_selectedVehicleId != null) {
      context.read<TransactionBloc>().add(
        LoadTransactionsByVehicle(_selectedVehicleId!),
      );
    } else {
      context.read<TransactionBloc>().add(LoadTransactions());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vehicleId != null
              ? 'Vehicle Transactions'
              : 'All Transactions',
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Logger.logNavigation('MANUAL_REFRESH', 'TransactionsListScreen');
              _loadTransactions();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_hasActiveFilters()) _buildFilterChips(),
          Expanded(
            child: BlocListener<TransactionBloc, TransactionState>(
              listener: (context, state) {
                // Handle state changes if needed
              },
              child: BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TransactionLoaded) {
                    return _buildTransactionsList(state.transactions);
                  } else if (state is TransactionFiltered) {
                    return _buildTransactionsList(state.transactions);
                  } else if (state is TransactionEmpty) {
                    return _buildEmptyState(state.message);
                  } else if (state is TransactionError) {
                    return _buildErrorState(state.message);
                  } else {
                    return const Center(child: Text('No transactions'));
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "transaction_add_button",
        onPressed: _addTransaction,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedType != null)
            Chip(
              label: Text(_selectedType!.displayName),
              onDeleted: () {
                setState(() {
                  _selectedType = null;
                });
                _applyFilters();
              },
            ),
          if (_startDate != null)
            Chip(
              label: Text('From: ${_formatDate(_startDate!)}'),
              onDeleted: () {
                setState(() {
                  _startDate = null;
                });
                _applyFilters();
              },
            ),
          if (_endDate != null)
            Chip(
              label: Text('To: ${_formatDate(_endDate!)}'),
              onDeleted: () {
                setState(() {
                  _endDate = null;
                });
                _applyFilters();
              },
            ),
          if (_selectedVehicleId != null)
            Chip(
              label: Text(_getVehicleName(_selectedVehicleId!)),
              onDeleted: () {
                setState(() {
                  _selectedVehicleId = null;
                });
                _applyFilters();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return _buildEmptyState('No transactions found');
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: AppColors.surface,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTypeColor(transaction.type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTypeIcon(transaction.type),
            color: _getTypeColor(transaction.type),
            size: 20,
          ),
        ),
        title: Text(
          transaction.type.displayName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getVehicleName(transaction.vehicleId),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            Text(
              _formatDate(transaction.date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (transaction.amount != null)
              Text(
                '${transaction.amount!.toStringAsFixed(2)} ${transaction.currency}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (transaction.odometerKm != null)
              Text(
                '${transaction.odometerKm} km',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
        onTap: () {
          Logger.logNavigation(
            'NAVIGATE_TO_DETAIL',
            'TransactionDetailScreen',
            data: 'Transaction ID: ${transaction.id}',
          );
          _viewTransaction(transaction);
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: AppColors.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addTransaction,
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
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
            ).textTheme.titleLarge?.copyWith(color: AppColors.onSurface),
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
            onPressed: _loadTransactions,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: BlocBuilder<VehicleBloc, VehicleState>(
          builder: (context, vehicleState) {
            List<Vehicle> vehicles = [];
            if (vehicleState is VehicleLoaded) {
              vehicles = vehicleState.vehicles;
            }

            return StatefulBuilder(
              builder: (context, setDialogState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<TransactionType?>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Transaction Type',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<TransactionType?>(
                          value: null,
                          child: Text('All Types'),
                        ),
                        ...TransactionType.values.map((type) {
                          return DropdownMenuItem<TransactionType?>(
                            value: type,
                            child: Text(type.displayName),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          _selectedType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
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
                        ...vehicles.map((vehicle) {
                          return DropdownMenuItem<String?>(
                            value: vehicle.id,
                            child: Text(
                              '${vehicle.make} ${vehicle.model} (${vehicle.year})',
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          _selectedVehicleId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _startDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setDialogState(() {
                                  _startDate = date;
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
                                  Icon(
                                    Icons.calendar_today,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _startDate != null
                                        ? _formatDate(_startDate!)
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
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _endDate ?? DateTime.now(),
                                firstDate: _startDate ?? DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setDialogState(() {
                                  _endDate = date;
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
                                  Icon(
                                    Icons.calendar_today,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _endDate != null
                                        ? _formatDate(_endDate!)
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
                );
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
                _selectedVehicleId = null;
                _startDate = null;
                _endDate = null;
              });
              Navigator.of(context).pop();
              _applyFilters();
            },
            child: const Text('Clear'),
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

  void _applyFilters() {
    context.read<TransactionBloc>().add(
      LoadTransactionsWithFilters(
        vehicleId: _selectedVehicleId,
        type: _selectedType,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
  }

  void _addTransaction() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            TransactionFormScreen(vehicleId: _selectedVehicleId),
      ),
    );
  }

  void _viewTransaction(Transaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            TransactionDetailScreen(transactionId: transaction.id),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedType != null ||
        _selectedVehicleId != null ||
        _startDate != null ||
        _endDate != null;
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
      return '${vehicle.make} ${vehicle.model}';
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
}
