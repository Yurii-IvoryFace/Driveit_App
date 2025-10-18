import 'package:driveit_app/features/expenses/domain/expense.dart';

abstract class ExpenseRepository {
  Stream<List<Expense>> watchByVehicle(String vehicleId);

  Future<List<Expense>> fetchByVehicle(String vehicleId);

  Future<void> saveExpense(Expense expense);

  Future<void> deleteExpense(String id);
}
