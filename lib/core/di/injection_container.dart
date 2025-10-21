import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/local/app_database.dart';
import '../../data/repositories/vehicle_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/repositories/attachment_repository_impl.dart';
import '../../data/repositories/refueling_repository_impl.dart';
import '../../domain/entities/vehicle.dart' as domain;
import '../../domain/repositories/vehicle_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/attachment_repository.dart';
import '../../domain/repositories/refueling_repository.dart';
import '../../domain/usecases/vehicle_usecases.dart' as vehicle_usecases;
import '../../domain/usecases/transaction_usecases.dart'
    as transaction_usecases;
import '../../domain/usecases/attachment_usecases.dart' as attachment_usecases;
import '../../domain/usecases/refueling_usecases.dart' as refueling_usecases;

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Core dependencies
  getIt.registerLazySingleton<Uuid>(() => const Uuid());

  // Database
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Repositories
  getIt.registerLazySingleton<VehicleRepository>(
    () => VehicleRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<AttachmentRepository>(
    () => AttachmentRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<RefuelingRepository>(
    () => RefuelingRepositoryImpl(getIt<AppDatabase>()),
  );

  // Vehicle Use Cases
  getIt.registerLazySingleton<vehicle_usecases.GetVehicles>(
    () => vehicle_usecases.GetVehicles(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.GetVehicle>(
    () => vehicle_usecases.GetVehicle(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.SaveVehicle>(
    () => vehicle_usecases.SaveVehicle(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.DeleteVehicle>(
    () => vehicle_usecases.DeleteVehicle(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.WatchVehicles>(
    () => vehicle_usecases.WatchVehicles(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.SetPrimaryVehicle>(
    () => vehicle_usecases.SetPrimaryVehicle(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.GetPrimaryVehicle>(
    () => vehicle_usecases.GetPrimaryVehicle(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.WatchVehiclesWithStats>(
    () => vehicle_usecases.WatchVehiclesWithStats(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.GetVehicleWithPhotos>(
    () => vehicle_usecases.GetVehicleWithPhotos(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.GetVehicleWithDocuments>(
    () => vehicle_usecases.GetVehicleWithDocuments(getIt<VehicleRepository>()),
  );

  // Vehicle Stats Use Cases
  getIt.registerLazySingleton<vehicle_usecases.AddVehicleStat>(
    () => vehicle_usecases.AddVehicleStat(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.UpdateVehicleStat>(
    () => vehicle_usecases.UpdateVehicleStat(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.DeleteVehicleStat>(
    () => vehicle_usecases.DeleteVehicleStat(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.GetVehicleStats>(
    () => vehicle_usecases.GetVehicleStats(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.WatchVehicleStats>(
    () => vehicle_usecases.WatchVehicleStats(getIt<VehicleRepository>()),
  );

  // Vehicle Photos Use Cases
  getIt.registerLazySingleton<vehicle_usecases.AddVehiclePhoto>(
    () => vehicle_usecases.AddVehiclePhoto(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.UpdateVehiclePhoto>(
    () => vehicle_usecases.UpdateVehiclePhoto(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.DeleteVehiclePhoto>(
    () => vehicle_usecases.DeleteVehiclePhoto(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.GetVehiclePhotos>(
    () => vehicle_usecases.GetVehiclePhotos(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.WatchVehiclePhotos>(
    () => vehicle_usecases.WatchVehiclePhotos(getIt<VehicleRepository>()),
  );

  // Vehicle Documents Use Cases
  getIt.registerLazySingleton<vehicle_usecases.AddVehicleDocument>(
    () => vehicle_usecases.AddVehicleDocument(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.UpdateVehicleDocument>(
    () => vehicle_usecases.UpdateVehicleDocument(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.DeleteVehicleDocument>(
    () => vehicle_usecases.DeleteVehicleDocument(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.GetVehicleDocuments>(
    () => vehicle_usecases.GetVehicleDocuments(getIt<VehicleRepository>()),
  );
  getIt.registerLazySingleton<vehicle_usecases.WatchVehicleDocuments>(
    () => vehicle_usecases.WatchVehicleDocuments(getIt<VehicleRepository>()),
  );

  // Transaction Use Cases
  getIt.registerLazySingleton<transaction_usecases.GetTransactions>(
    () => transaction_usecases.GetTransactions(getIt<TransactionRepository>()),
  );
  getIt.registerLazySingleton<transaction_usecases.WatchTransactions>(
    () =>
        transaction_usecases.WatchTransactions(getIt<TransactionRepository>()),
  );
  getIt.registerLazySingleton<transaction_usecases.GetTransactionsByVehicle>(
    () => transaction_usecases.GetTransactionsByVehicle(
      getIt<TransactionRepository>(),
    ),
  );
  getIt.registerLazySingleton<transaction_usecases.WatchTransactionsByVehicle>(
    () => transaction_usecases.WatchTransactionsByVehicle(
      getIt<TransactionRepository>(),
    ),
  );
  getIt.registerLazySingleton<transaction_usecases.GetTransactionsByType>(
    () => transaction_usecases.GetTransactionsByType(
      getIt<TransactionRepository>(),
    ),
  );
  getIt.registerLazySingleton<transaction_usecases.GetTransactionsByDateRange>(
    () => transaction_usecases.GetTransactionsByDateRange(
      getIt<TransactionRepository>(),
    ),
  );
  getIt.registerLazySingleton<transaction_usecases.GetTransactionsWithFilters>(
    () => transaction_usecases.GetTransactionsWithFilters(
      getIt<TransactionRepository>(),
    ),
  );
  getIt.registerLazySingleton<transaction_usecases.AddTransaction>(
    () => transaction_usecases.AddTransaction(getIt<TransactionRepository>()),
  );
  getIt.registerLazySingleton<transaction_usecases.UpdateTransaction>(
    () =>
        transaction_usecases.UpdateTransaction(getIt<TransactionRepository>()),
  );
  getIt.registerLazySingleton<transaction_usecases.DeleteTransaction>(
    () =>
        transaction_usecases.DeleteTransaction(getIt<TransactionRepository>()),
  );
  getIt.registerLazySingleton<transaction_usecases.GetTransaction>(
    () => transaction_usecases.GetTransaction(getIt<TransactionRepository>()),
  );
  getIt.registerLazySingleton<transaction_usecases.GetTransactionStatistics>(
    () => transaction_usecases.GetTransactionStatistics(
      getIt<TransactionRepository>(),
    ),
  );
  getIt.registerLazySingleton<transaction_usecases.GetRecentTransactions>(
    () => transaction_usecases.GetRecentTransactions(
      getIt<TransactionRepository>(),
    ),
  );
  getIt.registerLazySingleton<
    transaction_usecases.GetTransactionsByOdometerRange
  >(
    () => transaction_usecases.GetTransactionsByOdometerRange(
      getIt<TransactionRepository>(),
    ),
  );

  // Attachment Use Cases
  getIt.registerLazySingleton<attachment_usecases.GetAttachments>(
    () => attachment_usecases.GetAttachments(getIt<AttachmentRepository>()),
  );
  getIt.registerLazySingleton<attachment_usecases.GetAttachment>(
    () => attachment_usecases.GetAttachment(getIt<AttachmentRepository>()),
  );
  getIt.registerLazySingleton<attachment_usecases.SaveAttachment>(
    () => attachment_usecases.SaveAttachment(getIt<AttachmentRepository>()),
  );
  getIt.registerLazySingleton<attachment_usecases.DeleteAttachment>(
    () => attachment_usecases.DeleteAttachment(getIt<AttachmentRepository>()),
  );
  getIt.registerLazySingleton<attachment_usecases.GetAttachmentsByVehicle>(
    () => attachment_usecases.GetAttachmentsByVehicle(
      getIt<AttachmentRepository>(),
    ),
  );
  getIt.registerLazySingleton<attachment_usecases.WatchAttachmentsByVehicle>(
    () => attachment_usecases.WatchAttachmentsByVehicle(
      getIt<AttachmentRepository>(),
    ),
  );
  getIt.registerLazySingleton<attachment_usecases.GetAttachmentsByTransaction>(
    () => attachment_usecases.GetAttachmentsByTransaction(
      getIt<AttachmentRepository>(),
    ),
  );
  getIt
      .registerLazySingleton<attachment_usecases.WatchAttachmentsByTransaction>(
        () => attachment_usecases.WatchAttachmentsByTransaction(
          getIt<AttachmentRepository>(),
        ),
      );
  getIt.registerLazySingleton<attachment_usecases.GetAttachmentsByType>(
    () =>
        attachment_usecases.GetAttachmentsByType(getIt<AttachmentRepository>()),
  );
  getIt.registerLazySingleton<attachment_usecases.GetVehiclePhotos>(
    () => attachment_usecases.GetVehiclePhotos(getIt<AttachmentRepository>()),
  );
  getIt.registerLazySingleton<attachment_usecases.GetVehicleDocuments>(
    () =>
        attachment_usecases.GetVehicleDocuments(getIt<AttachmentRepository>()),
  );
  getIt.registerLazySingleton<attachment_usecases.GetTransactionAttachments>(
    () => attachment_usecases.GetTransactionAttachments(
      getIt<AttachmentRepository>(),
    ),
  );
  getIt.registerLazySingleton<attachment_usecases.GetAttachmentStats>(
    () => attachment_usecases.GetAttachmentStats(getIt<AttachmentRepository>()),
  );
  getIt.registerLazySingleton<attachment_usecases.SearchAttachmentsByName>(
    () => attachment_usecases.SearchAttachmentsByName(
      getIt<AttachmentRepository>(),
    ),
  );
  getIt.registerLazySingleton<attachment_usecases.GetAttachmentsByMimeType>(
    () => attachment_usecases.GetAttachmentsByMimeType(
      getIt<AttachmentRepository>(),
    ),
  );
  getIt.registerLazySingleton<attachment_usecases.GetRecentAttachments>(
    () =>
        attachment_usecases.GetRecentAttachments(getIt<AttachmentRepository>()),
  );
  getIt.registerLazySingleton<attachment_usecases.DeleteAttachmentsByVehicle>(
    () => attachment_usecases.DeleteAttachmentsByVehicle(
      getIt<AttachmentRepository>(),
    ),
  );
  getIt.registerLazySingleton<
    attachment_usecases.DeleteAttachmentsByTransaction
  >(
    () => attachment_usecases.DeleteAttachmentsByTransaction(
      getIt<AttachmentRepository>(),
    ),
  );

  // Refueling Use Cases
  getIt.registerLazySingleton<refueling_usecases.GetRefuelingEntries>(
    () => refueling_usecases.GetRefuelingEntries(getIt<RefuelingRepository>()),
  );
  getIt.registerLazySingleton<refueling_usecases.WatchRefuelingEntries>(
    () =>
        refueling_usecases.WatchRefuelingEntries(getIt<RefuelingRepository>()),
  );
  getIt.registerLazySingleton<refueling_usecases.GetRefuelingEntriesByVehicle>(
    () => refueling_usecases.GetRefuelingEntriesByVehicle(
      getIt<RefuelingRepository>(),
    ),
  );
  getIt
      .registerLazySingleton<refueling_usecases.WatchRefuelingEntriesByVehicle>(
        () => refueling_usecases.WatchRefuelingEntriesByVehicle(
          getIt<RefuelingRepository>(),
        ),
      );
  getIt.registerLazySingleton<refueling_usecases.GetRefuelingEntry>(
    () => refueling_usecases.GetRefuelingEntry(getIt<RefuelingRepository>()),
  );
  getIt.registerLazySingleton<refueling_usecases.AddRefuelingEntry>(
    () => refueling_usecases.AddRefuelingEntry(getIt<RefuelingRepository>()),
  );
  getIt.registerLazySingleton<refueling_usecases.UpdateRefuelingEntry>(
    () => refueling_usecases.UpdateRefuelingEntry(getIt<RefuelingRepository>()),
  );
  getIt.registerLazySingleton<refueling_usecases.DeleteRefuelingEntry>(
    () => refueling_usecases.DeleteRefuelingEntry(getIt<RefuelingRepository>()),
  );
  getIt
      .registerLazySingleton<refueling_usecases.GetRefuelingEntriesByDateRange>(
        () => refueling_usecases.GetRefuelingEntriesByDateRange(
          getIt<RefuelingRepository>(),
        ),
      );
  getIt.registerLazySingleton<refueling_usecases.GetRecentRefuelingEntries>(
    () => refueling_usecases.GetRecentRefuelingEntries(
      getIt<RefuelingRepository>(),
    ),
  );
  getIt.registerLazySingleton<refueling_usecases.GetRefuelingSummary>(
    () => refueling_usecases.GetRefuelingSummary(getIt<RefuelingRepository>()),
  );
  getIt.registerLazySingleton<refueling_usecases.GetRefuelingStatistics>(
    () =>
        refueling_usecases.GetRefuelingStatistics(getIt<RefuelingRepository>()),
  );
  getIt.registerLazySingleton<refueling_usecases.CalculateFuelEfficiency>(
    () => refueling_usecases.CalculateFuelEfficiency(
      getIt<RefuelingRepository>(),
    ),
  );

  // Add a test vehicle for demonstration if it doesn't exist
  final vehicleRepository = getIt<VehicleRepository>();
  final existingVehicle = await vehicleRepository.getVehicle('test-vehicle-1');
  if (existingVehicle == null) {
    await vehicleRepository.saveVehicle(
      domain.Vehicle(
        id: 'test-vehicle-1',
        name: 'My Car',
        make: 'Toyota',
        model: 'Camry',
        year: 2020,
        isPrimary: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }
}
