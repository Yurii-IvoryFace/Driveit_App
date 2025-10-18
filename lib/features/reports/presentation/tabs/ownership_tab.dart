import 'package:driveit_app/features/reports/presentation/tabs/tab_components.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_document.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_repository.dart';
import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OwnershipTab extends StatelessWidget {
  const OwnershipTab({
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
            icon: Icons.assignment_outlined,
            title: 'Keep ownership tasks organised',
            message:
                'Upload documents and track renewals once you have at least one vehicle configured.',
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

        final documents = [...selected.documents]
          ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
        final categoryCounts = _groupDocumentsByCategory(documents);
        final tasks = _ownershipTasks(selected);

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            VehicleSelectorRow(
              vehicles: vehicles,
              selected: selected,
              onVehicleChanged: onVehicleChanged,
              trailing: FilledButton.icon(
                onPressed: () => onOpenVehicleDetails(selected),
                icon: const Icon(Icons.folder_shared_outlined),
                label: const Text('Manage documents'),
              ),
            ),
            const SizedBox(height: 24),
            _OwnershipDocumentSummary(counts: categoryCounts),
            const SizedBox(height: 24),
            _OwnershipTaskList(tasks: tasks),
            const SizedBox(height: 24),
            _OwnershipDocumentsList(documents: documents),
          ],
        );
      },
    );
  }
}

class _OwnershipDocumentSummary extends StatelessWidget {
  const _OwnershipDocumentSummary({required this.counts});

  final Map<VehicleDocumentCategory, int> counts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (counts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'No documents attached yet. Upload vehicle paperwork to keep everything at hand.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

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
            'Document library',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: counts.entries
                .map(
                  (entry) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entry.key.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${entry.value}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _OwnershipTaskList extends StatelessWidget {
  const _OwnershipTaskList({required this.tasks});

  final List<_OwnershipTask> tasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'No upcoming ownership tasks tracked for this vehicle.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

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
            'Renewals & reminders',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...tasks.map((task) {
            final status = _evaluateTaskStatus(task);
            final statusLabel = _describeTaskStatus(status, task);
            final statusColor = _taskStatusColor(status);
            final dateLabel = task.date != null
                ? DateFormat('MMM d, yyyy').format(task.date!)
                : 'Not set';

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

class _OwnershipDocumentsList extends StatelessWidget {
  const _OwnershipDocumentsList({required this.documents});

  final List<VehicleDocument> documents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = documents.take(6).toList();

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'When you upload insurance, registration, or maintenance files they will appear here.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final dateFormat = DateFormat('MMM d, yyyy');

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
            'Latest documents',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (doc) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  _documentIcon(doc.category),
                  color: AppColors.accent,
                ),
                title: Text(doc.title, style: theme.textTheme.titleMedium),
                subtitle: Text(
                  doc.category.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Text(
                  dateFormat.format(doc.uploadedAt),
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

Map<VehicleDocumentCategory, int> _groupDocumentsByCategory(
  List<VehicleDocument> docs,
) {
  final counts = <VehicleDocumentCategory, int>{};
  for (final doc in docs) {
    counts.update(doc.category, (value) => value + 1, ifAbsent: () => 1);
  }
  return counts;
}

List<_OwnershipTask> _ownershipTasks(Vehicle vehicle) {
  return [
    _OwnershipTask(
      title: 'Insurance renewal',
      icon: Icons.policy_outlined,
      date: vehicle.insuranceExpiry,
      type: _OwnershipTaskType.due,
    ),
    _OwnershipTask(
      title: 'Registration renewal',
      icon: Icons.badge_outlined,
      date: vehicle.registrationExpiry,
      type: _OwnershipTaskType.due,
    ),
    _OwnershipTask(
      title: 'Next service',
      icon: Icons.build_circle_outlined,
      date: vehicle.nextService,
      type: _OwnershipTaskType.due,
    ),
    _OwnershipTask(
      title: 'Last service',
      icon: Icons.history_toggle_off_outlined,
      date: vehicle.lastService,
      type: _OwnershipTaskType.completed,
    ),
  ];
}

class _OwnershipTask {
  const _OwnershipTask({
    required this.title,
    required this.icon,
    this.date,
    required this.type,
  });

  final String title;
  final IconData icon;
  final DateTime? date;
  final _OwnershipTaskType type;
}

enum _OwnershipTaskType { due, completed }

enum _TaskStatus { overdue, dueSoon, onTrack, completed, missing }

_TaskStatus _evaluateTaskStatus(_OwnershipTask task) {
  if (task.type == _OwnershipTaskType.completed) {
    return task.date == null ? _TaskStatus.missing : _TaskStatus.completed;
  }
  if (task.date == null) return _TaskStatus.missing;

  final today = DateTime.now();
  final comparisonDate = DateTime(today.year, today.month, today.day);
  final delta = task.date!.difference(comparisonDate).inDays;

  if (delta < 0) return _TaskStatus.overdue;
  if (delta <= 30) return _TaskStatus.dueSoon;
  return _TaskStatus.onTrack;
}

String _describeTaskStatus(_TaskStatus status, _OwnershipTask task) {
  switch (status) {
    case _TaskStatus.onTrack:
      final days = task.date!.difference(DateTime.now()).inDays;
      return days == 0
          ? 'Due today'
          : 'Due in $days day${days == 1 ? '' : 's'}';
    case _TaskStatus.dueSoon:
      final days = task.date!.difference(DateTime.now()).inDays;
      return days == 0
          ? 'Due today'
          : 'Due in $days day${days == 1 ? '' : 's'}';
    case _TaskStatus.overdue:
      final days = DateTime.now().difference(task.date!).inDays;
      return 'Overdue ${days}d';
    case _TaskStatus.completed:
      return 'Completed';
    case _TaskStatus.missing:
      return 'Not scheduled';
  }
}

Color _taskStatusColor(_TaskStatus status) {
  switch (status) {
    case _TaskStatus.overdue:
      return AppColors.danger;
    case _TaskStatus.dueSoon:
      return AppColors.accent;
    case _TaskStatus.onTrack:
      return AppColors.primary;
    case _TaskStatus.completed:
      return AppColors.textSecondary;
    case _TaskStatus.missing:
      return AppColors.textSecondary;
  }
}

IconData _documentIcon(VehicleDocumentCategory category) {
  switch (category) {
    case VehicleDocumentCategory.insurance:
      return Icons.policy_outlined;
    case VehicleDocumentCategory.registration:
      return Icons.badge_outlined;
    case VehicleDocumentCategory.maintenance:
      return Icons.build_outlined;
    case VehicleDocumentCategory.purchase:
      return Icons.receipt_long_outlined;
    case VehicleDocumentCategory.other:
      return Icons.insert_drive_file_outlined;
  }
}
