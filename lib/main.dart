import 'package:driveit_app/app/app.dart';
import 'package:driveit_app/core/config/app_config.dart';
import 'package:driveit_app/features/expenses/data/in_memory_expense_repository.dart';
import 'package:driveit_app/features/expenses/domain/expense.dart';
import 'package:driveit_app/features/expenses/domain/expense_repository.dart';
import 'package:driveit_app/features/events/data/in_memory_vehicle_event_repository.dart';
import 'package:driveit_app/features/events/domain/vehicle_event.dart';
import 'package:driveit_app/features/events/domain/vehicle_event_repository.dart';
import 'package:driveit_app/features/refueling/data/in_memory_refueling_data_source.dart';
import 'package:driveit_app/features/refueling/data/refueling_repository_impl.dart';
import 'package:driveit_app/features/refueling/domain/refueling_repository.dart';
import 'package:driveit_app/features/vehicles/data/http_vehicle_data_source.dart';
import 'package:driveit_app/features/vehicles/data/in_memory_vehicle_data_source.dart';
import 'package:driveit_app/features/vehicles/data/vehicle_repository_impl.dart';
import 'package:driveit_app/features/vehicles/data/vehicle_local_data_source.dart';
import 'package:driveit_app/features/vehicles/data/dto/vehicle_dto.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

void main() {
  const config = AppConfig(
    apiBaseUrl: 'http://localhost:8080',
    useInMemoryStorage: true,
  );

  late final VehicleLocalDataSource vehicleDataSource;
  late final RefuelingRepository refuelingRepository;
  late final ExpenseRepository expenseRepository;
  late final VehicleEventRepository vehicleEventRepository;

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
    vehicleEventRepository = InMemoryVehicleEventRepository(
      seed: _buildSampleVehicleEvents(inMemoryVehicleSource.currentSnapshot),
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
    vehicleEventRepository = InMemoryVehicleEventRepository();
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
        Provider<VehicleEventRepository>.value(value: vehicleEventRepository),
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

List<VehicleEvent> _buildSampleVehicleEvents(List<VehicleDto> vehicles) {
  final now = DateTime.now();
  final uuid = const Uuid();
  final events = <VehicleEvent>[];

  for (var i = 0; i < vehicles.length; i++) {
    final vehicle = vehicles[i];
    final baseOdometer = vehicle.odometerKm ?? (150000 + i * 8000);
    events.addAll([
      VehicleEvent(
        id: uuid.v4(),
        vehicleId: vehicle.id,
        type: VehicleEventType.service,
        title: 'Full inspection & fluids',
        occurredAt: now.subtract(Duration(days: 12 + i * 4)),
        location: 'MK Service Center',
        odometerKm: baseOdometer - 120,
        amount: 420.0 + i * 35,
        currency: 'PLN',
        serviceType: 'Maintenance',
        notes: 'Replaced oil, cabin filter and topped up washer fluid.',
        attachments: [
          VehicleEventAttachment(
            id: uuid.v4(),
            type: VehicleEventAttachmentType.document,
            name: 'invoice-${vehicle.id.substring(0, 4)}.pdf',
            dataUrl:
                'data:application/pdf;base64,VGhpcyBpcyBhIHNhbXBsZSBpbnZvaWNlLg==',
            sizeBytes: 2048,
          ),
        ],
      ),
      VehicleEvent(
        id: uuid.v4(),
        vehicleId: vehicle.id,
        type: VehicleEventType.refuel,
        title: 'Refuel 40L',
        occurredAt: now.subtract(Duration(days: 6 + i * 2)),
        location: 'Shell Station, Downtown',
        odometerKm: baseOdometer - 40,
        amount: 278.4 + i * 12,
        currency: 'PLN',
        notes: 'Used loyalty card, added tire pressure check reminder.',
      ),
      VehicleEvent(
        id: uuid.v4(),
        vehicleId: vehicle.id,
        type: VehicleEventType.note,
        title: 'Dashboard reminder',
        occurredAt: now.subtract(Duration(days: 3 + i)),
        location: 'Garage',
        odometerKm: baseOdometer - 18,
        notes: 'Check wiper blades before next rain.',
      ),
      VehicleEvent(
        id: uuid.v4(),
        vehicleId: vehicle.id,
        type: VehicleEventType.odometer,
        title: 'Mileage snapshot',
        occurredAt: now.subtract(Duration(hours: 12 * (i + 1))),
        location: 'Home driveway',
        odometerKm: baseOdometer,
        notes: 'Preparing for quarterly expense report.',
      ),
    ]);
  }

  events.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  return events;
}
