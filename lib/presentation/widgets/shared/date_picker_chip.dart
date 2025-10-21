import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DatePickerChip extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime?>? onDateChanged;
  final String? label;
  final IconData? icon;
  final bool showIcon;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const DatePickerChip({
    super.key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateChanged,
    this.label,
    this.icon,
    this.showIcon = true,
    this.padding,
    this.margin,
  });

  @override
  State<DatePickerChip> createState() => _DatePickerChipState();
}

class _DatePickerChipState extends State<DatePickerChip> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(2000),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onDateChanged?.call(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: Material(
        color: _selectedDate != null ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        elevation: _selectedDate != null ? 2 : 0,
        child: InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding:
                widget.padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showIcon) ...[
                  Icon(
                    widget.icon ?? Icons.calendar_today,
                    size: 16,
                    color: _selectedDate != null
                        ? AppColors.onPrimary
                        : AppColors.onSurface,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  _selectedDate != null
                      ? _formatDate(_selectedDate!)
                      : (widget.label ?? 'Select Date'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _selectedDate != null
                        ? AppColors.onPrimary
                        : AppColors.onSurface,
                    fontWeight: _selectedDate != null
                        ? FontWeight.w600
                        : FontWeight.w500,
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

class DateRangePickerChip extends StatefulWidget {
  final DateTimeRange? initialDateRange;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTimeRange?>? onDateRangeChanged;
  final String? label;
  final IconData? icon;
  final bool showIcon;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const DateRangePickerChip({
    super.key,
    this.initialDateRange,
    this.firstDate,
    this.lastDate,
    this.onDateRangeChanged,
    this.label,
    this.icon,
    this.showIcon = true,
    this.padding,
    this.margin,
  });

  @override
  State<DateRangePickerChip> createState() => _DateRangePickerChipState();
}

class _DateRangePickerChipState extends State<DateRangePickerChip> {
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _selectedDateRange = widget.initialDateRange;
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: widget.firstDate ?? DateTime(2000),
      lastDate: widget.lastDate ?? DateTime(2100),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      widget.onDateRangeChanged?.call(picked);
    }
  }

  String _formatDateRange(DateTimeRange range) {
    final start = range.start;
    final end = range.end;
    return '${start.day.toString().padLeft(2, '0')}.${start.month.toString().padLeft(2, '0')}.${start.year} - ${end.day.toString().padLeft(2, '0')}.${end.month.toString().padLeft(2, '0')}.${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: Material(
        color: _selectedDateRange != null
            ? AppColors.primary
            : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        elevation: _selectedDateRange != null ? 2 : 0,
        child: InkWell(
          onTap: _selectDateRange,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding:
                widget.padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showIcon) ...[
                  Icon(
                    widget.icon ?? Icons.date_range,
                    size: 16,
                    color: _selectedDateRange != null
                        ? AppColors.onPrimary
                        : AppColors.onSurface,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  _selectedDateRange != null
                      ? _formatDateRange(_selectedDateRange!)
                      : (widget.label ?? 'Select Date Range'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _selectedDateRange != null
                        ? AppColors.onPrimary
                        : AppColors.onSurface,
                    fontWeight: _selectedDateRange != null
                        ? FontWeight.w600
                        : FontWeight.w500,
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
