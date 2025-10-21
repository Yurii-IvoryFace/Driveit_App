import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../../main.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/home/home_state.dart';
import '../../bloc/vehicle/vehicle_bloc.dart';
import '../../bloc/vehicle/vehicle_event.dart';
import '../../bloc/vehicle/vehicle_state.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../bloc/transaction/transaction_event.dart';
import '../../bloc/transaction/transaction_state.dart';
import '../../bloc/reports/reports_bloc.dart';
import '../../bloc/reports/reports_event.dart';
import '../../bloc/reports/reports_state.dart';
import '../../widgets/shell/app_drawer.dart';
import '../../widgets/shell/bottom_nav_bar.dart';
import 'keep_alive_page.dart';
import '../home/home_screen.dart';
import '../vehicles/vehicles_list_screen.dart';
import '../transactions/transactions_list_screen.dart';
import '../reports/reports_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Load home data when shell initializes
    context.read<HomeBloc>().add(LoadHomeData());

    // Set up navigation observer callback
    appNavigatorObserver.onReturnToTabScreen = _onReturnToTabScreen;

    // Initialize pages with KeepAlive to maintain state
    _pages = [
      KeepAlivePage(
        key: const ValueKey('home'),
        keyValue: 'home',
        child: const HomeScreen(),
      ),
      KeepAlivePage(
        key: const ValueKey('vehicles'),
        keyValue: 'vehicles',
        child: const VehiclesListScreen(),
      ),
      KeepAlivePage(
        key: const ValueKey('transactions'),
        keyValue: 'transactions',
        child: const TransactionsListScreen(),
      ),
      KeepAlivePage(
        key: const ValueKey('reports'),
        keyValue: 'reports',
        child: const ReportsScreen(),
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Clear the callback to prevent memory leaks
    appNavigatorObserver.onReturnToTabScreen = null;
    super.dispose();
  }

  void _onReturnToTabScreen() {
    Logger.logNavigation('RETURN_TO_TAB_SCREEN', 'Current tab: $_currentIndex');
    // Refresh data for the current tab if needed
    _reloadTabDataIfNeeded(_currentIndex);
  }

  void _onTabTapped(int index) {
    Logger.logNavigation('TAB_TAPPED', 'Index: $index');
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Only reload data if we don't have data for the selected tab
    _reloadTabDataIfNeeded(index);
  }

  void _reloadTabDataIfNeeded(int index) {
    Logger.logNavigation('RELOAD_TAB_DATA_IF_NEEDED', 'Tab: $index');

    switch (index) {
      case 0: // Home
        final homeState = context.read<HomeBloc>().state;
        if (homeState is! HomeLoaded) {
          Logger.logNavigation(
            'RELOAD_TAB_DATA_IF_NEEDED',
            'Reloading home data',
          );
          context.read<HomeBloc>().add(LoadHomeData());
        } else {
          Logger.logNavigation(
            'RELOAD_TAB_DATA_IF_NEEDED',
            'Home data already loaded',
          );
        }
        break;
      case 1: // Vehicles
        final vehicleState = context.read<VehicleBloc>().state;
        if (vehicleState is! VehicleLoaded) {
          Logger.logNavigation(
            'RELOAD_TAB_DATA_IF_NEEDED',
            'Reloading vehicles data',
          );
          context.read<VehicleBloc>().add(LoadVehicles());
        } else {
          Logger.logNavigation(
            'RELOAD_TAB_DATA_IF_NEEDED',
            'Vehicles data already loaded - ${vehicleState.vehicles.length} vehicles',
          );
        }
        break;
      case 2: // Transactions
        final transactionState = context.read<TransactionBloc>().state;
        if (transactionState is! TransactionLoaded &&
            transactionState is! TransactionFiltered) {
          Logger.logNavigation(
            'RELOAD_TAB_DATA_IF_NEEDED',
            'Reloading transactions data',
          );
          context.read<TransactionBloc>().add(LoadTransactions());
        } else {
          final count = transactionState is TransactionLoaded
              ? transactionState.transactions.length
              : (transactionState as TransactionFiltered).transactions.length;
          Logger.logNavigation(
            'RELOAD_TAB_DATA_IF_NEEDED',
            'Transactions data already loaded - $count transactions',
          );
        }
        break;
      case 3: // Reports
        final reportsState = context.read<ReportsBloc>().state;
        if (reportsState is! AllReportsDataLoaded &&
            reportsState is! OverviewDataLoaded &&
            reportsState is! FuelDataLoaded &&
            reportsState is! CostsDataLoaded) {
          Logger.logNavigation(
            'RELOAD_TAB_DATA_IF_NEEDED',
            'Reloading reports data',
          );
          context.read<ReportsBloc>().add(RefreshReportsData());
        } else {
          Logger.logNavigation(
            'RELOAD_TAB_DATA_IF_NEEDED',
            'Reports data already loaded',
          );
        }
        break;
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
