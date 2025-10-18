import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      children: [
        Text(
          'Preferences',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        _SettingCard(
          icon: Icons.palette_outlined,
          title: 'Theme & appearance',
          description:
              'Switch between dark, midnight, or custom accent colors to match your in-car displays.',
          actionLabel: 'Customize',
        ),
        const SizedBox(height: 12),
        _SettingCard(
          icon: Icons.notifications_active_outlined,
          title: 'Notifications',
          description:
              'Enable reminders for insurance, registration, and maintenance tasks.',
          actionLabel: 'Configure',
        ),
        const SizedBox(height: 12),
        _SettingCard(
          icon: Icons.cloud_sync_outlined,
          title: 'Cloud sync',
          description:
              'Link DriveIt to Google Drive or Firebase to back up your data securely.',
          actionLabel: 'Link account',
        ),
        const SizedBox(height: 12),
        _SettingCard(
          icon: Icons.language_outlined,
          title: 'Localization',
          description:
              'Set preferred units, currency, and language for metrics and reports.',
          actionLabel: 'Coming soon',
          actionEnabled: false,
        ),
      ],
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    this.actionEnabled = true,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final bool actionEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        color: AppColors.surface,
      ),
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
            onPressed: actionEnabled ? () {} : null,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
