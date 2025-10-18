import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:driveit_app/shared/widgets/drive_card.dart';
import 'package:flutter/material.dart';

/// Unified empty-state presentation used across modules.
class DriveEmptyState extends StatelessWidget {
  const DriveEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.useCard = true,
    this.alignment = CrossAxisAlignment.center,
    this.textAlign = TextAlign.center,
    this.iconColor,
    this.spacing = 16,
    this.padding,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final bool useCard;
  final CrossAxisAlignment alignment;
  final TextAlign textAlign;
  final Color? iconColor;
  final double spacing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        Icon(icon, size: 56, color: iconColor ?? AppColors.textSecondary),
        SizedBox(height: spacing),
        Text(
          title,
          textAlign: textAlign,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: textAlign,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        if (primaryActionLabel != null && onPrimaryAction != null) ...[
          SizedBox(height: spacing),
          FilledButton(
            onPressed: onPrimaryAction,
            child: Text(primaryActionLabel!),
          ),
        ],
      ],
    );

    if (!useCard) {
      return content;
    }

    return DriveCard(
      padding: padding ?? const EdgeInsets.all(24),
      child: content,
    );
  }
}
