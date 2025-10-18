import 'package:driveit_app/features/refueling/domain/fuel_type.dart';
import 'package:driveit_app/features/refueling/domain/refueling_entry.dart';

class RefuelingEntryDto {
  RefuelingEntryDto({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.odometerKm,
    required this.volumeLiters,
    required this.totalCost,
    required this.fuelType,
    required this.isFullFill,
    this.pricePerLiter,
    this.station,
    this.notes,
  });

  final String id;
  final String vehicleId;
  final DateTime date;
  final double odometerKm;
  final double volumeLiters;
  final double totalCost;
  final double? pricePerLiter;
  final String fuelType;
  final bool isFullFill;
  final String? station;
  final String? notes;

  RefuelingEntry toDomain() {
    return RefuelingEntry(
      id: id,
      vehicleId: vehicleId,
      date: date,
      odometerKm: odometerKm,
      volumeLiters: volumeLiters,
      totalCost: totalCost,
      pricePerLiter: pricePerLiter,
      fuelType: FuelType.fromSerialized(fuelType),
      isFullFill: isFullFill,
      station: station,
      notes: notes,
    );
  }

  factory RefuelingEntryDto.fromDomain(RefuelingEntry entry) {
    return RefuelingEntryDto(
      id: entry.id,
      vehicleId: entry.vehicleId,
      date: entry.date,
      odometerKm: entry.odometerKm,
      volumeLiters: entry.volumeLiters,
      totalCost: entry.totalCost,
      pricePerLiter: entry.pricePerLiter,
      fuelType: entry.fuelType.name,
      isFullFill: entry.isFullFill,
      station: entry.station,
      notes: entry.notes,
    );
  }
}
