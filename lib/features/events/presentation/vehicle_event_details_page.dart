import 'package:driveit_app/features/events/domain/vehicle_event.dart';
import 'package:driveit_app/features/events/domain/vehicle_event_repository.dart';
import 'package:driveit_app/features/events/presentation/attachment_viewer.dart';
import 'package:driveit_app/features/events/presentation/event_visuals.dart';
import 'package:driveit_app/features/events/presentation/vehicle_event_form_page.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:driveit_app/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class VehicleEventDetailsPage extends StatefulWidget {
  const VehicleEventDetailsPage({
    super.key,
    required this.vehicle,
    required this.event,
  });

  final Vehicle vehicle;
  final VehicleEvent event;

  @override
  State<VehicleEventDetailsPage> createState() =>
      _VehicleEventDetailsPageState();
}

class _VehicleEventDetailsPageState extends State<VehicleEventDetailsPage> {
  late VehicleEvent _event;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  VehicleEventRepository get _repository =>
      context.read<VehicleEventRepository>();

  Future<void> _editEvent() async {
    final label = _labelForType(_event.type);
    final updated = await Navigator.of(context).push<VehicleEvent>(
      MaterialPageRoute(
        builder: (_) => VehicleEventFormPage(
          vehicle: widget.vehicle,
          type: _event.type,
          actionLabel: label,
          initialEvent: _event,
        ),
      ),
    );
    if (updated == null) return;
    await _repository.saveEvent(updated);
    if (!mounted) return;
    setState(() => _event = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.fixed,
        content: Text('Event updated'),
      ),
    );
  }

  Future<void> _deleteEvent() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete event'),
            content: const Text(
              'Are you sure you want to delete this event? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await _repository.deleteEvent(_event.id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final visuals = resolveEventVisual(_event.type);
    final theme = Theme.of(context);
    final amountText = _formatAmount(_event);
    final odometerText = _event.odometerKm == null
        ? null
        : '${NumberFormat.decimalPattern().format(_event.odometerKm)} km';

    return Scaffold(
      appBar: AppBar(
        title: Text(_event.title),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: _editEvent,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: _deleteEvent,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DriveCard(
                borderRadius: 22,
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: visuals.color.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(visuals.icon, color: visuals.color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _event.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _labelForType(_event.type),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatDate(_event.occurredAt),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              DriveInfoRow(
                icon: Icons.place_outlined,
                label: 'Location',
                value: _event.location?.trim().isNotEmpty == true
                    ? _event.location!.trim()
                    : 'Not specified',
                margin: const EdgeInsets.only(bottom: 16),
              ),
              if (odometerText != null)
                DriveInfoRow(
                  icon: Icons.speed_outlined,
                  label: 'Odometer',
                  value: odometerText,
                  margin: const EdgeInsets.only(bottom: 16),
                ),
              if (_event.serviceType != null &&
                  _event.serviceType!.trim().isNotEmpty)
                DriveInfoRow(
                  icon: Icons.build_outlined,
                  label: 'Service type',
                  value: _event.serviceType!,
                  margin: const EdgeInsets.only(bottom: 16),
                ),
              if (amountText != null)
                DriveInfoRow(
                  icon: Icons.payments_outlined,
                  label: 'Amount',
                  value: amountText,
                  margin: const EdgeInsets.only(bottom: 16),
                ),
              if (_event.type == VehicleEventType.refuel) ...[
                const SizedBox(height: 20),
                const DriveSectionHeader(title: 'Fuel'),
                const SizedBox(height: 12),
                _buildFuelDetailsCard(),
              ],
              if (_event.notes?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 20),
                Text(
                  'Notes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(_event.notes!.trim(), style: theme.textTheme.bodyMedium),
              ],
              if (_event.attachments.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Attachments',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                DriveAttachmentChipList(
                  attachments: _event.attachments,
                  onTap: (attachment) =>
                      showVehicleAttachment(context, attachment),
                ),
              ],
              const SizedBox(height: 28),
              const DriveSectionHeader(title: 'Driver'),
              const SizedBox(height: 12),
              const _DriverPlaceholderCard(),
            ],
          ),
        ),
      ),
    );
  }

  String _labelForType(VehicleEventType type) {
    return switch (type) {
      VehicleEventType.odometer => 'Odometer',
      VehicleEventType.note => 'Note',
      VehicleEventType.income => 'Income',
      VehicleEventType.service => 'Service',
      VehicleEventType.expense => 'Expense',
      VehicleEventType.refuel => 'Refuel',
    };
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy • HH:mm').format(date);
  }

  String? _formatAmount(VehicleEvent event) {
    final amount = event.amount;
    if (amount == null) return null;
    final currency = event.currency ?? '';
    final formatter = NumberFormat.currency(
      symbol: currency.isEmpty ? '' : '$currency ',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  String? _formatVolume(VehicleEvent event) {
    final volume = event.volumeLiters;
    if (volume == null) return null;
    final formatter = NumberFormat('0.0');
    return '${formatter.format(volume)} L';
  }

  String? _formatPricePerLiter(VehicleEvent event) {
    final price = event.pricePerLiter;
    if (price == null) return null;
    final currency = event.currency ?? '';
    final prefix = currency.isEmpty ? '' : '$currency ';
    return '$prefix${price.toStringAsFixed(2)} /L';
  }

  DriveCard _buildFuelDetailsCard() {
    final theme = Theme.of(context);
    const fallbackValue = '\u2014';
    final amountText = _formatAmount(_event) ?? fallbackValue;
    final volumeText = _formatVolume(_event) ?? fallbackValue;
    final pricePerLiterText = _formatPricePerLiter(_event) ?? fallbackValue;
    final fullTankText = _event.isFullTank == null
        ? fallbackValue
        : (_event.isFullTank! ? 'Yes' : 'No');

    return DriveCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.local_gas_station_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Fuel details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              const double spacing = 20;
              final double maxWidth = constraints.maxWidth;
              final double columnWidth = maxWidth >= 360
                  ? (maxWidth - spacing) / 2
                  : maxWidth;

              return Wrap(
                spacing: spacing,
                runSpacing: 16,
                children: [
                  _FuelMetric(
                    label: 'Fuel type',
                    value: _event.fuelType?.trim().isNotEmpty == true
                        ? _event.fuelType!.trim()
                        : fallbackValue,
                    width: columnWidth,
                  ),
                  _FuelMetric(
                    label: 'Liters',
                    value: volumeText,
                    width: columnWidth,
                  ),
                  _FuelMetric(
                    label: 'Price (per L)',
                    value: pricePerLiterText,
                    width: columnWidth,
                  ),
                  _FuelMetric(
                    label: 'Full tank',
                    value: fullTankText,
                    width: columnWidth,
                  ),
                  _FuelMetric(
                    label: 'Total cost',
                    value: amountText,
                    width: columnWidth,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DriverPlaceholderCard extends StatelessWidget {
  const _DriverPlaceholderCard();

  static const String _driverName = 'Google Driver (placeholder)';
  static const String _driverEmail = 'driver.placeholder@gmail.com';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DriveCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.surfaceSecondary,
            child: Icon(
              Icons.person_outline,
              size: 24,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _driverName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _driverEmail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FuelMetric extends StatelessWidget {
  const _FuelMetric({
    required this.label,
    required this.value,
    required this.width,
  });

  final String label;
  final String value;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
