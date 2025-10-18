import 'package:equatable/equatable.dart';

/// Supported fuel types for refueling entries.
class FuelType extends Equatable {
  const FuelType._(this.name, this.label);

  final String name;
  final String label;

  static const petrol = FuelType._('petrol', 'Petrol');
  static const diesel = FuelType._('diesel', 'Diesel');
  static const electric = FuelType._('electric', 'Electric');
  static const hybrid = FuelType._('hybrid', 'Hybrid');
  static const lpg = FuelType._('lpg', 'LPG');
  static const other = FuelType._('other', 'Other');

  static const values = <FuelType>[
    petrol,
    diesel,
    electric,
    hybrid,
    lpg,
    other,
  ];

  static FuelType fromSerialized(String value) {
    return values.firstWhere((type) => type.name == value, orElse: () => other);
  }

  @override
  List<Object?> get props => [name];
}
