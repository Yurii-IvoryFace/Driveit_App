import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:driveit_app/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ReportMetric {
  const ReportMetric({
    required this.icon,
    required this.title,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final String title;
  final String value;
  final String caption;
}

class ReportMetricGrid extends StatelessWidget {
  const ReportMetricGrid({super.key, required this.metrics});

  final List<ReportMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 520;
        final itemWidth = isWide
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: itemWidth,
                  child: ReportMetricCard(metric: metric),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class ReportMetricCard extends StatelessWidget {
  const ReportMetricCard({super.key, required this.metric});

  final ReportMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DriveCard(
      color: AppColors.surface,
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(metric.icon, color: AppColors.accent),
          ),
          const SizedBox(height: 16),
          Text(
            metric.title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            metric.value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            metric.caption,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class VehicleSelectorRow extends StatelessWidget {
  const VehicleSelectorRow({
    super.key,
    required this.vehicles,
    required this.selected,
    required this.onVehicleChanged,
    this.trailing,
  });

  final List<Vehicle> vehicles;
  final Vehicle selected;
  final ValueChanged<String?> onVehicleChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DriveCard(
            color: AppColors.surface,
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
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class ReportsPlaceholder extends StatelessWidget {
  const ReportsPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: DriveCard(
            color: AppColors.surface,
            borderRadius: 28,
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: AppColors.accent),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Vehicle? resolveVehicleSelection({
  required List<Vehicle> vehicles,
  required String? selectedVehicleId,
  required ValueChanged<String?> onVehicleChanged,
}) {
  if (vehicles.isEmpty) return null;

  Vehicle? resolved;
  if (selectedVehicleId != null) {
    for (final vehicle in vehicles) {
      if (vehicle.id == selectedVehicleId) {
        resolved = vehicle;
        break;
      }
    }
  }
  resolved ??= vehicles.first;

  if (resolved.id != selectedVehicleId) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => onVehicleChanged(resolved!.id),
    );
  }

  return resolved;
}
