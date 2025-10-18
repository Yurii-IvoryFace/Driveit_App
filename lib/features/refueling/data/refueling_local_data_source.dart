import 'dart:async';

import 'package:driveit_app/features/refueling/data/dto/refueling_entry_dto.dart';

/// Abstraction for locally persisted refueling entries.
abstract class RefuelingLocalDataSource {
  Stream<List<RefuelingEntryDto>> watchByVehicle(String vehicleId);

  Future<List<RefuelingEntryDto>> getByVehicle(String vehicleId);

  Future<void> upsert(RefuelingEntryDto dto);

  Future<void> remove(String id);
}
