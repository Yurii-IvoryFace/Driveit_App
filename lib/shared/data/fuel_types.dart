import 'dart:collection';

import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:flutter/material.dart';

/// Central catalog of supported fuel types plus helpers to build menus.
class FuelTypes {
  const FuelTypes._();

  /// Default ordered list of fuel type labels.
  static const List<String> defaults = <String>[
    'Petrol',
    'Diesel',
    'LPG',
    'CNG',
    'Electric',
    'Hybrid',
    'Hydrogen',
    'Other',
  ];

  /// Builds dropdown menu entries for the provided [types] (or [defaults]).
  static List<DropdownMenuEntry<String>> menuEntries([List<String>? types]) {
    final values = types ?? defaults;
    return values
        .map((type) => DropdownMenuEntry<String>(value: type, label: type))
        .toList(growable: false);
  }

  /// Computes the available fuel type options for [vehicle].
  ///
  /// Returns the vehicle's primary/secondary fuel types (if defined) plus the
  /// [initial] value (useful when editing an event that contains a custom fuel
  /// type). Falls back to [defaults] when no vehicle data is present.
  static List<String> optionsForVehicle(Vehicle vehicle, {String? initial}) {
    final normalized = LinkedHashSet<String>(
      equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
      hashCode: (value) => value.toLowerCase().hashCode,
    );

    void add(String? value) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) return;
      normalized.add(trimmed);
    }

    add(initial);
    add(vehicle.fuelType);
    add(vehicle.secondaryFuelType);

    if (normalized.isEmpty) {
      return defaults;
    }

    return normalized.toList(growable: false);
  }
}
