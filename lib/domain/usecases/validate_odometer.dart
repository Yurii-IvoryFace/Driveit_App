import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Result of odometer validation
class OdometerValidationResult {
  final bool isValid;
  final String? errorMessage;
  final int? suggestedMinOdometer;
  final int? suggestedMaxOdometer;

  const OdometerValidationResult({
    required this.isValid,
    this.errorMessage,
    this.suggestedMinOdometer,
    this.suggestedMaxOdometer,
  });

  factory OdometerValidationResult.valid() {
    return const OdometerValidationResult(isValid: true);
  }

  factory OdometerValidationResult.invalid(
    String errorMessage, {
    int? suggestedMinOdometer,
    int? suggestedMaxOdometer,
  }) {
    return OdometerValidationResult(
      isValid: false,
      errorMessage: errorMessage,
      suggestedMinOdometer: suggestedMinOdometer,
      suggestedMaxOdometer: suggestedMaxOdometer,
    );
  }
}

/// Use case for validating odometer readings against existing transactions
class ValidateOdometer {
  final TransactionRepository _repository;

  ValidateOdometer(this._repository);

  /// Validates odometer reading for a transaction
  ///
  /// [vehicleId] - ID of the vehicle
  /// [transactionId] - ID of the transaction being edited (null for new transactions)
  /// [date] - Date of the transaction
  /// [odometerKm] - Odometer reading to validate
  /// [vehicleOdometerKm] - Current odometer reading of the vehicle
  Future<OdometerValidationResult> call({
    required String vehicleId,
    String? transactionId,
    required DateTime date,
    required int odometerKm,
    int? vehicleOdometerKm,
  }) async {
    try {
      // Get all transactions for the vehicle (excluding the current one if editing)
      final transactions = await _repository.getTransactionsByVehicle(
        vehicleId,
      );

      // Filter out the current transaction if editing
      final filteredTransactions = transactions
          .where((t) => t.id != transactionId)
          .toList();

      // Sort transactions by date, then by odometer reading
      filteredTransactions.sort((a, b) {
        final dateComparison = a.date.compareTo(b.date);
        if (dateComparison != 0) return dateComparison;
        return (a.odometerKm ?? 0).compareTo(b.odometerKm ?? 0);
      });

      // Find the previous and next transactions relative to the given date
      Transaction? previousTransaction;
      Transaction? nextTransaction;

      for (int i = 0; i < filteredTransactions.length; i++) {
        final transaction = filteredTransactions[i];

        if (transaction.date.isBefore(date) ||
            (transaction.date.isAtSameMomentAs(date) &&
                (transaction.odometerKm ?? 0) <= odometerKm)) {
          previousTransaction = transaction;
        }

        if (transaction.date.isAfter(date) ||
            (transaction.date.isAtSameMomentAs(date) &&
                (transaction.odometerKm ?? 0) > odometerKm)) {
          nextTransaction = transaction;
          break;
        }
      }

      // Validate against previous transaction
      if (previousTransaction != null &&
          previousTransaction.odometerKm != null) {
        if (odometerKm < previousTransaction.odometerKm!) {
          return OdometerValidationResult.invalid(
            'Пробіг не може бути менше ніж у попередньої транзакції (${previousTransaction.odometerKm} км)',
            suggestedMinOdometer: previousTransaction.odometerKm,
          );
        }
      }

      // Validate against next transaction
      if (nextTransaction != null && nextTransaction.odometerKm != null) {
        if (odometerKm > nextTransaction.odometerKm!) {
          return OdometerValidationResult.invalid(
            'Пробіг не може бути більше ніж у наступної транзакції (${nextTransaction.odometerKm} км)',
            suggestedMaxOdometer: nextTransaction.odometerKm,
          );
        }
      }

      // Validate against vehicle's current odometer (for new transactions)
      if (transactionId == null && vehicleOdometerKm != null) {
        if (odometerKm < vehicleOdometerKm) {
          return OdometerValidationResult.invalid(
            'Пробіг не може бути менше ніж поточний пробіг автомобіля ($vehicleOdometerKm км)',
            suggestedMinOdometer: vehicleOdometerKm,
          );
        }
      }

      return OdometerValidationResult.valid();
    } catch (e) {
      return OdometerValidationResult.invalid(
        'Помилка при валідації пробігу: $e',
      );
    }
  }

  /// Validates if vehicle's odometer can be updated to the given value
  ///
  /// [vehicleId] - ID of the vehicle
  /// [newOdometerKm] - New odometer reading for the vehicle
  Future<OdometerValidationResult> validateVehicleOdometer({
    required String vehicleId,
    required int newOdometerKm,
  }) async {
    try {
      // Get all transactions for the vehicle
      final transactions = await _repository.getTransactionsByVehicle(
        vehicleId,
      );

      // Find the maximum odometer reading from all transactions
      int maxTransactionOdometer = 0;
      for (final transaction in transactions) {
        if (transaction.odometerKm != null &&
            transaction.odometerKm! > maxTransactionOdometer) {
          maxTransactionOdometer = transaction.odometerKm!;
        }
      }

      // Vehicle's odometer cannot be lower than the maximum transaction odometer
      if (newOdometerKm < maxTransactionOdometer) {
        return OdometerValidationResult.invalid(
          'Пробіг автомобіля не може бути менше ніж максимальний пробіг з транзакцій ($maxTransactionOdometer км)',
          suggestedMinOdometer: maxTransactionOdometer,
        );
      }

      return OdometerValidationResult.valid();
    } catch (e) {
      return OdometerValidationResult.invalid(
        'Помилка при валідації пробігу автомобіля: $e',
      );
    }
  }
}
