import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:driveit_app/shared/widgets/drive_card.dart';
import 'package:flutter/material.dart';

/// Displays a compact label/value pair on a branded surface.
class DriveStatTile extends StatelessWidget {
  const DriveStatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.backgroundColor,
    this.labelStyle,
    this.valueStyle,
    this.padding,
    this.borderRadius = 18,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? backgroundColor;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    return DriveCard(
      color: backgroundColor ?? AppColors.surfaceSecondary,
      borderRadius: borderRadius,
      padding: resolvedPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: AppColors.accent),
            const SizedBox(height: 8),
          ],
          Text(
            label,
            style:
                labelStyle ??
                theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style:
                valueStyle ??
                theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
