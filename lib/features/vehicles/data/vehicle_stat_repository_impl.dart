import 'dart:async';
import 'package:driveit_app/features/vehicles/domain/vehicle_stat.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_stat_repository.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_stat_type.dart';
import 'package:uuid/uuid.dart';

/// In-memory implementation of VehicleStatRepository.
/// This will be replaced with a proper database implementation later.
class VehicleStatRepositoryImpl implements VehicleStatRepository {
  VehicleStatRepositoryImpl({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;
  final Map<String, VehicleStat> _stats = {};
  final Map<String, StreamController<List<VehicleStat>>> _streamControllers = {};

  @override
  Future<List<VehicleStat>> fetchStats(String vehicleId) async {
    return _stats.values
        .where((stat) => stat.vehicleId == vehicleId)
        .toList()
      ..sort((a, b) => (b.updatedAt ?? b.createdAt ?? DateTime.now())
          .compareTo(a.updatedAt ?? a.createdAt ?? DateTime.now()));
  }

  @override
  Stream<List<VehicleStat>> watchStats(String vehicleId) {
    if (!_streamControllers.containsKey(vehicleId)) {
      _streamControllers[vehicleId] = StreamController<List<VehicleStat>>.broadcast();
    }
    
    // Emit current stats after a short delay to ensure the stream is ready
    Future.microtask(() => _emitStatsForVehicle(vehicleId));
    
    return _streamControllers[vehicleId]!.stream;
  }

  @override
  Future<void> saveStat(VehicleStat stat) async {
    final now = DateTime.now();
    final statToSave = stat.copyWith(
      id: stat.id.isEmpty ? _uuid.v4() : stat.id,
      updatedAt: now,
      createdAt: stat.createdAt ?? now,
    );
    
    _stats[statToSave.id] = statToSave;
    _emitStatsForVehicle(statToSave.vehicleId);
  }

  @override
  Future<void> deleteStat(String statId) async {
    final stat = _stats.remove(statId);
    if (stat != null) {
      _emitStatsForVehicle(stat.vehicleId);
    }
  }

  @override
  Future<VehicleStat?> getStat(String statId) async {
    return _stats[statId];
  }

  @override
  Future<VehicleStat?> getLatestStat(String vehicleId, String type) async {
    final stats = await fetchStats(vehicleId);
    final typeEnum = VehicleStatType.values.firstWhere(
      (t) => t.name == type,
      orElse: () => throw ArgumentError('Unknown stat type: $type'),
    );
    
    return stats
        .where((stat) => stat.type == typeEnum)
        .isNotEmpty
        ? stats.where((stat) => stat.type == typeEnum).first
        : null;
  }

  void _emitStatsForVehicle(String vehicleId) {
    final controller = _streamControllers[vehicleId];
    if (controller != null && !controller.isClosed) {
      final stats = _stats.values
          .where((stat) => stat.vehicleId == vehicleId)
          .toList()
        ..sort((a, b) => (b.updatedAt ?? b.createdAt ?? DateTime.now())
            .compareTo(a.updatedAt ?? a.createdAt ?? DateTime.now()));
      controller.add(stats);
    }
  }

  @override
  Future<void> ensureOdometerStat(String vehicleId, int odometerKm) async {
    final existingStats = await fetchStats(vehicleId);
    final existingOdometerStat = existingStats
        .where((stat) => stat.type == VehicleStatType.odometer)
        .firstOrNull;

    if (existingOdometerStat != null) {
      // Update existing odometer stat if the value has changed
      if (existingOdometerStat.numericValue != odometerKm) {
        final updatedStat = existingOdometerStat.copyWith(
          value: odometerKm,
          updatedAt: DateTime.now(),
        );
        await saveStat(updatedStat);
      }
    } else {
      // Create new odometer stat
      final now = DateTime.now();
      final odometerStat = VehicleStat(
        id: _uuid.v4(),
        vehicleId: vehicleId,
        type: VehicleStatType.odometer,
        value: odometerKm,
        notes: 'Current odometer reading',
        createdAt: now,
        updatedAt: now,
      );
      await saveStat(odometerStat);
    }
  }

  void dispose() {
    for (final controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
  }
}

