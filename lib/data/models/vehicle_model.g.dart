// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VehicleModelImpl _$$VehicleModelImplFromJson(Map<String, dynamic> json) =>
    _$VehicleModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: (json['year'] as num).toInt(),
      vin: json['vin'] as String?,
      licensePlate: json['licensePlate'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
      fuelType: json['fuelType'] as String?,
      odometerKm: (json['odometerKm'] as num?)?.toInt(),
      purchaseDate: json['purchaseDate'] == null
          ? null
          : DateTime.parse(json['purchaseDate'] as String),
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
      purchaseOdometerKm: (json['purchaseOdometerKm'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$VehicleModelImplToJson(_$VehicleModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'vin': instance.vin,
      'licensePlate': instance.licensePlate,
      'photoUrl': instance.photoUrl,
      'isPrimary': instance.isPrimary,
      'fuelType': instance.fuelType,
      'odometerKm': instance.odometerKm,
      'purchaseDate': instance.purchaseDate?.toIso8601String(),
      'purchasePrice': instance.purchasePrice,
      'purchaseOdometerKm': instance.purchaseOdometerKm,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
