// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionModelImpl _$$TransactionModelImplFromJson(
  Map<String, dynamic> json,
) => _$TransactionModelImpl(
  id: json['id'] as String,
  vehicleId: json['vehicleId'] as String,
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  date: DateTime.parse(json['date'] as String),
  amount: (json['amount'] as num?)?.toDouble(),
  currency: json['currency'] as String?,
  odometerKm: (json['odometerKm'] as num?)?.toInt(),
  volumeLiters: (json['volumeLiters'] as num?)?.toDouble(),
  pricePerLiter: (json['pricePerLiter'] as num?)?.toDouble(),
  fuelType: json['fuelType'] as String?,
  isFullTank: json['isFullTank'] as bool?,
  serviceType: json['serviceType'] as String?,
  serviceProvider: json['serviceProvider'] as String?,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$TransactionModelImplToJson(
  _$TransactionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'vehicleId': instance.vehicleId,
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'date': instance.date.toIso8601String(),
  'amount': instance.amount,
  'currency': instance.currency,
  'odometerKm': instance.odometerKm,
  'volumeLiters': instance.volumeLiters,
  'pricePerLiter': instance.pricePerLiter,
  'fuelType': instance.fuelType,
  'isFullTank': instance.isFullTank,
  'serviceType': instance.serviceType,
  'serviceProvider': instance.serviceProvider,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$TransactionTypeEnumMap = {
  TransactionType.refueling: 'refueling',
  TransactionType.maintenance: 'maintenance',
  TransactionType.insurance: 'insurance',
  TransactionType.parking: 'parking',
  TransactionType.toll: 'toll',
  TransactionType.carWash: 'carWash',
  TransactionType.other: 'other',
};
