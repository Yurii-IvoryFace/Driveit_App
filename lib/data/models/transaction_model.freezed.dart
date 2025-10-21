// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) {
  return _TransactionModel.fromJson(json);
}

/// @nodoc
mixin _$TransactionModel {
  String get id => throw _privateConstructorUsedError;
  String get vehicleId => throw _privateConstructorUsedError;
  TransactionType get type => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  double? get amount => throw _privateConstructorUsedError;
  String? get currency => throw _privateConstructorUsedError;
  int? get odometerKm =>
      throw _privateConstructorUsedError; // Refueling specific
  double? get volumeLiters => throw _privateConstructorUsedError;
  double? get pricePerLiter => throw _privateConstructorUsedError;
  String? get fuelType => throw _privateConstructorUsedError;
  bool? get isFullTank =>
      throw _privateConstructorUsedError; // Service specific
  String? get serviceType => throw _privateConstructorUsedError;
  String? get serviceProvider => throw _privateConstructorUsedError; // Common
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TransactionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionModelCopyWith<TransactionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionModelCopyWith<$Res> {
  factory $TransactionModelCopyWith(
    TransactionModel value,
    $Res Function(TransactionModel) then,
  ) = _$TransactionModelCopyWithImpl<$Res, TransactionModel>;
  @useResult
  $Res call({
    String id,
    String vehicleId,
    TransactionType type,
    DateTime date,
    double? amount,
    String? currency,
    int? odometerKm,
    double? volumeLiters,
    double? pricePerLiter,
    String? fuelType,
    bool? isFullTank,
    String? serviceType,
    String? serviceProvider,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$TransactionModelCopyWithImpl<$Res, $Val extends TransactionModel>
    implements $TransactionModelCopyWith<$Res> {
  _$TransactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vehicleId = null,
    Object? type = null,
    Object? date = null,
    Object? amount = freezed,
    Object? currency = freezed,
    Object? odometerKm = freezed,
    Object? volumeLiters = freezed,
    Object? pricePerLiter = freezed,
    Object? fuelType = freezed,
    Object? isFullTank = freezed,
    Object? serviceType = freezed,
    Object? serviceProvider = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            vehicleId: null == vehicleId
                ? _value.vehicleId
                : vehicleId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as TransactionType,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            amount: freezed == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double?,
            currency: freezed == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String?,
            odometerKm: freezed == odometerKm
                ? _value.odometerKm
                : odometerKm // ignore: cast_nullable_to_non_nullable
                      as int?,
            volumeLiters: freezed == volumeLiters
                ? _value.volumeLiters
                : volumeLiters // ignore: cast_nullable_to_non_nullable
                      as double?,
            pricePerLiter: freezed == pricePerLiter
                ? _value.pricePerLiter
                : pricePerLiter // ignore: cast_nullable_to_non_nullable
                      as double?,
            fuelType: freezed == fuelType
                ? _value.fuelType
                : fuelType // ignore: cast_nullable_to_non_nullable
                      as String?,
            isFullTank: freezed == isFullTank
                ? _value.isFullTank
                : isFullTank // ignore: cast_nullable_to_non_nullable
                      as bool?,
            serviceType: freezed == serviceType
                ? _value.serviceType
                : serviceType // ignore: cast_nullable_to_non_nullable
                      as String?,
            serviceProvider: freezed == serviceProvider
                ? _value.serviceProvider
                : serviceProvider // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TransactionModelImplCopyWith<$Res>
    implements $TransactionModelCopyWith<$Res> {
  factory _$$TransactionModelImplCopyWith(
    _$TransactionModelImpl value,
    $Res Function(_$TransactionModelImpl) then,
  ) = __$$TransactionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String vehicleId,
    TransactionType type,
    DateTime date,
    double? amount,
    String? currency,
    int? odometerKm,
    double? volumeLiters,
    double? pricePerLiter,
    String? fuelType,
    bool? isFullTank,
    String? serviceType,
    String? serviceProvider,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$TransactionModelImplCopyWithImpl<$Res>
    extends _$TransactionModelCopyWithImpl<$Res, _$TransactionModelImpl>
    implements _$$TransactionModelImplCopyWith<$Res> {
  __$$TransactionModelImplCopyWithImpl(
    _$TransactionModelImpl _value,
    $Res Function(_$TransactionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vehicleId = null,
    Object? type = null,
    Object? date = null,
    Object? amount = freezed,
    Object? currency = freezed,
    Object? odometerKm = freezed,
    Object? volumeLiters = freezed,
    Object? pricePerLiter = freezed,
    Object? fuelType = freezed,
    Object? isFullTank = freezed,
    Object? serviceType = freezed,
    Object? serviceProvider = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$TransactionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        vehicleId: null == vehicleId
            ? _value.vehicleId
            : vehicleId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as TransactionType,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        amount: freezed == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double?,
        currency: freezed == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String?,
        odometerKm: freezed == odometerKm
            ? _value.odometerKm
            : odometerKm // ignore: cast_nullable_to_non_nullable
                  as int?,
        volumeLiters: freezed == volumeLiters
            ? _value.volumeLiters
            : volumeLiters // ignore: cast_nullable_to_non_nullable
                  as double?,
        pricePerLiter: freezed == pricePerLiter
            ? _value.pricePerLiter
            : pricePerLiter // ignore: cast_nullable_to_non_nullable
                  as double?,
        fuelType: freezed == fuelType
            ? _value.fuelType
            : fuelType // ignore: cast_nullable_to_non_nullable
                  as String?,
        isFullTank: freezed == isFullTank
            ? _value.isFullTank
            : isFullTank // ignore: cast_nullable_to_non_nullable
                  as bool?,
        serviceType: freezed == serviceType
            ? _value.serviceType
            : serviceType // ignore: cast_nullable_to_non_nullable
                  as String?,
        serviceProvider: freezed == serviceProvider
            ? _value.serviceProvider
            : serviceProvider // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionModelImpl implements _TransactionModel {
  const _$TransactionModelImpl({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.date,
    this.amount,
    this.currency,
    this.odometerKm,
    this.volumeLiters,
    this.pricePerLiter,
    this.fuelType,
    this.isFullTank,
    this.serviceType,
    this.serviceProvider,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$TransactionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String vehicleId;
  @override
  final TransactionType type;
  @override
  final DateTime date;
  @override
  final double? amount;
  @override
  final String? currency;
  @override
  final int? odometerKm;
  // Refueling specific
  @override
  final double? volumeLiters;
  @override
  final double? pricePerLiter;
  @override
  final String? fuelType;
  @override
  final bool? isFullTank;
  // Service specific
  @override
  final String? serviceType;
  @override
  final String? serviceProvider;
  // Common
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'TransactionModel(id: $id, vehicleId: $vehicleId, type: $type, date: $date, amount: $amount, currency: $currency, odometerKm: $odometerKm, volumeLiters: $volumeLiters, pricePerLiter: $pricePerLiter, fuelType: $fuelType, isFullTank: $isFullTank, serviceType: $serviceType, serviceProvider: $serviceProvider, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.vehicleId, vehicleId) ||
                other.vehicleId == vehicleId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.odometerKm, odometerKm) ||
                other.odometerKm == odometerKm) &&
            (identical(other.volumeLiters, volumeLiters) ||
                other.volumeLiters == volumeLiters) &&
            (identical(other.pricePerLiter, pricePerLiter) ||
                other.pricePerLiter == pricePerLiter) &&
            (identical(other.fuelType, fuelType) ||
                other.fuelType == fuelType) &&
            (identical(other.isFullTank, isFullTank) ||
                other.isFullTank == isFullTank) &&
            (identical(other.serviceType, serviceType) ||
                other.serviceType == serviceType) &&
            (identical(other.serviceProvider, serviceProvider) ||
                other.serviceProvider == serviceProvider) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    vehicleId,
    type,
    date,
    amount,
    currency,
    odometerKm,
    volumeLiters,
    pricePerLiter,
    fuelType,
    isFullTank,
    serviceType,
    serviceProvider,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionModelImplCopyWith<_$TransactionModelImpl> get copyWith =>
      __$$TransactionModelImplCopyWithImpl<_$TransactionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionModelImplToJson(this);
  }
}

abstract class _TransactionModel implements TransactionModel {
  const factory _TransactionModel({
    required final String id,
    required final String vehicleId,
    required final TransactionType type,
    required final DateTime date,
    final double? amount,
    final String? currency,
    final int? odometerKm,
    final double? volumeLiters,
    final double? pricePerLiter,
    final String? fuelType,
    final bool? isFullTank,
    final String? serviceType,
    final String? serviceProvider,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$TransactionModelImpl;

  factory _TransactionModel.fromJson(Map<String, dynamic> json) =
      _$TransactionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get vehicleId;
  @override
  TransactionType get type;
  @override
  DateTime get date;
  @override
  double? get amount;
  @override
  String? get currency;
  @override
  int? get odometerKm; // Refueling specific
  @override
  double? get volumeLiters;
  @override
  double? get pricePerLiter;
  @override
  String? get fuelType;
  @override
  bool? get isFullTank; // Service specific
  @override
  String? get serviceType;
  @override
  String? get serviceProvider; // Common
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionModelImplCopyWith<_$TransactionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
