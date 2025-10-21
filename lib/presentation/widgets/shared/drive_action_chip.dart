import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DriveActionChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isSelected;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const DriveActionChip({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isSelected = false,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = isSelected
        ? (selectedColor ?? AppColors.primary)
        : (backgroundColor ?? AppColors.surface);

    final effectiveTextColor = isSelected
        ? AppColors.onPrimary
        : (textColor ?? AppColors.onSurface);

    return Container(
      margin: margin,
      child: Material(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        elevation: isSelected ? 2 : 0,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: effectiveTextColor),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: effectiveTextColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DriveFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onSelected;
  final IconData? icon;
  final Color? selectedColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const DriveFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onSelected,
    this.icon,
    this.selectedColor,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
              ),
              const SizedBox(width: 6),
            ],
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: onSelected != null ? (_) => onSelected!() : null,
        selectedColor: selectedColor ?? AppColors.primary,
        checkmarkColor: AppColors.onPrimary,
        backgroundColor: AppColors.surface,
        side: BorderSide(
          color: isSelected
              ? (selectedColor ?? AppColors.primary)
              : AppColors.border,
          width: 1,
        ),
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

class DriveChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onSelected;
  final IconData? icon;
  final Color? selectedColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const DriveChoiceChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onSelected,
    this.icon,
    this.selectedColor,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
              ),
              const SizedBox(width: 6),
            ],
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: onSelected != null ? (_) => onSelected!() : null,
        selectedColor: selectedColor ?? AppColors.primary,
        backgroundColor: AppColors.surface,
        side: BorderSide(
          color: isSelected
              ? (selectedColor ?? AppColors.primary)
              : AppColors.border,
          width: 1,
        ),
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

class DriveChipGroup extends StatelessWidget {
  final List<Widget> chips;
  final WrapAlignment alignment;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? padding;

  const DriveChipGroup({
    super.key,
    required this.chips,
    this.alignment = WrapAlignment.start,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: Wrap(
        alignment: alignment,
        spacing: spacing,
        runSpacing: runSpacing,
        children: chips,
      ),
    );
  }
}
