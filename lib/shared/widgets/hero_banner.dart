import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Hero banner with background image/gradient and action buttons.
class DriveHeroBanner extends StatelessWidget {
  const DriveHeroBanner({
    super.key,
    this.image,
    required this.title,
    required this.subtitle,
    required this.primaryAction,
    this.secondaryAction,
    this.height = 220,
    this.fallbackIcon = Icons.directions_car_outlined,
  });

  final ImageProvider<Object>? image;
  final String title;
  final String subtitle;
  final Widget primaryAction;
  final Widget? secondaryAction;
  final double height;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
            image: image != null
                ? DecorationImage(
                    image: image!,
                    fit: BoxFit.cover,
                    onError: (error, stackTrace) {},
                  )
                : null,
            color: AppColors.surfaceSecondary,
          ),
          child: image == null
              ? Center(
                  child: Icon(
                    fallbackIcon,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                )
              : null,
        ),
        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black87],
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    primaryAction,
                    if (secondaryAction != null) ...[
                      const SizedBox(width: 12),
                      secondaryAction!,
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
