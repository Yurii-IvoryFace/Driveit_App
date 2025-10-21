import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_model.freezed.dart';
part 'vehicle_model.g.dart';

@freezed
class VehicleModel with _$VehicleModel {
  const factory VehicleModel({
    required String id,
    required String name,
    required String make,
    required String model,
    required int year,
    String? vin,
    String? licensePlate,
    String? photoUrl,
    @Default(false) bool isPrimary,
    String? fuelType,
    int? odometerKm,
    DateTime? purchaseDate,
    double? purchasePrice,
    int? purchaseOdometerKm,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _VehicleModel;

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);
}
