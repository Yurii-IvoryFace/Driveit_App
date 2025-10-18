import 'dart:async';

import 'package:driveit_app/features/vehicles/data/dto/vehicle_dto.dart';

/// Contract for persistence backed by a local server or embedded SQLite.
///
/// Replace the stub implementation once the server API is available.
abstract class VehicleLocalDataSource {
  Stream<List<VehicleDto>> watchAll();

  Future<List<VehicleDto>> getAll();

  Future<void> upsert(VehicleDto dto);

  Future<void> remove(String id);

  Future<void> markPrimary(String id);
}
