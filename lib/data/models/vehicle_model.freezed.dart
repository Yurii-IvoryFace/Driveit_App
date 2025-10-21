// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VehicleModel _$VehicleModelFromJson(Map<String, dynamic> json) {
  return _VehicleModel.fromJson(json);
}

/// @nodoc
mixin _$VehicleModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get make => throw _privateConstructorUsedError;
  String get model => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  String? get vin => throw _privateConstructorUsedError;
  String? get licensePlate => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  bool get isPrimary => throw _privateConstructorUsedError;
  String? get fuelType => throw _privateConstructorUsedError;
  int? get odometerKm => throw _privateConstructorUsedError;
  DateTime? get purchaseDate => throw _privateConstructorUsedError;
  double? get purchasePrice => throw _privateConstructorUsedError;
  int? get purchaseOdometerKm => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this VehicleModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VehicleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VehicleModelCopyWith<VehicleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VehicleModelCopyWith<$Res> {
  factory $VehicleModelCopyWith(
    VehicleModel value,
    $Res Function(VehicleModel) then,
  ) = _$VehicleModelCopyWithImpl<$Res, VehicleModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String make,
    String model,
    int year,
    String? vin,
    String? licensePlate,
    String? photoUrl,
    bool isPrimary,
    String? fuelType,
    int? odometerKm,
    DateTime? purchaseDate,
    double? purchasePrice,
    int? purchaseOdometerKm,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$VehicleModelCopyWithImpl<$Res, $Val extends VehicleModel>
    implements $VehicleModelCopyWith<$Res> {
  _$VehicleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VehicleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? make = null,
    Object? model = null,
    Object? year = null,
    Object? vin = freezed,
    Object? licensePlate = freezed,
    Object? photoUrl = freezed,
    Object? isPrimary = null,
    Object? fuelType = freezed,
    Object? odometerKm = freezed,
    Object? purchaseDate = freezed,
    Object? purchasePrice = freezed,
    Object? purchaseOdometerKm = freezed,
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
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            make: null == make
                ? _value.make
                : make // ignore: cast_nullable_to_non_nullable
                      as String,
            model: null == model
                ? _value.model
                : model // ignore: cast_nullable_to_non_nullable
                      as String,
            year: null == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int,
            vin: freezed == vin
                ? _value.vin
                : vin // ignore: cast_nullable_to_non_nullable
                      as String?,
            licensePlate: freezed == licensePlate
                ? _value.licensePlate
                : licensePlate // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            isPrimary: null == isPrimary
                ? _value.isPrimary
                : isPrimary // ignore: cast_nullable_to_non_nullable
                      as bool,
            fuelType: freezed == fuelType
                ? _value.fuelType
                : fuelType // ignore: cast_nullable_to_non_nullable
                      as String?,
            odometerKm: freezed == odometerKm
                ? _value.odometerKm
                : odometerKm // ignore: cast_nullable_to_non_nullable
                      as int?,
            purchaseDate: freezed == purchaseDate
                ? _value.purchaseDate
                : purchaseDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            purchasePrice: freezed == purchasePrice
                ? _value.purchasePrice
                : purchasePrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            purchaseOdometerKm: freezed == purchaseOdometerKm
                ? _value.purchaseOdometerKm
                : purchaseOdometerKm // ignore: cast_nullable_to_non_nullable
                      as int?,
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
abstract class _$$VehicleModelImplCopyWith<$Res>
    implements $VehicleModelCopyWith<$Res> {
  factory _$$VehicleModelImplCopyWith(
    _$VehicleModelImpl value,
    $Res Function(_$VehicleModelImpl) then,
  ) = __$$VehicleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String make,
    String model,
    int year,
    String? vin,
    String? licensePlate,
    String? photoUrl,
    bool isPrimary,
    String? fuelType,
    int? odometerKm,
    DateTime? purchaseDate,
    double? purchasePrice,
    int? purchaseOdometerKm,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$VehicleModelImplCopyWithImpl<$Res>
    extends _$VehicleModelCopyWithImpl<$Res, _$VehicleModelImpl>
    implements _$$VehicleModelImplCopyWith<$Res> {
  __$$VehicleModelImplCopyWithImpl(
    _$VehicleModelImpl _value,
    $Res Function(_$VehicleModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VehicleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? make = null,
    Object? model = null,
    Object? year = null,
    Object? vin = freezed,
    Object? licensePlate = freezed,
    Object? photoUrl = freezed,
    Object? isPrimary = null,
    Object? fuelType = freezed,
    Object? odometerKm = freezed,
    Object? purchaseDate = freezed,
    Object? purchasePrice = freezed,
    Object? purchaseOdometerKm = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$VehicleModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        make: null == make
            ? _value.make
            : make // ignore: cast_nullable_to_non_nullable
                  as String,
        model: null == model
            ? _value.model
            : model // ignore: cast_nullable_to_non_nullable
                  as String,
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
        vin: freezed == vin
            ? _value.vin
            : vin // ignore: cast_nullable_to_non_nullable
                  as String?,
        licensePlate: freezed == licensePlate
            ? _value.licensePlate
            : licensePlate // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        isPrimary: null == isPrimary
            ? _value.isPrimary
            : isPrimary // ignore: cast_nullable_to_non_nullable
                  as bool,
        fuelType: freezed == fuelType
            ? _value.fuelType
            : fuelType // ignore: cast_nullable_to_non_nullable
                  as String?,
        odometerKm: freezed == odometerKm
            ? _value.odometerKm
            : odometerKm // ignore: cast_nullable_to_non_nullable
                  as int?,
        purchaseDate: freezed == purchaseDate
            ? _value.purchaseDate
            : purchaseDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        purchasePrice: freezed == purchasePrice
            ? _value.purchasePrice
            : purchasePrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        purchaseOdometerKm: freezed == purchaseOdometerKm
            ? _value.purchaseOdometerKm
            : purchaseOdometerKm // ignore: cast_nullable_to_non_nullable
                  as int?,
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
class _$VehicleModelImpl implements _VehicleModel {
  const _$VehicleModelImpl({
    required this.id,
    required this.name,
    required this.make,
    required this.model,
    required this.year,
    this.vin,
    this.licensePlate,
    this.photoUrl,
    this.isPrimary = false,
    this.fuelType,
    this.odometerKm,
    this.purchaseDate,
    this.purchasePrice,
    this.purchaseOdometerKm,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$VehicleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VehicleModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String make;
  @override
  final String model;
  @override
  final int year;
  @override
  final String? vin;
  @override
  final String? licensePlate;
  @override
  final String? photoUrl;
  @override
  @JsonKey()
  final bool isPrimary;
  @override
  final String? fuelType;
  @override
  final int? odometerKm;
  @override
  final DateTime? purchaseDate;
  @override
  final double? purchasePrice;
  @override
  final int? purchaseOdometerKm;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'VehicleModel(id: $id, name: $name, make: $make, model: $model, year: $year, vin: $vin, licensePlate: $licensePlate, photoUrl: $photoUrl, isPrimary: $isPrimary, fuelType: $fuelType, odometerKm: $odometerKm, purchaseDate: $purchaseDate, purchasePrice: $purchasePrice, purchaseOdometerKm: $purchaseOdometerKm, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VehicleModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.make, make) || other.make == make) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.vin, vin) || other.vin == vin) &&
            (identical(other.licensePlate, licensePlate) ||
                other.licensePlate == licensePlate) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary) &&
            (identical(other.fuelType, fuelType) ||
                other.fuelType == fuelType) &&
            (identical(other.odometerKm, odometerKm) ||
                other.odometerKm == odometerKm) &&
            (identical(other.purchaseDate, purchaseDate) ||
                other.purchaseDate == purchaseDate) &&
            (identical(other.purchasePrice, purchasePrice) ||
                other.purchasePrice == purchasePrice) &&
            (identical(other.purchaseOdometerKm, purchaseOdometerKm) ||
                other.purchaseOdometerKm == purchaseOdometerKm) &&
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
    name,
    make,
    model,
    year,
    vin,
    licensePlate,
    photoUrl,
    isPrimary,
    fuelType,
    odometerKm,
    purchaseDate,
    purchasePrice,
    purchaseOdometerKm,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of VehicleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VehicleModelImplCopyWith<_$VehicleModelImpl> get copyWith =>
      __$$VehicleModelImplCopyWithImpl<_$VehicleModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VehicleModelImplToJson(this);
  }
}

abstract class _VehicleModel implements VehicleModel {
  const factory _VehicleModel({
    required final String id,
    required final String name,
    required final String make,
    required final String model,
    required final int year,
    final String? vin,
    final String? licensePlate,
    final String? photoUrl,
    final bool isPrimary,
    final String? fuelType,
    final int? odometerKm,
    final DateTime? purchaseDate,
    final double? purchasePrice,
    final int? purchaseOdometerKm,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$VehicleModelImpl;

  factory _VehicleModel.fromJson(Map<String, dynamic> json) =
      _$VehicleModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get make;
  @override
  String get model;
  @override
  int get year;
  @override
  String? get vin;
  @override
  String? get licensePlate;
  @override
  String? get photoUrl;
  @override
  bool get isPrimary;
  @override
  String? get fuelType;
  @override
  int? get odometerKm;
  @override
  DateTime? get purchaseDate;
  @override
  double? get purchasePrice;
  @override
  int? get purchaseOdometerKm;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of VehicleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VehicleModelImplCopyWith<_$VehicleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
