import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class NotesField extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? label;
  final String? hint;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const NotesField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.label,
    this.hint,
    this.maxLines,
    this.maxLength,
    this.enabled = true,
    this.padding,
    this.margin,
  });

  @override
  State<NotesField> createState() => _NotesFieldState();
}

class _NotesFieldState extends State<NotesField> {
  late TextEditingController _controller;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _currentLength = _controller.text.length;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      margin: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],
          TextFormField(
            controller: _controller,
            enabled: widget.enabled,
            maxLines: widget.maxLines ?? 4,
            maxLength: widget.maxLength,
            decoration: InputDecoration(
              hintText: widget.hint ?? 'Add notes...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (value) {
              setState(() {
                _currentLength = value.length;
              });
              widget.onChanged?.call(value);
            },
          ),
          if (widget.maxLength != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$_currentLength/${widget.maxLength}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _currentLength > widget.maxLength!
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ExpandableNotesField extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? label;
  final String? hint;
  final int? maxLength;
  final bool enabled;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ExpandableNotesField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.label,
    this.hint,
    this.maxLength,
    this.enabled = true,
    this.padding,
    this.margin,
  });

  @override
  State<ExpandableNotesField> createState() => _ExpandableNotesFieldState();
}

class _ExpandableNotesFieldState extends State<ExpandableNotesField> {
  late TextEditingController _controller;
  bool _isExpanded = false;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _currentLength = _controller.text.length;
    _isExpanded = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      margin: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isExpanded ? null : 48,
            child: TextFormField(
              controller: _controller,
              enabled: widget.enabled,
              maxLines: _isExpanded ? (widget.maxLength != null ? 6 : null) : 1,
              maxLength: widget.maxLength,
              decoration: InputDecoration(
                hintText: widget.hint ?? 'Add notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _currentLength = value.length;
                  if (value.isNotEmpty && !_isExpanded) {
                    _isExpanded = true;
                  }
                });
                widget.onChanged?.call(value);
              },
            ),
          ),
          if (widget.maxLength != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$_currentLength/${widget.maxLength}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _currentLength > widget.maxLength!
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class NotesDisplay extends StatelessWidget {
  final String? notes;
  final String? label;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool showLabel;

  const NotesDisplay({
    super.key,
    this.notes,
    this.label,
    this.padding,
    this.margin,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    if (notes == null || notes!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabel && label != null) ...[
            Text(
              label!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            notes!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }
}
