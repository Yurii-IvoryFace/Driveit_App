import 'package:flutter/foundation.dart';

enum VehicleEventType { odometer, note, income, service, expense, refuel }

enum VehicleEventAttachmentType { photo, document }

@immutable
class VehicleEventAttachment {
  VehicleEventAttachment({
    required this.id,
    required this.type,
    required this.name,
    required this.dataUrl,
    required this.sizeBytes,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  final String id;
  final VehicleEventAttachmentType type;
  final String name;
  final String dataUrl;
  final int sizeBytes;
  final DateTime addedAt;

  VehicleEventAttachment copyWith({
    String? id,
    VehicleEventAttachmentType? type,
    String? name,
    String? dataUrl,
    int? sizeBytes,
    DateTime? addedAt,
  }) {
    return VehicleEventAttachment(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      dataUrl: dataUrl ?? this.dataUrl,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

@immutable
class VehicleEvent {
  VehicleEvent({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.title,
    required this.occurredAt,
    this.location,
    this.odometerKm,
    this.amount,
    this.currency,
    this.serviceType,
    this.fuelType,
    this.volumeLiters,
    this.pricePerLiter,
    this.isFullTank,
    this.notes,
    this.attachments = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String vehicleId;
  final VehicleEventType type;
  final String title;
  final DateTime occurredAt;
  final String? location;
  final int? odometerKm;
  final double? amount;
  final String? currency;
  final String? serviceType;
  final String? fuelType;
  final double? volumeLiters;
  final double? pricePerLiter;
  final bool? isFullTank;
  final String? notes;
  final List<VehicleEventAttachment> attachments;
  final DateTime createdAt;

  bool get hasAttachments => attachments.isNotEmpty;

  VehicleEvent copyWith({
    String? id,
    String? vehicleId,
    VehicleEventType? type,
    String? title,
    DateTime? occurredAt,
    String? location,
    int? odometerKm,
    double? amount,
    String? currency,
    String? serviceType,
    String? fuelType,
    double? volumeLiters,
    double? pricePerLiter,
    bool? isFullTank,
    String? notes,
    List<VehicleEventAttachment>? attachments,
    DateTime? createdAt,
  }) {
    return VehicleEvent(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      title: title ?? this.title,
      occurredAt: occurredAt ?? this.occurredAt,
      location: location ?? this.location,
      odometerKm: odometerKm ?? this.odometerKm,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      serviceType: serviceType ?? this.serviceType,
      fuelType: fuelType ?? this.fuelType,
      volumeLiters: volumeLiters ?? this.volumeLiters,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      isFullTank: isFullTank ?? this.isFullTank,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
