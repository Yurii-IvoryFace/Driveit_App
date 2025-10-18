import 'package:driveit_app/features/refueling/domain/refueling_entry.dart';
import 'package:driveit_app/features/refueling/domain/refueling_repository.dart';
import 'package:driveit_app/features/reports/presentation/tabs/tab_components.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_repository.dart';
import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OdometerTab extends StatelessWidget {
  const OdometerTab({
    super.key,
    required this.selectedVehicleId,
    required this.onVehicleChanged,
    required this.onOpenVehicleDetails,
  });

  final String? selectedVehicleId;
  final ValueChanged<String?> onVehicleChanged;
  final ValueChanged<Vehicle> onOpenVehicleDetails;

  @override
  Widget build(BuildContext context) {
    final vehicleRepo = context.watch<VehicleRepository>();
    return StreamBuilder<List<Vehicle>>(
      stream: vehicleRepo.watchVehicles(),
      builder: (context, snapshot) {
        final vehicles = snapshot.data ?? const <Vehicle>[];
        if (vehicles.isEmpty) {
          return const ReportsPlaceholder(
            icon: Icons.route_outlined,
            title: 'Log your mileage',
            message:
                'Add a vehicle and capture odometer readings with each refueling to monitor driving trends.',
          );
        }

        final selected = resolveVehicleSelection(
          vehicles: vehicles,
          selectedVehicleId: selectedVehicleId,
          onVehicleChanged: onVehicleChanged,
        );
        if (selected == null) {
          return const SizedBox.shrink();
        }

        final refuelingRepo = context.watch<RefuelingRepository>();
        return StreamBuilder<List<RefuelingEntry>>(
          stream: refuelingRepo.watchByVehicle(selected.id),
          builder: (context, snapshot) {
            final entries = [...(snapshot.data ?? const <RefuelingEntry>[])];
            entries.sort((a, b) => b.date.compareTo(a.date));

            final metrics = _buildOdometerMetrics(entries, selected);
            final latestEntries = entries.take(7).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
                VehicleSelectorRow(
                  vehicles: vehicles,
                  selected: selected,
                  onVehicleChanged: onVehicleChanged,
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: () => onVehicleChanged(selected.id),
                        icon: const Icon(Icons.refresh_outlined),
                        label: const Text('Refresh'),
                      ),
                      FilledButton.icon(
                        onPressed: () => onOpenVehicleDetails(selected),
                        icon: const Icon(Icons.directions_car_outlined),
                        label: const Text('View vehicle'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ReportMetricGrid(metrics: metrics),
                const SizedBox(height: 24),
                _OdometerTimeline(entries: latestEntries),
                const SizedBox(height: 24),
                _ServiceScheduleCard(vehicle: selected),
              ],
            );
          },
        );
      },
    );
  }

  List<ReportMetric> _buildOdometerMetrics(
    List<RefuelingEntry> entries,
    Vehicle vehicle,
  ) {
    final number = NumberFormat.decimalPattern();
    final now = DateTime.now();
    final currentReading = entries.isNotEmpty
        ? entries.first.odometerKm
        : (vehicle.odometerKm?.toDouble() ?? 0);
    final lastEntry = entries.isNotEmpty ? entries.first : null;
    final daysSinceLast = lastEntry != null
        ? now.difference(lastEntry.date).inDays
        : null;

    double distanceBetweenFillUps = 0;
    var segments = 0;
    for (var i = 0; i < entries.length - 1; i++) {
      final diff = entries[i].odometerKm - entries[i + 1].odometerKm;
      if (diff > 0) {
        distanceBetweenFillUps += diff;
        segments++;
      }
    }
    final averageDistance = segments > 0
        ? distanceBetweenFillUps / segments
        : 0.0;

    final cutoff = now.subtract(const Duration(days: 30));
    final recentEntries = entries
        .where((entry) => !entry.date.isBefore(cutoff))
        .toList();
    final distanceLast30Days = recentEntries.length >= 2
        ? recentEntries.first.odometerKm - recentEntries.last.odometerKm
        : 0.0;

    final projectedAnnual = distanceLast30Days <= 0
        ? 0.0
        : distanceLast30Days * 12.0;

    return [
      ReportMetric(
        icon: Icons.speed_outlined,
        title: 'Current odometer',
        value: '${number.format(currentReading.round())} km',
        caption: lastEntry != null
            ? 'Captured ${DateFormat('MMM d, yyyy').format(lastEntry.date)}'
            : 'No odometer entries logged yet',
      ),
      ReportMetric(
        icon: Icons.calendar_view_week_outlined,
        title: 'Last 30 days',
        value: '${number.format(distanceLast30Days.round())} km',
        caption: distanceLast30Days > 0
            ? 'Based on recent refueling logs'
            : 'Log fill-ups to track monthly mileage',
      ),
      ReportMetric(
        icon: Icons.timeline_outlined,
        title: 'Avg distance per fill-up',
        value: '${number.format(averageDistance.round())} km',
        caption: segments > 0
            ? '$segments segments analysed'
            : 'Need at least two odometer readings',
      ),
      ReportMetric(
        icon: Icons.event_busy_outlined,
        title: 'Time since last reading',
        value: daysSinceLast == null
            ? 'No data'
            : daysSinceLast == 0
            ? 'Recorded today'
            : '${daysSinceLast.abs()} day${daysSinceLast == 1 ? '' : 's'}',
        caption: daysSinceLast == null
            ? 'Add a refueling to capture odometer readings'
            : 'Compared to ${DateFormat('MMM d, yyyy').format(lastEntry!.date)}',
      ),
      ReportMetric(
        icon: Icons.route_outlined,
        title: 'Projected yearly distance',
        value: '${number.format(projectedAnnual.round())} km',
        caption: 'Scaled from the last 30 days of driving',
      ),
    ];
  }
}

class _OdometerTimeline extends StatelessWidget {
  const _OdometerTimeline({required this.entries});

  final List<RefuelingEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'Add a refueling to capture the first odometer snapshot.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final number = NumberFormat.decimalPattern();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent odometer snapshots',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM').format(entry.date),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        DateFormat('d').format(entry.date),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                title: Text(
                  '${number.format(entry.odometerKm.round())} km',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${entry.volumeLiters.toStringAsFixed(1)} L \u2022 ${entry.station ?? 'Unknown station'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Text(
                  entry.fuelType.label,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceScheduleCard extends StatelessWidget {
  const _ServiceScheduleCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = [
      _MaintenanceTask(
        title: 'Next service',
        icon: Icons.build_circle_outlined,
        date: vehicle.nextService,
        type: _MaintenanceTaskType.due,
      ),
      _MaintenanceTask(
        title: 'Last service',
        icon: Icons.history_toggle_off_outlined,
        date: vehicle.lastService,
        type: _MaintenanceTaskType.completed,
      ),
      _MaintenanceTask(
        title: 'Insurance expiry',
        icon: Icons.policy_outlined,
        date: vehicle.insuranceExpiry,
        type: _MaintenanceTaskType.due,
      ),
      _MaintenanceTask(
        title: 'Registration expiry',
        icon: Icons.badge_outlined,
        date: vehicle.registrationExpiry,
        type: _MaintenanceTaskType.due,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service & compliance',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...rows.map((task) {
            final status = _evaluateMaintenanceStatus(task);
            final statusLabel = _describeMaintenanceStatus(status, task);
            final statusColor = _maintenanceStatusColor(status);
            final dateLabel = task.date != null
                ? DateFormat('MMM d, yyyy').format(task.date!)
                : 'Not scheduled';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(task.icon, color: statusColor),
                title: Text(task.title, style: theme.textTheme.titleMedium),
                subtitle: Text(
                  dateLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Text(
                  statusLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MaintenanceTask {
  const _MaintenanceTask({
    required this.title,
    required this.icon,
    this.date,
    required this.type,
  });

  final String title;
  final IconData icon;
  final DateTime? date;
  final _MaintenanceTaskType type;
}

enum _MaintenanceTaskType { due, completed }

enum _MaintenanceStatus { overdue, dueSoon, onTrack, completed, missing }

_MaintenanceStatus _evaluateMaintenanceStatus(_MaintenanceTask task) {
  if (task.type == _MaintenanceTaskType.completed) {
    return task.date == null
        ? _MaintenanceStatus.missing
        : _MaintenanceStatus.completed;
  }
  if (task.date == null) return _MaintenanceStatus.missing;

  final today = DateTime.now();
  final comparisonDate = DateTime(today.year, today.month, today.day);
  final delta = task.date!.difference(comparisonDate).inDays;

  if (delta < 0) return _MaintenanceStatus.overdue;
  if (delta <= 30) return _MaintenanceStatus.dueSoon;
  return _MaintenanceStatus.onTrack;
}

String _describeMaintenanceStatus(
  _MaintenanceStatus status,
  _MaintenanceTask task,
) {
  switch (status) {
    case _MaintenanceStatus.onTrack:
      final days = task.date!.difference(DateTime.now()).inDays;
      return days == 0
          ? 'Due today'
          : 'Due in $days day${days == 1 ? '' : 's'}';
    case _MaintenanceStatus.dueSoon:
      final days = task.date!.difference(DateTime.now()).inDays;
      return days == 0
          ? 'Due today'
          : 'Due in $days day${days == 1 ? '' : 's'}';
    case _MaintenanceStatus.overdue:
      final days = DateTime.now().difference(task.date!).inDays;
      return 'Overdue ${days}d';
    case _MaintenanceStatus.completed:
      return 'Completed';
    case _MaintenanceStatus.missing:
      return 'Not scheduled';
  }
}

Color _maintenanceStatusColor(_MaintenanceStatus status) {
  switch (status) {
    case _MaintenanceStatus.overdue:
      return AppColors.danger;
    case _MaintenanceStatus.dueSoon:
      return AppColors.accent;
    case _MaintenanceStatus.onTrack:
      return AppColors.primary;
    case _MaintenanceStatus.completed:
      return AppColors.textSecondary;
    case _MaintenanceStatus.missing:
      return AppColors.textSecondary;
  }
}
