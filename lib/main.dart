import 'package:driveit_app/app/app.dart';
import 'package:driveit_app/core/config/app_config.dart';
import 'package:driveit_app/features/expenses/data/in_memory_expense_repository.dart';
import 'package:driveit_app/features/expenses/domain/expense.dart';
import 'package:driveit_app/features/expenses/domain/expense_repository.dart';
import 'package:driveit_app/features/refueling/data/in_memory_refueling_data_source.dart';
import 'package:driveit_app/features/refueling/data/refueling_repository_impl.dart';
import 'package:driveit_app/features/refueling/domain/refueling_repository.dart';
import 'package:driveit_app/features/vehicles/data/http_vehicle_data_source.dart';
import 'package:driveit_app/features/vehicles/data/in_memory_vehicle_data_source.dart';
import 'package:driveit_app/features/vehicles/data/vehicle_repository_impl.dart';
import 'package:driveit_app/features/vehicles/data/vehicle_local_data_source.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

void main() {
  const config = AppConfig(
    apiBaseUrl: 'http://localhost:8080',
    useInMemoryStorage: true,
  );

  late final VehicleLocalDataSource vehicleDataSource;
  late final RefuelingRepository refuelingRepository;
  late final ExpenseRepository expenseRepository;

  if (config.useInMemoryStorage) {
    final inMemoryVehicleSource = InMemoryVehicleDataSource();
    vehicleDataSource = inMemoryVehicleSource;
    final seeds = inMemoryVehicleSource.currentSnapshot
        .map(
          (dto) => (
            id: dto.id,
            odometerKm: (dto.odometerKm ?? 0).toDouble(),
            fuelType: (dto.fuelType ?? 'other').toLowerCase(),
          ),
        )
        .toList();
    refuelingRepository = RefuelingRepositoryImpl(
      InMemoryRefuelingDataSource(vehicleSeeds: seeds),
    );
    expenseRepository = InMemoryExpenseRepository(
      seed: _buildSampleExpenses(seeds),
    );
  } else {
    vehicleDataSource = HttpVehicleDataSource(
      client: http.Client(),
      baseUrl: config.apiBaseUrl,
    );
    refuelingRepository = RefuelingRepositoryImpl(
      InMemoryRefuelingDataSource(),
    );
    expenseRepository = InMemoryExpenseRepository();
  }

  final VehicleRepository vehicleRepository = VehicleRepositoryImpl(
    vehicleDataSource,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: config),
        Provider<VehicleRepository>.value(value: vehicleRepository),
        Provider<RefuelingRepository>.value(value: refuelingRepository),
        Provider<ExpenseRepository>.value(value: expenseRepository),
      ],
      child: const DriveItApp(),
    ),
  );
}

List<Expense> _buildSampleExpenses(
  List<({String id, double odometerKm, String fuelType})> seeds,
) {
  final now = DateTime.now();
  final expenses = <Expense>[];
  for (var i = 0; i < seeds.length; i++) {
    final seed = seeds[i];
    expenses.addAll([
      Expense(
        id: '${seed.id}-insurance',
        vehicleId: seed.id,
        amount: 420.0 + i * 35,
        category: ExpenseCategory.insurance,
        date: now.subtract(Duration(days: 18 + i * 28)),
        description: 'Insurance premium payment',
      ),
      Expense(
        id: '${seed.id}-maintenance',
        vehicleId: seed.id,
        amount: 185.0 + i * 20,
        category: ExpenseCategory.maintenance,
        date: now.subtract(Duration(days: 42 + i * 35)),
        description: 'Workshop maintenance visit',
      ),
      Expense(
        id: '${seed.id}-parking',
        vehicleId: seed.id,
        amount: 48.5 + i * 8,
        category: ExpenseCategory.parking,
        date: now.subtract(Duration(days: 7 + i * 10)),
        description: 'Monthly parking subscription',
      ),
    ]);
  }
  return expenses;
}
