import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/home/home_state.dart';
import '../../bloc/vehicle/vehicle_bloc.dart';
import '../../bloc/vehicle/vehicle_event.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../bloc/transaction/transaction_state.dart';
import '../../widgets/home/hero_banner.dart';
import '../../widgets/home/stats_slider.dart';
import '../../widgets/home/timeline_card.dart';
import '../../widgets/home/quick_action_menu.dart';
import '../vehicles/vehicles_list_screen.dart';
import '../transactions/transaction_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load vehicles first, then home data
    context.read<VehicleBloc>().add(LoadVehicles());
    context.read<HomeBloc>().add(LoadHomeData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('DriveIt'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HomeBloc>().add(RefreshHomeData());
            },
          ),
        ],
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionOperationSuccess) {
            // Automatically refresh home data when transaction is added/updated
            context.read<HomeBloc>().add(RefreshHomeData());
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is HomeError) {
              return _buildErrorState(context, state.message);
            }

            if (state is HomeNoPrimaryVehicle) {
              return _buildNoPrimaryVehicleState(context, state);
            }

            if (state is HomeLoaded) {
              return _buildHomeContent(context, state);
            }

            if (state is HomeRefreshing) {
              return _buildHomeContent(context, state);
            }

            return _buildWelcomeState(context);
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.danger),
          const SizedBox(height: 16),
          Text(
            'Error: $message',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<HomeBloc>().add(LoadHomeData());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPrimaryVehicleState(
    BuildContext context,
    HomeNoPrimaryVehicle state,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(RefreshHomeData());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Icon(Icons.directions_car, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Welcome to DriveIt',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first vehicle to get started',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const VehiclesListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Vehicle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            if (state.recentTransactions.isNotEmpty) ...[
              const SizedBox(height: 32),
              TimelineCard(recentTransactions: state.recentTransactions),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, dynamic state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(RefreshHomeData());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            if (state.primaryVehicle != null) ...[
              HeroBanner(
                vehicle: state.primaryVehicle!,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const VehiclesListScreen(),
                    ),
                  );
                },
              ),
              StatsSlider(
                vehicle: state.primaryVehicle!,
                vehicleStats: state.vehicleStats,
              ),
            ],
            TimelineCard(recentTransactions: state.recentTransactions),
            QuickActionMenu(
              onAddTransaction: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TransactionFormScreen(),
                  ),
                );
              },
              onAddRefueling: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TransactionFormScreen(),
                  ),
                );
              },
              onAddMaintenance: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TransactionFormScreen(),
                  ),
                );
              },
              onAddExpense: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TransactionFormScreen(),
                  ),
                );
              },
              onViewReports: () {
                // TODO: Navigate to reports screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reports coming soon')),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Welcome to DriveIt',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your car management app',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
