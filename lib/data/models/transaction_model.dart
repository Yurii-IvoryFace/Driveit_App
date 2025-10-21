import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

enum TransactionType {
  refueling,
  maintenance,
  insurance,
  parking,
  toll,
  carWash,
  other,
}

@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String id,
    required String vehicleId,
    required TransactionType type,
    required DateTime date,
    double? amount,
    String? currency,
    int? odometerKm,

    // Refueling specific
    double? volumeLiters,
    double? pricePerLiter,
    String? fuelType,
    bool? isFullTank,

    // Service specific
    String? serviceType,
    String? serviceProvider,

    // Common
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
}
