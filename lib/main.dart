import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart';
import 'core/navigation/app_router.dart';
import 'domain/usecases/vehicle_usecases.dart' as vehicle_usecases;
import 'domain/usecases/transaction_usecases.dart' as transaction_usecases;
import 'domain/usecases/refueling_usecases.dart' as refueling_usecases;
import 'presentation/bloc/vehicle/vehicle_bloc.dart';
import 'presentation/bloc/transaction/transaction_bloc.dart';
import 'presentation/bloc/home/home_bloc.dart';
import 'presentation/bloc/refueling/refueling_bloc.dart';
import 'presentation/bloc/reports/reports_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await configureDependencies();

  runApp(const DriveItApp());
}

class DriveItApp extends StatelessWidget {
  const DriveItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VehicleBloc>(
          create: (context) => VehicleBloc(
            // Vehicle CRUD use cases
            getVehicles: vehicle_usecases.GetVehicles(getIt()),
            saveVehicle: vehicle_usecases.SaveVehicle(getIt()),
            deleteVehicle: vehicle_usecases.DeleteVehicle(getIt()),
            setPrimaryVehicle: vehicle_usecases.SetPrimaryVehicle(getIt()),
            getPrimaryVehicle: vehicle_usecases.GetPrimaryVehicle(getIt()),
            watchVehiclesWithStats: vehicle_usecases.WatchVehiclesWithStats(
              getIt(),
            ),
            getVehicleWithPhotos: vehicle_usecases.GetVehicleWithPhotos(
              getIt(),
            ),
            getVehicleWithDocuments: vehicle_usecases.GetVehicleWithDocuments(
              getIt(),
            ),

            // Vehicle Stats use cases
            addVehicleStat: vehicle_usecases.AddVehicleStat(getIt()),
            updateVehicleStat: vehicle_usecases.UpdateVehicleStat(getIt()),
            deleteVehicleStat: vehicle_usecases.DeleteVehicleStat(getIt()),
            getVehicleStats: vehicle_usecases.GetVehicleStats(getIt()),
            watchVehicleStats: vehicle_usecases.WatchVehicleStats(getIt()),

            // Vehicle Photos use cases
            addVehiclePhoto: vehicle_usecases.AddVehiclePhoto(getIt()),
            updateVehiclePhoto: vehicle_usecases.UpdateVehiclePhoto(getIt()),
            deleteVehiclePhoto: vehicle_usecases.DeleteVehiclePhoto(getIt()),
            getVehiclePhotos: vehicle_usecases.GetVehiclePhotos(getIt()),
            watchVehiclePhotos: vehicle_usecases.WatchVehiclePhotos(getIt()),

            // Vehicle Documents use cases
            addVehicleDocument: vehicle_usecases.AddVehicleDocument(getIt()),
            updateVehicleDocument: vehicle_usecases.UpdateVehicleDocument(
              getIt(),
            ),
            deleteVehicleDocument: vehicle_usecases.DeleteVehicleDocument(
              getIt(),
            ),
            getVehicleDocuments: vehicle_usecases.GetVehicleDocuments(getIt()),
            watchVehicleDocuments: vehicle_usecases.WatchVehicleDocuments(
              getIt(),
            ),
          ),
        ),
        BlocProvider<TransactionBloc>(
          create: (context) => TransactionBloc(
            getTransactions: transaction_usecases.GetTransactions(getIt()),
            getTransactionsByVehicle:
                transaction_usecases.GetTransactionsByVehicle(getIt()),
            getTransactionsByType: transaction_usecases.GetTransactionsByType(
              getIt(),
            ),
            getTransactionsByDateRange:
                transaction_usecases.GetTransactionsByDateRange(getIt()),
            getTransactionsWithFilters:
                transaction_usecases.GetTransactionsWithFilters(getIt()),
            addTransaction: transaction_usecases.AddTransaction(getIt()),
            updateTransaction: transaction_usecases.UpdateTransaction(getIt()),
            deleteTransaction: transaction_usecases.DeleteTransaction(getIt()),
            getTransaction: transaction_usecases.GetTransaction(getIt()),
            getTransactionStatistics:
                transaction_usecases.GetTransactionStatistics(getIt()),
            getRecentTransactions: transaction_usecases.GetRecentTransactions(
              getIt(),
            ),
            getTransactionsByOdometerRange:
                transaction_usecases.GetTransactionsByOdometerRange(getIt()),
          ),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(
            getPrimaryVehicle: vehicle_usecases.GetPrimaryVehicle(getIt()),
            getRecentTransactions: transaction_usecases.GetRecentTransactions(
              getIt(),
            ),
            getTransactionStatistics:
                transaction_usecases.GetTransactionStatistics(getIt()),
            getTransactionsByType: transaction_usecases.GetTransactionsByType(
              getIt(),
            ),
          ),
        ),
        BlocProvider<RefuelingBloc>(
          create: (context) => RefuelingBloc(
            getRefuelingEntries: refueling_usecases.GetRefuelingEntries(
              getIt(),
            ),
            getRefuelingEntriesByVehicle:
                refueling_usecases.GetRefuelingEntriesByVehicle(getIt()),
            getRefuelingEntriesByDateRange:
                refueling_usecases.GetRefuelingEntriesByDateRange(getIt()),
            getRecentRefuelingEntries:
                refueling_usecases.GetRecentRefuelingEntries(getIt()),
            addRefuelingEntry: refueling_usecases.AddRefuelingEntry(getIt()),
            updateRefuelingEntry: refueling_usecases.UpdateRefuelingEntry(
              getIt(),
            ),
            deleteRefuelingEntry: refueling_usecases.DeleteRefuelingEntry(
              getIt(),
            ),
            getRefuelingEntry: refueling_usecases.GetRefuelingEntry(getIt()),
            getRefuelingSummary: refueling_usecases.GetRefuelingSummary(
              getIt(),
            ),
            getRefuelingStatistics: refueling_usecases.GetRefuelingStatistics(
              getIt(),
            ),
            calculateFuelEfficiency: refueling_usecases.CalculateFuelEfficiency(
              getIt(),
            ),
          ),
        ),
        BlocProvider<ReportsBloc>(
          create: (context) => ReportsBloc(
            getTransactions: transaction_usecases.GetTransactions(getIt()),
            getTransactionsByVehicle:
                transaction_usecases.GetTransactionsByVehicle(getIt()),
            getTransactionsByDateRange:
                transaction_usecases.GetTransactionsByDateRange(getIt()),
            getTransactionStatistics:
                transaction_usecases.GetTransactionStatistics(getIt()),
            getRefuelingEntries: refueling_usecases.GetRefuelingEntries(
              getIt(),
            ),
            getRefuelingEntriesByVehicle:
                refueling_usecases.GetRefuelingEntriesByVehicle(getIt()),
            getRefuelingEntriesByDateRange:
                refueling_usecases.GetRefuelingEntriesByDateRange(getIt()),
            getRefuelingStatistics: refueling_usecases.GetRefuelingStatistics(
              getIt(),
            ),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'DriveIt',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
