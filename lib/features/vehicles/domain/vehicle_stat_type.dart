import 'package:flutter/material.dart';

/// Enumeration of available vehicle statistic types.
enum VehicleStatType {
  odometer('Odometer', 'km', Icons.speed_outlined),
  nextService('Next service', null, Icons.build_circle_outlined),
  insurance('Insurance', null, Icons.shield_outlined),
  registration('Registration', null, Icons.assignment_turned_in_outlined),
  lastService('Last service', null, Icons.build_outlined),
  purchaseDate('Purchase date', null, Icons.shopping_cart_outlined),
  saleDate('Sale date', null, Icons.sell_outlined),
  custom('Custom', null, Icons.info_outline);

  const VehicleStatType(this.label, this.unit, this.icon);

  final String label;
  final String? unit;
  final IconData icon;

  /// Returns true if this stat type requires a date value.
  bool get isDateType => this == nextService || 
                        this == insurance || 
                        this == registration || 
                        this == lastService || 
                        this == purchaseDate || 
                        this == saleDate;

  /// Returns true if this stat type requires a numeric value.
  bool get isNumericType => this == odometer;

  /// Returns true if this stat type is a custom type.
  bool get isCustomType => this == custom;

  /// Returns true if this stat type is editable by user.
  bool get isUserEditable => true; // All stat types are user editable
}
