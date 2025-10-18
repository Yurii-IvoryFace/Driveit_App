import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Reusable surface card with Driveit's rounded styling.
class DriveCard extends StatelessWidget {
  const DriveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.borderRadius = 20,
    this.onTap,
    this.clipBehavior,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final Clip? clipBehavior;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final resolvedPadding = padding ?? const EdgeInsets.all(20);

    Widget content = DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: radius,
        clipBehavior: clipBehavior ?? Clip.none,
        child: Padding(padding: resolvedPadding, child: child),
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: radius),
        child: InkWell(borderRadius: radius, onTap: onTap, child: content),
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}
