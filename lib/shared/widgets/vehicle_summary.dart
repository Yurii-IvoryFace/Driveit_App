import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:driveit_app/shared/widgets/drive_card.dart';
import 'package:driveit_app/shared/widgets/info_chip.dart';
import 'package:driveit_app/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Read-only summary block for the currently selected vehicle.
class DriveVehicleSummary extends StatelessWidget {
  const DriveVehicleSummary({
    super.key,
    required this.vehicle,
    this.subtitle,
    this.showLicense = true,
    this.showOdometer = true,
    this.showHeader = true,
  });

  final Vehicle vehicle;
  final String? subtitle;
  final bool showLicense;
  final bool showOdometer;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedSubtitle = subtitle ?? _buildSubtitle();
    final chips = _buildInfoChips();

    final card = DriveCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.directions_car_outlined,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (resolvedSubtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    resolvedSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: chips,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (!showHeader) {
      return card;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DriveSectionHeader(title: 'Vehicle'),
        const SizedBox(height: 12),
        card,
      ],
    );
  }

  String? _buildSubtitle() {
    final parts = <String>[];
    if (vehicle.year > 0) {
      parts.add(vehicle.year.toString());
    }
    final make = vehicle.make.trim();
    final model = vehicle.model.trim();
    if (make.isNotEmpty) {
      parts.add(make);
    }
    if (model.isNotEmpty) {
      parts.add(model);
    }
    if (parts.isEmpty) return null;
    return parts.join(' • ');
  }

  List<Widget> _buildInfoChips() {
    final entries = <Widget>[];
    final license = vehicle.licensePlate?.trim();
    if (showLicense && license != null && license.isNotEmpty) {
      entries.add(
        InfoChip(icon: Icons.badge_outlined, label: 'Plate: $license'),
      );
    }
    if (showOdometer && vehicle.odometerKm != null) {
      final formatted = NumberFormat.decimalPattern().format(
        vehicle.odometerKm,
      );
      entries.add(
        InfoChip(icon: Icons.speed_outlined, label: '$formatted km'),
      );
    }
    return entries;
  }
}
