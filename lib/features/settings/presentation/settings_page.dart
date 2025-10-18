import 'package:driveit_app/shared/widgets/widgets.dart';
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
        DriveActionTile(
          icon: Icons.palette_outlined,
          title: 'Theme & appearance',
          description:
              'Switch between dark, midnight, or custom accent colors to match your in-car displays.',
          actionLabel: 'Customize',
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        DriveActionTile(
          icon: Icons.notifications_active_outlined,
          title: 'Notifications',
          description:
              'Enable reminders for insurance, registration, and maintenance tasks.',
          actionLabel: 'Configure',
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        DriveActionTile(
          icon: Icons.cloud_sync_outlined,
          title: 'Cloud sync',
          description:
              'Link DriveIt to Google Drive or Firebase to back up your data securely.',
          actionLabel: 'Link account',
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        DriveActionTile(
          icon: Icons.language_outlined,
          title: 'Localization',
          description:
              'Set preferred units, currency, and language for metrics and reports.',
          actionLabel: 'Coming soon',
          enabled: false,
        ),
      ],
    );
  }
}
