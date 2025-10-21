import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/home/home_state.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavigationSection(context),
                const Divider(color: AppColors.border),
                _buildQuickActionsSection(context),
                const Divider(color: AppColors.border),
                _buildSettingsSection(context),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.onPrimary.withValues(
                          alpha: 0.2,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DriveIt',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: AppColors.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'Vehicle Management',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.onPrimary.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (state is HomeLoaded && state.primaryVehicle != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.onPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.onPrimary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_car,
                            color: AppColors.onPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${state.primaryVehicle!.make} ${state.primaryVehicle!.model}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.onPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.onPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.onPrimary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: AppColors.onPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add your first vehicle',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationSection(BuildContext context) {
    return Column(
      children: [
        _buildDrawerItem(
          context,
          icon: Icons.dashboard,
          title: 'Dashboard',
          onTap: () {
            Navigator.pop(context);
            // Navigate to home
          },
        ),
        _buildDrawerItem(
          context,
          icon: Icons.directions_car,
          title: 'Vehicles',
          onTap: () {
            Navigator.pop(context);
            // Navigate to vehicles
          },
        ),
        _buildDrawerItem(
          context,
          icon: Icons.receipt_long,
          title: 'Transactions',
          onTap: () {
            Navigator.pop(context);
            // Navigate to transactions
          },
        ),
        _buildDrawerItem(
          context,
          icon: Icons.local_gas_station,
          title: 'Refueling',
          onTap: () {
            Navigator.pop(context);
            // Navigate to refueling
          },
        ),
        _buildDrawerItem(
          context,
          icon: Icons.analytics,
          title: 'Reports',
          onTap: () {
            Navigator.pop(context);
            // Navigate to reports
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.add,
          title: 'Add Transaction',
          onTap: () {
            Navigator.pop(context);
            // Navigate to add transaction
          },
        ),
        _buildDrawerItem(
          context,
          icon: Icons.local_gas_station,
          title: 'Add Refueling',
          onTap: () {
            Navigator.pop(context);
            // Navigate to add refueling
          },
        ),
        _buildDrawerItem(
          context,
          icon: Icons.camera_alt,
          title: 'Add Photo',
          onTap: () {
            Navigator.pop(context);
            // Navigate to add photo
          },
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Settings',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.settings,
          title: 'Preferences',
          onTap: () {
            Navigator.pop(context);
            // Navigate to settings
          },
        ),
        _buildDrawerItem(
          context,
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () {
            Navigator.pop(context);
            // Navigate to help
          },
        ),
        _buildDrawerItem(
          context,
          icon: Icons.info_outline,
          title: 'About',
          onTap: () {
            Navigator.pop(context);
            // Navigate to about
          },
        ),
      ],
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.onSurface,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: isSelected ? AppColors.primary : AppColors.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Icon(Icons.sync, color: AppColors.textSecondary, size: 16),
          const SizedBox(width: 8),
          Text(
            'Last sync: ${_getLastSyncTime()}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              // Trigger sync
              context.read<HomeBloc>().add(RefreshHomeData());
            },
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  String _getLastSyncTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
