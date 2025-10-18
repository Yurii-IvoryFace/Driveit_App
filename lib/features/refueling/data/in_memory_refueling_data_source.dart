import 'dart:async';

import 'package:driveit_app/features/refueling/data/dto/refueling_entry_dto.dart';
import 'package:driveit_app/features/refueling/data/refueling_local_data_source.dart';
import 'package:uuid/uuid.dart';

typedef VehicleSeed = ({String id, double odometerKm, String fuelType});

class InMemoryRefuelingDataSource implements RefuelingLocalDataSource {
  InMemoryRefuelingDataSource({
    List<RefuelingEntryDto>? seed,
    List<VehicleSeed>? vehicleSeeds,
  }) {
    _entries = seed != null
        ? List<RefuelingEntryDto>.from(seed)
        : <RefuelingEntryDto>[];
    if ((seed == null || seed.isEmpty) &&
        vehicleSeeds != null &&
        vehicleSeeds.isNotEmpty) {
      _entries.addAll(_buildSeedEntries(vehicleSeeds));
    }

    _controller = StreamController<List<RefuelingEntryDto>>.broadcast(
      onListen: () => _controller.add(List.unmodifiable(_entries)),
    );
  }

  final _uuid = const Uuid();
  late List<RefuelingEntryDto> _entries;
  late final StreamController<List<RefuelingEntryDto>> _controller;

  @override
  Stream<List<RefuelingEntryDto>> watchByVehicle(String vehicleId) {
    return _controller.stream.map((entries) => _filter(entries, vehicleId));
  }

  @override
  Future<List<RefuelingEntryDto>> getByVehicle(String vehicleId) async {
    return _filter(_entries, vehicleId);
  }

  @override
  Future<void> upsert(RefuelingEntryDto dto) async {
    final index = _entries.indexWhere((entry) => entry.id == dto.id);
    if (index == -1) {
      _entries = [..._entries, dto];
    } else {
      _entries = [
        ..._entries.sublist(0, index),
        dto,
        ..._entries.sublist(index + 1),
      ];
    }
    _emit();
  }

  @override
  Future<void> remove(String id) async {
    _entries = _entries.where((entry) => entry.id != id).toList();
    _emit();
  }

  void dispose() {
    _controller.close();
  }

  void _emit() {
    if (!_controller.hasListener) return;
    _controller.add(List.unmodifiable(_entries));
  }

  List<RefuelingEntryDto> _filter(
    List<RefuelingEntryDto> source,
    String vehicleId,
  ) {
    final filtered =
        source.where((entry) => entry.vehicleId == vehicleId).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  List<RefuelingEntryDto> _buildSeedEntries(List<VehicleSeed> seeds) {
    final now = DateTime.now();
    final generated = <RefuelingEntryDto>[];

    for (var i = 0; i < seeds.length; i++) {
      final seed = seeds[i];
      final baseOdometer = seed.odometerKm;

      if (i == 0) {
        generated.addAll([
          _createEntry(
            vehicleId: seed.id,
            date: now.subtract(const Duration(days: 4)),
            odometer: baseOdometer,
            volume: 41.8,
            total: 64.27,
            station: 'Shell Downtown',
            fuelType: seed.fuelType,
          ),
          _createEntry(
            vehicleId: seed.id,
            date: now.subtract(const Duration(days: 19)),
            odometer: baseOdometer - 540,
            volume: 42.6,
            total: 66.91,
            station: 'BP Riverside',
            fuelType: seed.fuelType,
          ),
          _createEntry(
            vehicleId: seed.id,
            date: now.subtract(const Duration(days: 33)),
            odometer: baseOdometer - 1120,
            volume: 40.9,
            total: 62.35,
            station: 'Shell Downtown',
            fuelType: seed.fuelType,
          ),
        ]);
      } else if (i == 1) {
        generated.addAll([
          _createEntry(
            vehicleId: seed.id,
            date: now.subtract(const Duration(days: 8)),
            odometer: baseOdometer,
            volume: 32.4,
            total: 54.88,
            station: 'Costco Fuel',
            fuelType: seed.fuelType,
          ),
          _createEntry(
            vehicleId: seed.id,
            date: now.subtract(const Duration(days: 27)),
            odometer: baseOdometer - 410,
            volume: 30.7,
            total: 51.21,
            station: 'Chevron 5th Ave',
            fuelType: seed.fuelType,
          ),
        ]);
      } else {
        generated.add(
          _createEntry(
            vehicleId: seed.id,
            date: now.subtract(Duration(days: 6 * (i + 1))),
            odometer: baseOdometer - 320,
            volume: 28.5,
            total: 46.32,
            station: 'General Fuel',
            fuelType: seed.fuelType,
          ),
        );
      }
    }

    generated.sort((a, b) => b.date.compareTo(a.date));
    return generated;
  }

  RefuelingEntryDto _createEntry({
    required String vehicleId,
    required DateTime date,
    required double odometer,
    required double volume,
    required double total,
    required String fuelType,
    String? station,
  }) {
    return RefuelingEntryDto(
      id: _uuid.v4(),
      vehicleId: vehicleId,
      date: date,
      odometerKm: odometer,
      volumeLiters: volume,
      totalCost: total,
      pricePerLiter: total / volume,
      fuelType: fuelType,
      isFullFill: true,
      station: station,
    );
  }
}
