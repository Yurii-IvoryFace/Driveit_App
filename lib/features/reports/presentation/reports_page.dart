import 'package:driveit_app/features/refueling/domain/refueling_repository.dart';
import 'package:driveit_app/features/refueling/domain/refueling_summary.dart';
import 'package:driveit_app/features/refueling/presentation/refueling_page.dart';
import 'package:driveit_app/features/reports/presentation/tabs/costs_tab.dart';
import 'package:driveit_app/features/reports/presentation/tabs/odometer_tab.dart';
import 'package:driveit_app/features/reports/presentation/tabs/ownership_tab.dart';
import 'package:driveit_app/features/reports/presentation/tabs/tab_components.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_repository.dart';
import 'package:driveit_app/features/vehicles/presentation/vehicle_details_page.dart';
import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:driveit_app/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum ReportsTab { overview, fuel, costs, odometer, ownership }

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key, this.initialTab = ReportsTab.overview});

  final ReportsTab initialTab;

  @override
  ReportsPageState createState() => ReportsPageState();
}

class ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  final GlobalKey<RefuelingViewState> _fuelViewKey =
      GlobalKey<RefuelingViewState>();
  String? _pendingVehicleId;
  String? _currentVehicleId;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: ReportsTab.values.length,
      vsync: this,
      initialIndex: widget.initialTab.index,
    );
  }

  void switchToTab(ReportsTab tab) {
    if (!mounted) return;
    _controller.animateTo(tab.index);
  }

  void showFuelSummary({String? vehicleId}) {
    final updatedVehicleId = vehicleId ?? _currentVehicleId;
    final shouldUpdate = updatedVehicleId != _currentVehicleId;
    if (shouldUpdate) {
      setState(() {
        _currentVehicleId = updatedVehicleId;
      });
    }
    if (vehicleId != null) {
      _pendingVehicleId = vehicleId;
    }
    switchToTab(ReportsTab.fuel);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = _pendingVehicleId;
      if (id != null) {
        _fuelViewKey.currentState?.focusVehicle(id);
        _pendingVehicleId = null;
      }
    });
  }

  void _handleVehicleChanged(String? vehicleId) {
    if (_currentVehicleId == vehicleId) return;
    setState(() {
      _currentVehicleId = vehicleId;
    });
    if (vehicleId != null && _controller.index == ReportsTab.fuel.index) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fuelViewKey.currentState?.focusVehicle(vehicleId);
      });
    }
  }

  void _openVehicleDetails(Vehicle vehicle) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VehicleDetailsPage(vehicle: vehicle)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reports',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                DriveCard(
                  color: AppColors.surfaceSecondary,
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: TabBar(
                    isScrollable: true,
                    controller: _controller,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Fuel'),
                      Tab(text: 'Costs'),
                      Tab(text: 'Odometer'),
                      Tab(text: 'Ownership'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          _ReportsOverviewTab(
            selectedVehicleId: _currentVehicleId,
            onVehicleChanged: _handleVehicleChanged,
            onViewFuel: (vehicleId) => showFuelSummary(vehicleId: vehicleId),
          ),
          RefuelingView(
            key: _fuelViewKey,
            embedded: true,
            initialVehicleId: _currentVehicleId,
          ),
          CostsTab(
            selectedVehicleId: _currentVehicleId,
            onVehicleChanged: _handleVehicleChanged,
            onViewFuel: (vehicleId) => showFuelSummary(vehicleId: vehicleId),
            onOpenVehicleDetails: _openVehicleDetails,
          ),
          OdometerTab(
            selectedVehicleId: _currentVehicleId,
            onVehicleChanged: _handleVehicleChanged,
            onOpenVehicleDetails: _openVehicleDetails,
          ),
          OwnershipTab(
            selectedVehicleId: _currentVehicleId,
            onVehicleChanged: _handleVehicleChanged,
            onOpenVehicleDetails: _openVehicleDetails,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ReportsOverviewTab extends StatelessWidget {
  const _ReportsOverviewTab({
    required this.selectedVehicleId,
    required this.onVehicleChanged,
    required this.onViewFuel,
  });

  final String? selectedVehicleId;
  final ValueChanged<String?> onVehicleChanged;
  final ValueChanged<String> onViewFuel;

  @override
  Widget build(BuildContext context) {
    final vehicleRepo = context.watch<VehicleRepository>();
    return StreamBuilder<List<Vehicle>>(
      stream: vehicleRepo.watchVehicles(),
      builder: (context, snapshot) {
        final vehicles = snapshot.data ?? const <Vehicle>[];
        if (vehicles.isEmpty) {
          return const ReportsPlaceholder(
            icon: Icons.directions_car_outlined,
            title: 'Add your first vehicle',
            message:
                'Once a vehicle is in the garage you\'ll unlock consumption, cost, and ownership analytics here.',
          );
        }

        var activeId = selectedVehicleId;
        final hasSelectedVehicle =
            activeId != null &&
            vehicles.any((vehicle) => vehicle.id == activeId);
        if (!hasSelectedVehicle) {
          activeId = vehicles.first.id;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onVehicleChanged(activeId);
          });
        }

        final selected = vehicles.firstWhere(
          (vehicle) => vehicle.id == activeId,
          orElse: () => vehicles.first,
        );

        final refuelingRepo = context.watch<RefuelingRepository>();
        return StreamBuilder<RefuelingSummary>(
          stream: refuelingRepo.watchSummary(selected.id),
          builder: (context, summarySnapshot) {
            final summary = summarySnapshot.data ?? RefuelingSummary.empty;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
                _OverviewHeader(
                  vehicles: vehicles,
                  selected: selected,
                  onVehicleChanged: onVehicleChanged,
                  onViewFuel: onViewFuel,
                ),
                const SizedBox(height: 24),
                _OverviewMetrics(summary: summary),
                const SizedBox(height: 24),
                _OverviewCallout(
                  hasData: summary.fillUps > 0,
                  onAction: () => onViewFuel(selected.id),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({
    required this.vehicles,
    required this.selected,
    required this.onVehicleChanged,
    required this.onViewFuel,
  });

  final List<Vehicle> vehicles;
  final Vehicle selected;
  final ValueChanged<String?> onVehicleChanged;
  final ValueChanged<String> onViewFuel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DriveCard(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selected.id,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onChanged: onVehicleChanged,
                    items: vehicles
                        .map(
                          (vehicle) => DropdownMenuItem(
                            value: vehicle.id,
                            child: Text(vehicle.displayName),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () => onViewFuel(selected.id),
              icon: const Icon(Icons.local_gas_station_outlined),
              label: const Text('Fuel summary'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${selected.make} ${selected.model} • ${selected.year}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _OverviewMetrics extends StatelessWidget {
  const _OverviewMetrics({required this.summary});

  final RefuelingSummary summary;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency();
    final decimal = NumberFormat('0.0');
    final distance = NumberFormat.decimalPattern();

    final metrics = [
      ReportMetric(
        icon: Icons.payments_outlined,
        title: 'Total spend',
        value: currency.format(summary.totalCost),
        caption: summary.fillUps > 0
            ? 'Across ${summary.fillUps} fill-ups in ${_formatDays(summary.timeframeDays)}'
            : 'No fill-ups logged yet',
      ),
      ReportMetric(
        icon: Icons.local_gas_station_outlined,
        title: 'Avg consumption',
        value: '${decimal.format(summary.averageConsumptionPer100km)} L/100 km',
        caption: 'Fuel efficiency based on full fill-ups',
      ),
      ReportMetric(
        icon: Icons.attach_money_outlined,
        title: 'Avg price per L',
        value: currency.format(summary.averagePricePerLiter),
        caption: 'Mean price paid across recorded fill-ups',
      ),
      ReportMetric(
        icon: Icons.route_outlined,
        title: 'Distance tracked',
        value: '${distance.format(summary.totalDistanceKm.round())} km',
        caption: 'Covered between recorded refueling stops',
      ),
    ];

    return ReportMetricGrid(metrics: metrics);
  }
}

class _OverviewCallout extends StatelessWidget {
  const _OverviewCallout({required this.hasData, required this.onAction});

  final bool hasData;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = hasData
        ? 'Explore detailed trends'
        : 'Ready for your first fill-up';
    final message = hasData
        ? 'Head to the fuel tab to drill into entries, spot anomalies, and update history.'
        : 'Log a refueling to unlock consumption and cost analytics for this vehicle.';
    final actionLabel = hasData ? 'Open fuel history' : 'Add refueling';

    return DriveCard(
      color: AppColors.surfaceSecondary,
      borderRadius: 20,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

String _formatDays(int days) {
  if (days <= 1) {
    return '1 day';
  }
  return '$days days';
}
