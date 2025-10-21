enum FuelType { gasoline, diesel, electric, hybrid, lpg, cng, other }

extension FuelTypeExtension on FuelType {
  String get displayName {
    switch (this) {
      case FuelType.gasoline:
        return 'Gasoline';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.electric:
        return 'Electric';
      case FuelType.hybrid:
        return 'Hybrid';
      case FuelType.lpg:
        return 'LPG';
      case FuelType.cng:
        return 'CNG';
      case FuelType.other:
        return 'Other';
    }
  }

  String get unit {
    switch (this) {
      case FuelType.gasoline:
      case FuelType.diesel:
      case FuelType.lpg:
      case FuelType.cng:
        return 'L';
      case FuelType.electric:
        return 'kWh';
      case FuelType.hybrid:
        return 'L/kWh';
      case FuelType.other:
        return 'L';
    }
  }

  String get icon {
    switch (this) {
      case FuelType.gasoline:
        return '⛽';
      case FuelType.diesel:
        return '🛢️';
      case FuelType.electric:
        return '🔌';
      case FuelType.hybrid:
        return '🔋';
      case FuelType.lpg:
        return '🔥';
      case FuelType.cng:
        return '💨';
      case FuelType.other:
        return '⛽';
    }
  }
}
