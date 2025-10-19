import 'dart:convert';
import 'dart:typed_data';

import 'package:driveit_app/features/events/domain/vehicle_event.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

Future<void> showVehicleAttachment(
  BuildContext context,
  VehicleEventAttachment attachment,
) async {
  final data = _decodeDataUrl(attachment.dataUrl);
  if (data == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to load attachment')),
    );
    return;
  }

  switch (attachment.type) {
    case VehicleEventAttachmentType.photo:
      await showDialog<void>(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InteractiveViewer(
              maxScale: 5,
              child: Image.memory(
                data,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      );
      break;
    case VehicleEventAttachmentType.document:
      await showDialog<void>(
        context: context,
        builder: (context) {
          return _DocumentPreviewDialog(
            title: attachment.name,
            mimeType: _inferMimeType(attachment),
            bytes: data,
          );
        },
      );
      break;
  }
}

Uint8List? _decodeDataUrl(String dataUrl) {
  try {
    final uri = Uri.parse(dataUrl);
    if (uri.data != null) {
      return Uint8List.fromList(uri.data!.contentAsBytes());
    }
    final separatorIndex = dataUrl.indexOf(',');
    if (separatorIndex == -1) return null;
    final base64Part = dataUrl.substring(separatorIndex + 1);
    return base64.decode(base64Part);
  } catch (_) {
    return null;
  }
}

String _inferMimeType(VehicleEventAttachment attachment) {
  final uri = Uri.tryParse(attachment.dataUrl);
  final mimeFromData = uri?.data?.mimeType;
  if (mimeFromData != null && mimeFromData.isNotEmpty) {
    return mimeFromData;
  }
  final name = attachment.name.toLowerCase();
  if (name.endsWith('.pdf')) return 'application/pdf';
  if (name.endsWith('.doc')) return 'application/msword';
  if (name.endsWith('.docx')) {
    return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
  }
  if (name.endsWith('.png')) return 'image/png';
  if (name.endsWith('.gif')) return 'image/gif';
  if (name.endsWith('.heic')) return 'image/heic';
  return 'application/octet-stream';
}

class _DocumentPreviewDialog extends StatelessWidget {
  const _DocumentPreviewDialog({
    required this.title,
    required this.mimeType,
    required this.bytes,
  });

  final String title;
  final String mimeType;
  final Uint8List bytes;

  bool get _isPdf => mimeType.contains('pdf');

  bool get _isPlainText => mimeType.startsWith('text/');

  bool get _looksLikePdf =>
      bytes.length >= 4 &&
      bytes[0] == 0x25 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x44 &&
      bytes[3] == 0x46;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: _buildContent(theme),
            ),
            const Divider(height: 1),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isPdf) {
      if (_looksLikePdf) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: _PdfInlineViewer(bytes: bytes),
        );
      }
      return const _AttachmentPreviewMessage(
        icon: Icons.picture_as_pdf_outlined,
        message: 'This document is not a valid PDF file.',
      );
    }
    if (_isPlainText) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(
          utf8.decode(bytes, allowMalformed: true),
          style: theme.textTheme.bodyMedium,
        ),
      );
    }
    return const _AttachmentPreviewMessage(
      icon: Icons.insert_drive_file_outlined,
      message: 'Preview is not available for this document type yet.',
    );
  }
}

class _PdfInlineViewer extends StatefulWidget {
  const _PdfInlineViewer({required this.bytes});

  final Uint8List bytes;

  @override
  State<_PdfInlineViewer> createState() => _PdfInlineViewerState();
}

class _PdfInlineViewerState extends State<_PdfInlineViewer> {
  late PdfControllerPinch _controller;

  @override
  void initState() {
    super.initState();
    _controller = PdfControllerPinch(
      document: PdfDocument.openData(widget.bytes),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PdfViewPinch(
      controller: _controller,
    );
  }
}

class _AttachmentPreviewMessage extends StatelessWidget {
  const _AttachmentPreviewMessage({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
