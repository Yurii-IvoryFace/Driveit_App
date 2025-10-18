import 'dart:async';

import 'package:driveit_app/features/expenses/domain/expense.dart';
import 'package:driveit_app/features/expenses/domain/expense_repository.dart';
import 'package:uuid/uuid.dart';

class InMemoryExpenseRepository implements ExpenseRepository {
  InMemoryExpenseRepository({List<Expense>? seed})
    : _expenses = List<Expense>.from(seed ?? const []) {
    _controller = StreamController<List<Expense>>.broadcast(onListen: _emit);
    _emit();
  }

  final _uuid = const Uuid();
  List<Expense> _expenses;
  late final StreamController<List<Expense>> _controller;

  @override
  Stream<List<Expense>> watchByVehicle(String vehicleId) {
    return _controller.stream.map(
      (items) => _filterByVehicle(items, vehicleId),
    );
  }

  @override
  Future<List<Expense>> fetchByVehicle(String vehicleId) async {
    return _filterByVehicle(_expenses, vehicleId);
  }

  @override
  Future<void> saveExpense(Expense expense) async {
    final index = _expenses.indexWhere((item) => item.id == expense.id);
    if (index == -1) {
      final newExpense = expense.id.isEmpty
          ? expense.copyWith(id: _uuid.v4())
          : expense;
      _expenses = [..._expenses, newExpense];
    } else {
      _expenses = [
        ..._expenses.sublist(0, index),
        expense,
        ..._expenses.sublist(index + 1),
      ];
    }
    _emit();
  }

  @override
  Future<void> deleteExpense(String id) async {
    _expenses = _expenses.where((item) => item.id != id).toList();
    _emit();
  }

  void dispose() {
    _controller.close();
  }

  void _emit() {
    if (!_controller.hasListener) return;
    _controller.add(List.unmodifiable(_expenses));
  }

  List<Expense> _filterByVehicle(List<Expense> source, String vehicleId) {
    final filtered =
        source.where((item) => item.vehicleId == vehicleId).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }
}
