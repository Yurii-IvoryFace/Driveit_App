import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/shell/app_shell.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/vehicles/vehicles_list_screen.dart';
import '../../presentation/screens/vehicles/vehicle_detail_screen.dart';
import '../../presentation/screens/vehicles/vehicle_form_screen.dart';
import '../../presentation/screens/vehicles/vehicle_photo_album_screen.dart';
import '../../presentation/screens/vehicles/vehicle_stat_form_screen.dart';
import '../../presentation/screens/transactions/transactions_list_screen.dart';
import '../../presentation/screens/transactions/transaction_form_screen.dart';
import '../../presentation/screens/transactions/transaction_detail_screen.dart';
import '../../presentation/screens/refueling/refueling_list_screen.dart';
import '../../presentation/screens/refueling/refueling_form_screen.dart';
import '../../presentation/screens/refueling/refueling_detail_screen.dart';
import '../../presentation/screens/reports/reports_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String vehicles = '/vehicles';
  static const String vehicleDetail = '/vehicles/:id';
  static const String vehicleForm = '/vehicles/form';
  static const String vehicleEdit = '/vehicles/:id/edit';
  static const String vehiclePhotos = '/vehicles/:id/photos';
  static const String vehicleStats = '/vehicles/:id/stats';
  static const String transactions = '/transactions';
  static const String transactionForm = '/transactions/form';
  static const String transactionEdit = '/transactions/:id/edit';
  static const String transactionDetail = '/transactions/:id';
  static const String refueling = '/refueling';
  static const String refuelingForm = '/refueling/form';
  static const String refuelingEdit = '/refueling/:id/edit';
  static const String refuelingDetail = '/refueling/:id';
  static const String reports = '/reports';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return const AppShell();
        },
        routes: [
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: vehicles,
            name: 'vehicles',
            builder: (context, state) => const VehiclesListScreen(),
          ),
          GoRoute(
            path: vehicleDetail,
            name: 'vehicleDetail',
            builder: (context, state) {
              final vehicleId = state.pathParameters['id']!;
              return VehicleDetailScreen(vehicleId: vehicleId);
            },
          ),
          GoRoute(
            path: vehicleForm,
            name: 'vehicleForm',
            builder: (context, state) => const VehicleFormScreen(),
          ),
          GoRoute(
            path: vehicleEdit,
            name: 'vehicleEdit',
            builder: (context, state) {
              return VehicleFormScreen();
            },
          ),
          GoRoute(
            path: vehiclePhotos,
            name: 'vehiclePhotos',
            builder: (context, state) {
              final vehicleId = state.pathParameters['id']!;
              return VehiclePhotoAlbumScreen(vehicleId: vehicleId);
            },
          ),
          GoRoute(
            path: vehicleStats,
            name: 'vehicleStats',
            builder: (context, state) {
              final vehicleId = state.pathParameters['id']!;
              return VehicleStatFormScreen(vehicleId: vehicleId);
            },
          ),
          GoRoute(
            path: transactions,
            name: 'transactions',
            builder: (context, state) => const TransactionsListScreen(),
          ),
          GoRoute(
            path: transactionForm,
            name: 'transactionForm',
            builder: (context, state) => const TransactionFormScreen(),
          ),
          GoRoute(
            path: transactionEdit,
            name: 'transactionEdit',
            builder: (context, state) {
              return TransactionFormScreen();
            },
          ),
          GoRoute(
            path: transactionDetail,
            name: 'transactionDetail',
            builder: (context, state) {
              final transactionId = state.pathParameters['id']!;
              return TransactionDetailScreen(transactionId: transactionId);
            },
          ),
          GoRoute(
            path: refueling,
            name: 'refueling',
            builder: (context, state) => const RefuelingListScreen(),
          ),
          GoRoute(
            path: refuelingForm,
            name: 'refuelingForm',
            builder: (context, state) => const RefuelingFormScreen(),
          ),
          GoRoute(
            path: refuelingEdit,
            name: 'refuelingEdit',
            builder: (context, state) {
              return RefuelingFormScreen();
            },
          ),
          GoRoute(
            path: refuelingDetail,
            name: 'refuelingDetail',
            builder: (context, state) {
              final refuelingId = state.pathParameters['id']!;
              return RefuelingDetailScreen(entryId: refuelingId);
            },
          ),
          GoRoute(
            path: reports,
            name: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: settings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
