import 'package:driveit_app/features/vehicles/domain/vehicle_stat_type.dart';
import 'package:equatable/equatable.dart';

/// Domain entity representing a vehicle statistic entry.
class VehicleStat extends Equatable {
  const VehicleStat({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.value,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier for this statistic entry.
  final String id;

  /// ID of the vehicle this statistic belongs to.
  final String vehicleId;

  /// Type of statistic (odometer, service, insurance, etc.).
  final VehicleStatType type;

  /// The actual value - can be numeric (for odometer) or date (for service/insurance).
  final dynamic value;

  /// Optional notes about this statistic entry.
  final String? notes;

  /// When this statistic was first created.
  final DateTime? createdAt;

  /// When this statistic was last updated.
  final DateTime? updatedAt;

  /// Returns the numeric value if this is a numeric stat type.
  int? get numericValue => type.isNumericType ? value as int? : null;

  /// Returns the date value if this is a date stat type.
  DateTime? get dateValue => type.isDateType ? value as DateTime? : null;

  /// Returns a formatted string representation of the value.
  String get formattedValue {
    if (type.isNumericType && numericValue != null) {
      return '${numericValue!.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )} ${type.unit ?? ''}';
    }
    if (type.isDateType && dateValue != null) {
      // This will be formatted by the UI layer
      return dateValue.toString();
    }
    return value?.toString() ?? '';
  }

  VehicleStat copyWith({
    String? id,
    String? vehicleId,
    VehicleStatType? type,
    dynamic value,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleStat(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      value: value ?? this.value,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    type,
    value,
    notes,
    createdAt,
    updatedAt,
  ];
}

