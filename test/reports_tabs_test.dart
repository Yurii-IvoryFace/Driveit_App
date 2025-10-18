import 'dart:async';

import 'package:driveit_app/features/expenses/domain/expense.dart';
import 'package:driveit_app/features/expenses/domain/expense_repository.dart';
import 'package:driveit_app/features/refueling/domain/refueling_calculator.dart';
import 'package:driveit_app/features/refueling/domain/fuel_type.dart';
import 'package:driveit_app/features/refueling/domain/refueling_summary.dart';
import 'package:driveit_app/features/refueling/domain/refueling_entry.dart';
import 'package:driveit_app/features/refueling/domain/refueling_repository.dart';
import 'package:driveit_app/features/reports/presentation/tabs/costs_tab.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

void main() {
  group('CostsTab', () {
    testWidgets('renders placeholder when no vehicles', (tester) async {
      final vehicleRepository = FakeVehicleRepository();
      final refuelingRepository = FakeRefuelingRepository();
      final expenseRepository = FakeExpenseRepository();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<VehicleRepository>.value(value: vehicleRepository),
            Provider<RefuelingRepository>.value(value: refuelingRepository),
            Provider<ExpenseRepository>.value(value: expenseRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CostsTab(
                selectedVehicleId: null,
                onVehicleChanged: _noopVehicleChanged,
                onViewFuel: _noopOnViewFuel,
                onOpenVehicleDetails: _noopOnOpenVehicle,
              ),
            ),
          ),
        ),
      );

      vehicleRepository.emit([]);
      await tester.pump();

      expect(find.text('Track your vehicle spend'), findsOneWidget);
    });

    testWidgets('combines fuel and non-fuel expenses in metrics', (
      tester,
    ) async {
      final vehicleRepository = FakeVehicleRepository();
      final refuelingRepository = FakeRefuelingRepository();
      final expenseRepository = FakeExpenseRepository();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<VehicleRepository>.value(value: vehicleRepository),
            Provider<RefuelingRepository>.value(value: refuelingRepository),
            Provider<ExpenseRepository>.value(value: expenseRepository),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CostsTab(
                selectedVehicleId: null,
                onVehicleChanged: (_) {},
                onViewFuel: _noopOnViewFuel,
                onOpenVehicleDetails: _noopOnOpenVehicle,
              ),
            ),
          ),
        ),
      );

      final vehicle = Vehicle(
        id: 'v1',
        displayName: 'Primary Car',
        make: 'Tesla',
        model: 'Model 3',
        year: 2022,
        documents: const [],
        photos: const [],
      );
      vehicleRepository.emit([vehicle]);

      final now = DateTime.now();
      refuelingRepository.emit(vehicle.id, [
        RefuelingEntry(
          id: 'r1',
          vehicleId: vehicle.id,
          date: now.subtract(const Duration(days: 5)),
          odometerKm: 20000,
          volumeLiters: 45,
          totalCost: 80,
          pricePerLiter: 1.77,
          fuelType: FuelType.petrol,
          isFullFill: true,
          station: 'Shell',
        ),
        RefuelingEntry(
          id: 'r2',
          vehicleId: vehicle.id,
          date: now.subtract(const Duration(days: 28)),
          odometerKm: 19450,
          volumeLiters: 42,
          totalCost: 75,
          pricePerLiter: 1.78,
          fuelType: FuelType.petrol,
          isFullFill: true,
          station: 'BP',
        ),
      ]);

      expenseRepository.emit(vehicle.id, [
        Expense(
          id: 'e1',
          vehicleId: vehicle.id,
          amount: 250,
          category: ExpenseCategory.maintenance,
          date: now.subtract(const Duration(days: 12)),
          description: 'Brake pads replacement',
        ),
        Expense(
          id: 'e2',
          vehicleId: vehicle.id,
          amount: 480,
          category: ExpenseCategory.insurance,
          date: now.subtract(const Duration(days: 40)),
          description: 'Annual insurance premium',
        ),
      ]);

      await tester.pump();
      await tester.pumpAndSettle();

      final currency = NumberFormat.simpleCurrency();
      expect(find.text('Total vehicle spend'), findsOneWidget);
      expect(find.text(currency.format(80 + 75 + 250 + 480)), findsOneWidget);
      expect(find.text('Non-fuel spend'), findsOneWidget);
    });
  });
}

void _noopVehicleChanged(String? _) {}

void _noopOnViewFuel(String _) {}

void _noopOnOpenVehicle(Vehicle _) {}

class FakeVehicleRepository implements VehicleRepository {
  FakeVehicleRepository();

  final StreamController<List<Vehicle>> _controller =
      StreamController<List<Vehicle>>.broadcast();

  List<Vehicle> _vehicles = const [];

  void emit(List<Vehicle> vehicles) {
    _vehicles = vehicles;
    _controller.add(List.unmodifiable(_vehicles));
  }

  @override
  Future<List<Vehicle>> fetchVehicles() async => _vehicles;

  @override
  Stream<List<Vehicle>> watchVehicles() => _controller.stream;

  @override
  Future<void> deleteVehicle(String id) async {}

  @override
  Future<void> saveVehicle(Vehicle vehicle) async {}

  @override
  Future<void> setPrimaryVehicle(String id) async {}
}

class FakeRefuelingRepository implements RefuelingRepository {
  final Map<String, List<RefuelingEntry>> _entries = {};
  final Map<String, StreamController<List<RefuelingEntry>>> _controllers = {};

  StreamController<List<RefuelingEntry>> _controllerFor(String vehicleId) {
    if (_controllers.containsKey(vehicleId)) {
      return _controllers[vehicleId]!;
    }
    late final StreamController<List<RefuelingEntry>> controller;
    controller = StreamController<List<RefuelingEntry>>.broadcast(
      onListen: () {
        controller.add(List.unmodifiable(_entries[vehicleId] ?? const []));
      },
    );
    _controllers[vehicleId] = controller;
    return controller;
  }

  void emit(String vehicleId, List<RefuelingEntry> entries) {
    _entries[vehicleId] = entries;
    _controllerFor(vehicleId).add(List.unmodifiable(entries));
  }

  @override
  Future<void> deleteEntry(String id) async {}

  @override
  Future<List<RefuelingEntry>> fetchByVehicle(String vehicleId) async =>
      _entries[vehicleId] ?? const [];

  @override
  Future<void> saveEntry(RefuelingEntry entry) async {}

  @override
  Stream<List<RefuelingEntry>> watchByVehicle(String vehicleId) =>
      _controllerFor(vehicleId).stream;

  @override
  Stream<RefuelingSummary> watchSummary(String vehicleId) =>
      watchByVehicle(vehicleId).map(RefuelingCalculator.buildSummary);
}

class FakeExpenseRepository implements ExpenseRepository {
  final Map<String, List<Expense>> _expenses = {};
  final Map<String, StreamController<List<Expense>>> _controllers = {};

  StreamController<List<Expense>> _controllerFor(String vehicleId) {
    if (_controllers.containsKey(vehicleId)) {
      return _controllers[vehicleId]!;
    }
    late final StreamController<List<Expense>> controller;
    controller = StreamController<List<Expense>>.broadcast(
      onListen: () {
        controller.add(List.unmodifiable(_expenses[vehicleId] ?? const []));
      },
    );
    _controllers[vehicleId] = controller;
    return controller;
  }

  void emit(String vehicleId, List<Expense> expenses) {
    _expenses[vehicleId] = expenses;
    _controllerFor(vehicleId).add(List.unmodifiable(expenses));
  }

  @override
  Future<void> deleteExpense(String id) async {}

  @override
  Future<List<Expense>> fetchByVehicle(String vehicleId) async =>
      _expenses[vehicleId] ?? const [];

  @override
  Future<void> saveExpense(Expense expense) async {}

  @override
  Stream<List<Expense>> watchByVehicle(String vehicleId) =>
      _controllerFor(vehicleId).stream;
}
