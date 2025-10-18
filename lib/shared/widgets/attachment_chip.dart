import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Chip used to represent attachments with optional tap/delete actions.
class DriveAttachmentChip extends StatelessWidget {
  const DriveAttachmentChip({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.onDeleted,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RawChip(
      label: Text(label),
      avatar: Icon(icon, size: 18, color: AppColors.textSecondary),
      backgroundColor: AppColors.surfaceSecondary,
      deleteIcon: onDeleted != null
          ? const Icon(Icons.close, size: 18, color: AppColors.textSecondary)
          : null,
      onDeleted: onDeleted,
      onPressed: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      labelStyle: theme.textTheme.bodyMedium,
      visualDensity: VisualDensity.compact,
    );
  }
}
