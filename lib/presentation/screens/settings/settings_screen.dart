import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/preferences/app_preferences.dart';
import '../../widgets/shared/drive_card.dart';
import '../../widgets/shared/drive_section_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    await AppPreferences.init();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            DriveSectionHeader(
              title: 'Appearance',
              subtitle: 'Customize the look and feel of the app',
            ),
            DriveCard(
              child: Column(
                children: [
                  _buildThemeSelector(),
                  const DriveDivider(),
                  _buildLanguageSelector(),
                ],
              ),
            ),

            // Units Section
            DriveSectionHeader(
              title: 'Units',
              subtitle: 'Configure measurement units',
            ),
            DriveCard(
              child: Column(
                children: [
                  _buildDistanceUnitSelector(),
                  const DriveDivider(),
                  _buildVolumeUnitSelector(),
                  const DriveDivider(),
                  _buildCurrencySelector(),
                ],
              ),
            ),

            // Notifications Section
            DriveSectionHeader(
              title: 'Notifications',
              subtitle: 'Manage notification preferences',
            ),
            DriveCard(
              child: Column(
                children: [
                  _buildNotificationToggle(),
                  const DriveDivider(),
                  _buildAutoSyncToggle(),
                ],
              ),
            ),

            // Data Section
            DriveSectionHeader(
              title: 'Data',
              subtitle: 'Manage your data and storage',
            ),
            DriveCard(
              child: Column(
                children: [
                  _buildDataRetentionSelector(),
                  const DriveDivider(),
                  _buildDataManagementActions(),
                ],
              ),
            ),

            // About Section
            DriveSectionHeader(
              title: 'About',
              subtitle: 'App information and support',
            ),
            DriveCard(
              child: Column(
                children: [
                  _buildAppInfo(),
                  const DriveDivider(),
                  _buildSupportActions(),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    return ListTile(
      leading: const Icon(Icons.palette, color: AppColors.primary),
      title: const Text('Theme'),
      subtitle: Text(_getThemeDisplayName(AppPreferences.themeMode)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showThemeSelector(),
    );
  }

  Widget _buildLanguageSelector() {
    return ListTile(
      leading: const Icon(Icons.language, color: AppColors.primary),
      title: const Text('Language'),
      subtitle: Text(_getLanguageDisplayName(AppPreferences.language)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showLanguageSelector(),
    );
  }

  Widget _buildDistanceUnitSelector() {
    return ListTile(
      leading: const Icon(Icons.straighten, color: AppColors.primary),
      title: const Text('Distance Unit'),
      subtitle: Text(AppPreferences.distanceUnit.displayName),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showDistanceUnitSelector(),
    );
  }

  Widget _buildVolumeUnitSelector() {
    return ListTile(
      leading: const Icon(Icons.local_gas_station, color: AppColors.primary),
      title: const Text('Volume Unit'),
      subtitle: Text(AppPreferences.volumeUnit.displayName),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showVolumeUnitSelector(),
    );
  }

  Widget _buildCurrencySelector() {
    return ListTile(
      leading: const Icon(Icons.attach_money, color: AppColors.primary),
      title: const Text('Currency'),
      subtitle: Text(AppPreferences.currency),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showCurrencySelector(),
    );
  }

  Widget _buildNotificationToggle() {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications, color: AppColors.primary),
      title: const Text('Enable Notifications'),
      subtitle: const Text('Receive reminders and updates'),
      value: AppPreferences.notificationsEnabled,
      onChanged: (value) async {
        await AppPreferences.setNotificationsEnabled(value);
        setState(() {});
      },
    );
  }

  Widget _buildAutoSyncToggle() {
    return SwitchListTile(
      secondary: const Icon(Icons.sync, color: AppColors.primary),
      title: const Text('Auto Sync'),
      subtitle: const Text('Automatically sync data when available'),
      value: AppPreferences.autoSyncEnabled,
      onChanged: (value) async {
        await AppPreferences.setAutoSyncEnabled(value);
        setState(() {});
      },
    );
  }

  Widget _buildDataRetentionSelector() {
    return ListTile(
      leading: const Icon(Icons.storage, color: AppColors.primary),
      title: const Text('Data Retention'),
      subtitle: Text('${AppPreferences.dataRetentionDays} days'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showDataRetentionSelector(),
    );
  }

  Widget _buildDataManagementActions() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.download, color: AppColors.primary),
          title: const Text('Export Data'),
          subtitle: const Text('Export your data to a file'),
          onTap: () => _exportData(),
        ),
        ListTile(
          leading: const Icon(Icons.upload, color: AppColors.primary),
          title: const Text('Import Data'),
          subtitle: const Text('Import data from a file'),
          onTap: () => _importData(),
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: AppColors.error),
          title: const Text('Clear All Data'),
          subtitle: const Text('Permanently delete all data'),
          onTap: () => _clearAllData(),
        ),
      ],
    );
  }

  Widget _buildAppInfo() {
    return ListTile(
      leading: const Icon(Icons.info, color: AppColors.primary),
      title: const Text('App Version'),
      subtitle: const Text('1.0.0'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showAppInfo(),
    );
  }

  Widget _buildSupportActions() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.help, color: AppColors.primary),
          title: const Text('Help & Support'),
          subtitle: const Text('Get help and contact support'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showHelp(),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip, color: AppColors.primary),
          title: const Text('Privacy Policy'),
          subtitle: const Text('Read our privacy policy'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showPrivacyPolicy(),
        ),
        ListTile(
          leading: const Icon(Icons.description, color: AppColors.primary),
          title: const Text('Terms of Service'),
          subtitle: const Text('Read our terms of service'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showTermsOfService(),
        ),
      ],
    );
  }

  String _getThemeDisplayName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'System Default';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }

  String _getLanguageDisplayName(String language) {
    switch (language) {
      case 'en':
        return 'English';
      case 'uk':
        return 'Українська';
      case 'ru':
        return 'Русский';
      default:
        return 'English';
    }
  }

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Theme',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...AppThemeMode.values.map(
              (mode) => ListTile(
                title: Text(_getThemeDisplayName(mode)),
                leading: Radio<AppThemeMode>(
                  value: mode,
                  groupValue: AppPreferences.themeMode,
                  onChanged: (value) async {
                    if (value != null) {
                      await AppPreferences.setThemeMode(value);
                      if (mounted) {
                        setState(() {});
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...['en', 'uk', 'ru'].map(
              (lang) => ListTile(
                title: Text(_getLanguageDisplayName(lang)),
                leading: Radio<String>(
                  value: lang,
                  groupValue: AppPreferences.language,
                  onChanged: (value) async {
                    if (value != null) {
                      await AppPreferences.setLanguage(value);
                      if (mounted) {
                        setState(() {});
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDistanceUnitSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Distance Unit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...DistanceUnit.values.map(
              (unit) => ListTile(
                title: Text(unit.displayName),
                leading: Radio<DistanceUnit>(
                  value: unit,
                  groupValue: AppPreferences.distanceUnit,
                  onChanged: (value) async {
                    if (value != null) {
                      await AppPreferences.setDistanceUnit(value);
                      if (mounted) {
                        setState(() {});
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVolumeUnitSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Volume Unit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...VolumeUnit.values.map(
              (unit) => ListTile(
                title: Text(unit.displayName),
                leading: Radio<VolumeUnit>(
                  value: unit,
                  groupValue: AppPreferences.volumeUnit,
                  onChanged: (value) async {
                    if (value != null) {
                      await AppPreferences.setVolumeUnit(value);
                      if (mounted) {
                        setState(() {});
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Currency',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...Currency.supportedCurrencies.map(
              (currency) => ListTile(
                title: Text('${currency.symbol} ${currency.name}'),
                subtitle: Text(currency.code),
                leading: Radio<String>(
                  value: currency.symbol,
                  groupValue: AppPreferences.currency,
                  onChanged: (value) async {
                    if (value != null) {
                      await AppPreferences.setCurrency(value);
                      if (mounted) {
                        setState(() {});
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDataRetentionSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Data Retention Period',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...['30', '90', '180', '365', '730'].map(
              (days) => ListTile(
                title: Text('$days days'),
                leading: Radio<String>(
                  value: days,
                  groupValue: AppPreferences.dataRetentionDays.toString(),
                  onChanged: (value) async {
                    if (value != null) {
                      await AppPreferences.setDataRetentionDays(
                        int.parse(value),
                      );
                      if (mounted) {
                        setState(() {});
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality not yet implemented')),
    );
  }

  void _importData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import functionality not yet implemented')),
    );
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await AppPreferences.clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('All data cleared')));
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAppInfo() {
    showAboutDialog(
      context: context,
      applicationName: 'DriveIt',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.directions_car, size: 48),
    );
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & Support not yet implemented')),
    );
  }

  void _showPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Policy not yet implemented')),
    );
  }

  void _showTermsOfService() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of Service not yet implemented')),
    );
  }
}
