import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'drive_action_chip.dart';

/// Reusable action chip that opens a material date picker.
class DriveDatePickerChip extends StatelessWidget {
  const DriveDatePickerChip({
    super.key,
    required this.date,
    required this.onDateChanged,
    this.icon = Icons.calendar_today_outlined,
    this.color,
    this.labelBuilder,
    this.firstDate,
    this.lastDate,
  });

  /// Currently selected date to display.
  final DateTime date;

  /// Callback invoked when a new date is picked.
  final ValueChanged<DateTime> onDateChanged;

  /// Icon rendered inside the chip. Defaults to [Icons.calendar_today_outlined].
  final IconData icon;

  /// Optional background color for the chip.
  final Color? color;

  /// Allows customizing the displayed label. Defaults to `MMM d, yyyy`.
  final String Function(DateTime date)? labelBuilder;

  /// Optional minimum date selectable by the picker.
  final DateTime? firstDate;

  /// Optional maximum date selectable by the picker.
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLabelBuilder =
        labelBuilder ?? (date) => DateFormat('MMM d, yyyy').format(date);

    return DriveActionChip(
      icon: icon,
      label: effectiveLabelBuilder(date),
      color: color ?? theme.colorScheme.primary,
      onTap: () => _handleTap(context),
    );
  }

  Future<void> _handleTap(BuildContext context) async {
    final now = DateTime.now();
    final min = firstDate ?? DateTime(now.year - 10);
    final max = lastDate ?? DateTime(now.year + 10);

    DateTime initialDate = date;
    if (initialDate.isBefore(min)) initialDate = min;
    if (initialDate.isAfter(max)) initialDate = max;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: min,
      lastDate: max,
    );
    if (picked == null) return;
    onDateChanged(picked);
  }
}
