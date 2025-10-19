import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:driveit_app/shared/widgets/drive_card.dart';
import 'package:flutter/material.dart';

/// Generic timeline card used to display dated events with metadata chips.
class DriveTimelineCard extends StatelessWidget {
  const DriveTimelineCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.dateLabel,
    this.location,
    this.locationIcon = Icons.place_outlined,
    this.metaChips = const <Widget>[],
    this.notes,
    this.hasAttachments = false,
    this.onTap,
    this.iconBackgroundColor,
    this.locationTrailing,
    this.headerTrailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String dateLabel;
  final String? location;
  final IconData locationIcon;
  final List<Widget> metaChips;
  final String? notes;
  final bool hasAttachments;
  final VoidCallback? onTap;
  final Color? iconBackgroundColor;
  final Widget? locationTrailing;
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconBg =
        iconBackgroundColor ?? iconColor.withValues(alpha: 0.18);

    return DriveCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(20),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: effectiveIconBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (headerTrailing != null) ...[
                      headerTrailing!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      dateLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (location != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        locationIcon,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (locationTrailing != null) ...[
                        const SizedBox(width: 8),
                        locationTrailing!,
                      ] else if (hasAttachments) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.attach_file,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                ],
                if (metaChips.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(spacing: 12, runSpacing: 6, children: metaChips),
                ],
                if (notes?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Text(
                    notes!.trim(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
