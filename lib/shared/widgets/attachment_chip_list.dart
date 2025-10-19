import 'package:flutter/material.dart';
import 'package:driveit_app/features/events/domain/vehicle_event.dart';
import 'package:driveit_app/shared/widgets/attachment_chip.dart';

typedef AttachmentTapCallback =
    void Function(VehicleEventAttachment attachment);
typedef AttachmentDeleteCallback =
    void Function(VehicleEventAttachment attachment);

/// Renders a responsive wrap of attachment chips, optionally with tap/delete.
class DriveAttachmentChipList extends StatelessWidget {
  const DriveAttachmentChipList({
    super.key,
    required this.attachments,
    this.onTap,
    this.onDeleted,
    this.spacing = 12,
    this.runSpacing = 12,
    this.emptyIndicator,
  });

  final List<VehicleEventAttachment> attachments;
  final AttachmentTapCallback? onTap;
  final AttachmentDeleteCallback? onDeleted;
  final double spacing;
  final double runSpacing;
  final Widget? emptyIndicator;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return emptyIndicator ?? const SizedBox.shrink();
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: attachments
          .map(
            (attachment) => DriveAttachmentChip(
              icon: attachment.type == VehicleEventAttachmentType.photo
                  ? Icons.photo_outlined
                  : Icons.insert_drive_file_outlined,
              label: attachment.name,
              onTap: onTap == null ? null : () => onTap!(attachment),
              onDeleted: onDeleted == null
                  ? null
                  : () => onDeleted!(attachment),
            ),
          )
          .toList(growable: false),
    );
  }
}
