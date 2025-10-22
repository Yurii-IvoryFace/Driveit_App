import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/transaction_usecases.dart';
import '../../../domain/usecases/vehicle_usecases.dart' as vehicle_usecases;
import '../../../domain/entities/transaction.dart';
import '../../../core/utils/logger.dart';
import '../../../core/di/injection_container.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions _getTransactions;
  final GetTransactionsByVehicle _getTransactionsByVehicle;
  final GetTransactionsByType _getTransactionsByType;
  final GetTransactionsByDateRange _getTransactionsByDateRange;
  final GetTransactionsWithFilters _getTransactionsWithFilters;
  final AddTransaction _addTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;
  final GetTransaction _getTransaction;
  final GetTransactionStatistics _getTransactionStatistics;
  final GetRecentTransactions _getRecentTransactions;
  final GetTransactionsByOdometerRange _getTransactionsByOdometerRange;

  TransactionBloc({
    required GetTransactions getTransactions,
    required GetTransactionsByVehicle getTransactionsByVehicle,
    required GetTransactionsByType getTransactionsByType,
    required GetTransactionsByDateRange getTransactionsByDateRange,
    required GetTransactionsWithFilters getTransactionsWithFilters,
    required AddTransaction addTransaction,
    required UpdateTransaction updateTransaction,
    required DeleteTransaction deleteTransaction,
    required GetTransaction getTransaction,
    required GetTransactionStatistics getTransactionStatistics,
    required GetRecentTransactions getRecentTransactions,
    required GetTransactionsByOdometerRange getTransactionsByOdometerRange,
  }) : _getTransactions = getTransactions,
       _getTransactionsByVehicle = getTransactionsByVehicle,
       _getTransactionsByType = getTransactionsByType,
       _getTransactionsByDateRange = getTransactionsByDateRange,
       _getTransactionsWithFilters = getTransactionsWithFilters,
       _addTransaction = addTransaction,
       _updateTransaction = updateTransaction,
       _deleteTransaction = deleteTransaction,
       _getTransaction = getTransaction,
       _getTransactionStatistics = getTransactionStatistics,
       _getRecentTransactions = getRecentTransactions,
       _getTransactionsByOdometerRange = getTransactionsByOdometerRange,
       super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadTransactionsByVehicle>(_onLoadTransactionsByVehicle);
    on<LoadTransactionsByType>(_onLoadTransactionsByType);
    on<LoadTransactionsByDateRange>(_onLoadTransactionsByDateRange);
    on<LoadTransactionsWithFilters>(_onLoadTransactionsWithFilters);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<LoadTransactionEvent>(_onLoadTransaction);
    on<LoadTransactionStatisticsEvent>(_onLoadTransactionStatistics);
    on<LoadRecentTransactionsEvent>(_onLoadRecentTransactions);
    on<LoadTransactionsByOdometerRangeEvent>(
      _onLoadTransactionsByOdometerRange,
    );
    on<RefreshTransactions>(_onRefreshTransactions);
    on<ClearTransactionFilters>(_onClearTransactionFilters);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    Logger.logBlocEvent(
      'TransactionBloc',
      'LoadTransactions',
      data: 'Current state: ${state.runtimeType}',
    );

    // Don't show loading if we already have data
    if (state is! TransactionLoaded) {
      emit(TransactionLoading());
      Logger.logBlocState('TransactionBloc', 'TransactionLoading');
    }
    try {
      final transactions = await _getTransactions();
      if (transactions.isEmpty) {
        emit(TransactionEmpty());
        Logger.logBlocState('TransactionBloc', 'TransactionEmpty');
      } else {
        emit(TransactionLoaded(transactions: transactions));
        Logger.logBlocState(
          'TransactionBloc',
          'TransactionLoaded',
          data: 'Loaded ${transactions.length} transactions',
        );
      }
    } catch (e) {
      emit(TransactionError(message: e.toString()));
      Logger.logBlocState(
        'TransactionBloc',
        'TransactionError',
        data: e.toString(),
      );
    }
  }

  Future<void> _onLoadTransactionsByVehicle(
    LoadTransactionsByVehicle event,
    Emitter<TransactionState> emit,
  ) async {
    // Don't show loading if we already have data
    if (state is! TransactionLoaded) {
      emit(TransactionLoading());
    }
    try {
      final transactions = await _getTransactionsByVehicle(event.vehicleId);
      if (transactions.isEmpty) {
        emit(
          TransactionEmpty(message: 'No transactions found for this vehicle'),
        );
      } else {
        emit(TransactionLoaded(transactions: transactions));
      }
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onLoadTransactionsByType(
    LoadTransactionsByType event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await _getTransactionsByType(event.type);
      if (transactions.isEmpty) {
        emit(
          TransactionEmpty(message: 'No ${event.type.name} transactions found'),
        );
      } else {
        emit(TransactionLoaded(transactions: transactions));
      }
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onLoadTransactionsByDateRange(
    LoadTransactionsByDateRange event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await _getTransactionsByDateRange(
        event.startDate,
        event.endDate,
      );
      if (transactions.isEmpty) {
        emit(
          TransactionEmpty(message: 'No transactions found in this date range'),
        );
      } else {
        emit(TransactionLoaded(transactions: transactions));
      }
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onLoadTransactionsWithFilters(
    LoadTransactionsWithFilters event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await _getTransactionsWithFilters(
        vehicleId: event.vehicleId,
        type: event.type,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      if (transactions.isEmpty) {
        emit(
          TransactionEmpty(
            message: 'No transactions found with current filters',
          ),
        );
      } else {
        emit(
          TransactionFiltered(
            transactions: transactions,
            vehicleId: event.vehicleId,
            type: event.type,
            startDate: event.startDate,
            endDate: event.endDate,
          ),
        );
      }
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionOperationInProgress(operation: 'Adding transaction'));
    try {
      await _addTransaction(event.transaction);

      // Sync vehicle odometer if transaction has odometer reading
      await _syncVehicleOdometer(event.transaction);

      emit(
        TransactionOperationSuccess(
          operation: 'Add',
          message: 'Transaction added successfully',
          transaction: event.transaction,
        ),
      );
    } catch (e) {
      emit(TransactionError(message: e.toString(), operation: 'Add'));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(
      TransactionOperationInProgress(
        operation: 'Updating transaction',
        transactionId: event.transaction.id,
      ),
    );
    try {
      await _updateTransaction(event.transaction);

      // Sync vehicle odometer if transaction has odometer reading
      await _syncVehicleOdometer(event.transaction);

      emit(
        TransactionOperationSuccess(
          operation: 'Update',
          message: 'Transaction updated successfully',
          transaction: event.transaction,
        ),
      );
    } catch (e) {
      emit(TransactionError(message: e.toString(), operation: 'Update'));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(
      TransactionOperationInProgress(
        operation: 'Deleting transaction',
        transactionId: event.transactionId,
      ),
    );
    try {
      await _deleteTransaction(event.transactionId);
      emit(
        TransactionOperationSuccess(
          operation: 'Delete',
          message: 'Transaction deleted successfully',
        ),
      );
    } catch (e) {
      emit(TransactionError(message: e.toString(), operation: 'Delete'));
    }
  }

  Future<void> _onLoadTransaction(
    LoadTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transaction = await _getTransaction(event.transactionId);
      if (transaction == null) {
        emit(TransactionError(message: 'Transaction not found'));
      } else {
        emit(TransactionDetailLoaded(transaction));
      }
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onLoadTransactionStatistics(
    LoadTransactionStatisticsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final statistics = await _getTransactionStatistics(
        vehicleId: event.vehicleId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(TransactionStatisticsLoaded(statistics));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onLoadRecentTransactions(
    LoadRecentTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await _getRecentTransactions(limit: event.limit);
      emit(RecentTransactionsLoaded(transactions));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onLoadTransactionsByOdometerRange(
    LoadTransactionsByOdometerRangeEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await _getTransactionsByOdometerRange(
        vehicleId: event.vehicleId,
        minOdometer: event.minOdometer,
        maxOdometer: event.maxOdometer,
      );
      if (transactions.isEmpty) {
        emit(
          TransactionEmpty(
            message: 'No transactions found in this odometer range',
          ),
        );
      } else {
        emit(TransactionLoaded(transactions: transactions));
      }
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onRefreshTransactions(
    RefreshTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    add(LoadTransactions());
  }

  Future<void> _onClearTransactionFilters(
    ClearTransactionFilters event,
    Emitter<TransactionState> emit,
  ) async {
    add(LoadTransactions());
  }

  Future<void> _syncVehicleOdometer(Transaction transaction) async {
    if (transaction.odometerKm != null) {
      try {
        // Get all transactions for this vehicle to find max odometer
        final vehicleTransactions = await _getTransactionsByVehicle(
          transaction.vehicleId,
        );
        final maxOdometer = vehicleTransactions
            .where((t) => t.odometerKm != null)
            .map((t) => t.odometerKm!)
            .fold<int>(0, (max, km) => km > max ? km : max);

        if (maxOdometer > 0) {
          final updateVehicleOdometer =
              getIt<vehicle_usecases.UpdateVehicleOdometer>();
          await updateVehicleOdometer(transaction.vehicleId, maxOdometer);
        }
      } catch (e) {
        // Log error but don't fail the transaction operation
        Logger.log('Failed to sync vehicle odometer', error: e);
      }
    }
  }
}
