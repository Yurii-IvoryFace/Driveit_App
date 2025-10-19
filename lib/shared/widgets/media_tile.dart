import 'package:flutter/material.dart';

class DriveMediaTile extends StatelessWidget {
  const DriveMediaTile({
    super.key,
    required this.child,
    this.onTap,
    this.topLabel,
    this.bottomLabel,
    this.topTrailing,
    this.borderRadius = 18,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? topLabel;
  final String? bottomLabel;
  final Widget? topTrailing;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (topLabel != null || topTrailing != null)
            Positioned(
              left: 12,
              right: 12,
              top: 10,
              child: Row(
                children: [
                  if (topLabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        topLabel!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (topTrailing != null) topTrailing!,
                ],
              ),
            ),
          if (bottomLabel != null)
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  bottomLabel!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
    );

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (onTap != null) {
      content = GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}
