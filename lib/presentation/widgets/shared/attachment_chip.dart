import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AttachmentChip extends StatelessWidget {
  final String fileName;
  final String? fileSize;
  final IconData? icon;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AttachmentChip({
    super.key,
    required this.fileName,
    this.fileSize,
    this.icon,
    this.onDelete,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Material(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon ?? _getFileIcon(fileName),
                  size: 16,
                  color: textColor ?? AppColors.onSurface,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _truncateFileName(fileName),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor ?? AppColors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (fileSize != null) ...[
                        Text(
                          fileSize!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: (textColor ?? AppColors.onSurface)
                                    .withValues(alpha: 0.7),
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onDelete != null) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: (textColor ?? AppColors.onSurface).withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      default:
        return Icons.attach_file;
    }
  }

  String _truncateFileName(String fileName) {
    if (fileName.length <= 20) return fileName;
    final nameWithoutExt = fileName.split('.').first;
    final extension = fileName.split('.').last;
    if (nameWithoutExt.length <= 15) return fileName;
    return '${nameWithoutExt.substring(0, 15)}...$extension';
  }
}

class AttachmentChipList extends StatelessWidget {
  final List<AttachmentChip> attachments;
  final WrapAlignment alignment;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? padding;

  const AttachmentChipList({
    super.key,
    required this.attachments,
    this.alignment = WrapAlignment.start,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: Wrap(
        alignment: alignment,
        spacing: spacing,
        runSpacing: runSpacing,
        children: attachments,
      ),
    );
  }
}

class AttachmentPreview extends StatelessWidget {
  final String fileName;
  final String? filePath;
  final String? fileSize;
  final IconData? icon;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const AttachmentPreview({
    super.key,
    required this.fileName,
    this.filePath,
    this.fileSize,
    this.icon,
    this.onDelete,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 120,
      height: height ?? 120,
      margin: const EdgeInsets.all(8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon ?? _getFileIcon(fileName),
                      size: 32,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _truncateFileName(fileName, 15),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    if (fileSize != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        fileSize!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onDelete != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      default:
        return Icons.attach_file;
    }
  }

  String _truncateFileName(String fileName, int maxLength) {
    if (fileName.length <= maxLength) return fileName;
    final nameWithoutExt = fileName.split('.').first;
    final extension = fileName.split('.').last;
    if (nameWithoutExt.length <= maxLength - 4) return fileName;
    return '${nameWithoutExt.substring(0, maxLength - 4)}...$extension';
  }
}
