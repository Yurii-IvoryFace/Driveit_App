import 'package:flutter/material.dart';

/// Shared multi-line notes field used across forms.
class DriveNotesField extends StatelessWidget {
  const DriveNotesField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.minLines = 3,
    this.maxLines = 6,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final int minLines;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
      ),
      onChanged: onChanged,
    );
  }
}
