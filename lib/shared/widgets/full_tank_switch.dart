import 'package:flutter/material.dart';

/// Standardized switch list tile for toggling full-tank refuels.
class DriveFullTankSwitch extends StatelessWidget {
  const DriveFullTankSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Full tank fill-up',
    this.subtitle,
    this.contentPadding = EdgeInsets.zero,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final String? subtitle;
  final EdgeInsetsGeometry contentPadding;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: enabled ? onChanged : null,
      contentPadding: contentPadding,
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle!),
    );
  }
}
