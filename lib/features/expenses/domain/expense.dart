import 'package:equatable/equatable.dart';

enum ExpenseCategory {
  maintenance('Maintenance'),
  insurance('Insurance'),
  parking('Parking'),
  tolls('Tolls'),
  other('Other');

  const ExpenseCategory(this.label);

  final String label;

  static ExpenseCategory fromSerialized(String value) {
    return ExpenseCategory.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}

class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.vehicleId,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    this.notes,
  });

  final String id;
  final String vehicleId;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String description;
  final String? notes;

  Expense copyWith({
    String? id,
    String? vehicleId,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? description,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    amount,
    category,
    date,
    description,
    notes,
  ];
}
