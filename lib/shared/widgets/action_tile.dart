import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:driveit_app/shared/widgets/drive_card.dart';
import 'package:flutter/material.dart';

/// Actionable settings-style tile with icon, description, and call-to-action.
class DriveActionTile extends StatelessWidget {
  const DriveActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    this.onPressed,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DriveCard(
      color: AppColors.surface,
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.accent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          FilledButton.tonal(
            onPressed: enabled ? onPressed : null,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
