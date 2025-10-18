import 'package:driveit_app/features/events/domain/vehicle_event.dart';
import 'package:driveit_app/features/events/domain/vehicle_event_repository.dart';
import 'package:driveit_app/features/events/presentation/event_visuals.dart';
import 'package:driveit_app/features/events/presentation/vehicle_event_form_page.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/shared/theme/app_theme.dart';
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                  color: AppColors.surface,
                ),
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
              _DetailSection(
                title: 'Location',
                value: _event.location?.trim().isNotEmpty == true
                    ? _event.location!.trim()
                    : 'Not specified',
                leading: Icons.place_outlined,
              ),
              if (odometerText != null)
                _DetailSection(
                  title: 'Odometer',
                  value: odometerText,
                  leading: Icons.speed_outlined,
                ),
              if (_event.serviceType != null &&
                  _event.serviceType!.trim().isNotEmpty)
                _DetailSection(
                  title: 'Service type',
                  value: _event.serviceType!,
                  leading: Icons.build_outlined,
                ),
              if (amountText != null)
                _DetailSection(
                  title: 'Amount',
                  value: amountText,
                  leading: Icons.payments_outlined,
                ),
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
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _event.attachments.map((attachment) {
                    return _AttachmentChip(attachment: attachment);
                  }).toList(),
                ),
              ],
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
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.value,
    required this.leading,
  });

  final String title;
  final String value;
  final IconData leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.surfaceSecondary,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(leading, color: AppColors.textSecondary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({required this.attachment});

  final VehicleEventAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final isPhoto = attachment.type == VehicleEventAttachmentType.photo;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        color: AppColors.surfaceSecondary,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPhoto ? Icons.photo_outlined : Icons.insert_drive_file_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Text(attachment.name, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
