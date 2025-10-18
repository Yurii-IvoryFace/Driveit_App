import 'package:driveit_app/features/events/domain/vehicle_event.dart';
import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class VehicleEventVisual {
  const VehicleEventVisual({required this.color, required this.icon});

  final Color color;
  final IconData icon;
}

const VehicleEventVisual _defaultVisual = VehicleEventVisual(
  color: AppColors.accent,
  icon: Icons.event_note_outlined,
);

const Map<VehicleEventType, VehicleEventVisual> _visualMap = {
  VehicleEventType.odometer: VehicleEventVisual(
    color: Color(0xFFFDD835),
    icon: Icons.speed_outlined,
  ),
  VehicleEventType.note: VehicleEventVisual(
    color: Color(0xFFFFEA00),
    icon: Icons.sticky_note_2_outlined,
  ),
  VehicleEventType.income: VehicleEventVisual(
    color: Color(0xFF4CAF50),
    icon: Icons.attach_money,
  ),
  VehicleEventType.service: VehicleEventVisual(
    color: Color(0xFF42A5F5),
    icon: Icons.build_outlined,
  ),
  VehicleEventType.expense: VehicleEventVisual(
    color: Color(0xFFEF5350),
    icon: Icons.receipt_long_outlined,
  ),
  VehicleEventType.refuel: VehicleEventVisual(
    color: Color(0xFFFFA726),
    icon: Icons.local_gas_station_outlined,
  ),
};

VehicleEventVisual resolveEventVisual(VehicleEventType type) {
  return _visualMap[type] ?? _defaultVisual;
}
