import 'package:driveit_app/features/events/domain/vehicle_event.dart';
import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class QuickAddMenu extends StatelessWidget {
  const QuickAddMenu({
    super.key,
    required this.onAction,
    required this.onDismiss,
    this.visible = false,
  });

  final bool visible;
  final ValueChanged<QuickAddAction> onAction;
  final VoidCallback onDismiss;

  static final List<QuickAddAction> actions = [
    QuickAddAction(
      label: 'Odometer',
      icon: Icons.speed_outlined,
      color: Color(0xFFFDD835),
      type: VehicleEventType.odometer,
    ),
    QuickAddAction(
      label: 'Note',
      icon: Icons.sticky_note_2_outlined,
      color: Color(0xFFFFEA00),
      type: VehicleEventType.note,
    ),
    QuickAddAction(
      label: 'Income',
      icon: Icons.attach_money,
      color: Color(0xFF4CAF50),
      type: VehicleEventType.income,
    ),
    QuickAddAction(
      label: 'Service',
      icon: Icons.build_outlined,
      color: Color(0xFF42A5F5),
      type: VehicleEventType.service,
    ),
    QuickAddAction(
      label: 'Expense',
      icon: Icons.camera_alt_outlined,
      color: Color(0xFFEF5350),
      type: VehicleEventType.expense,
    ),
    QuickAddAction(
      label: 'Refuel',
      icon: Icons.local_gas_station_outlined,
      color: Color(0xFFFFA726),
      type: VehicleEventType.refuel,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 104,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(actions.length, (index) {
              final action = actions[index];
              return _QuickAddButton(
                action: action,
                onTap: () => onAction(action),
                isLast: index == actions.length - 1,
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({
    required this.action,
    required this.onTap,
    required this.isLast,
  });

  final QuickAddAction action;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: SizedBox(
        width: 220,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            side: BorderSide(color: action.color.withValues(alpha: 0.35)),
            foregroundColor: AppColors.textPrimary,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: Text(
                  action.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, color: action.color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickAddAction {
  const QuickAddAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.type,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VehicleEventType type;
}
