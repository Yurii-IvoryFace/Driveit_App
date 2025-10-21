import '../entities/refueling_entry.dart';
import '../entities/refueling_summary.dart';
import '../repositories/refueling_repository.dart';

/// Use case for getting all refueling entries
class GetRefuelingEntries {
  final RefuelingRepository _repository;

  GetRefuelingEntries(this._repository);

  Future<List<RefuelingEntry>> call() async {
    return await _repository.getRefuelingEntries();
  }
}

/// Use case for watching refueling entries
class WatchRefuelingEntries {
  final RefuelingRepository _repository;

  WatchRefuelingEntries(this._repository);

  Stream<List<RefuelingEntry>> call() {
    return _repository.watchRefuelingEntries();
  }
}

/// Use case for getting refueling entries by vehicle
class GetRefuelingEntriesByVehicle {
  final RefuelingRepository _repository;

  GetRefuelingEntriesByVehicle(this._repository);

  Future<List<RefuelingEntry>> call(String vehicleId) async {
    return await _repository.getRefuelingEntriesByVehicle(vehicleId);
  }
}

/// Use case for watching refueling entries by vehicle
class WatchRefuelingEntriesByVehicle {
  final RefuelingRepository _repository;

  WatchRefuelingEntriesByVehicle(this._repository);

  Stream<List<RefuelingEntry>> call(String vehicleId) {
    return _repository.watchRefuelingEntriesByVehicle(vehicleId);
  }
}

/// Use case for getting a single refueling entry
class GetRefuelingEntry {
  final RefuelingRepository _repository;

  GetRefuelingEntry(this._repository);

  Future<RefuelingEntry?> call(String id) async {
    return await _repository.getRefuelingEntry(id);
  }
}

/// Use case for adding a new refueling entry
class AddRefuelingEntry {
  final RefuelingRepository _repository;

  AddRefuelingEntry(this._repository);

  Future<void> call(RefuelingEntry entry) async {
    await _repository.addRefuelingEntry(entry);
  }
}

/// Use case for updating a refueling entry
class UpdateRefuelingEntry {
  final RefuelingRepository _repository;

  UpdateRefuelingEntry(this._repository);

  Future<void> call(RefuelingEntry entry) async {
    await _repository.updateRefuelingEntry(entry);
  }
}

/// Use case for deleting a refueling entry
class DeleteRefuelingEntry {
  final RefuelingRepository _repository;

  DeleteRefuelingEntry(this._repository);

  Future<void> call(String id) async {
    await _repository.deleteRefuelingEntry(id);
  }
}

/// Use case for getting refueling summary
class GetRefuelingSummary {
  final RefuelingRepository _repository;

  GetRefuelingSummary(this._repository);

  Future<RefuelingSummary> call(String vehicleId) async {
    return await _repository.getRefuelingSummary(vehicleId);
  }
}

/// Use case for calculating fuel efficiency
class CalculateFuelEfficiency {
  final RefuelingRepository _repository;

  CalculateFuelEfficiency(this._repository);

  Future<double> call({
    required String vehicleId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _repository.calculateFuelEfficiency(
      vehicleId: vehicleId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

/// Use case for getting refueling statistics
class GetRefuelingStatistics {
  final RefuelingRepository _repository;

  GetRefuelingStatistics(this._repository);

  Future<Map<String, dynamic>> call({
    required String vehicleId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getRefuelingStatistics(
      vehicleId: vehicleId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

/// Use case for getting recent refueling entries
class GetRecentRefuelingEntries {
  final RefuelingRepository _repository;

  GetRecentRefuelingEntries(this._repository);

  Future<List<RefuelingEntry>> call({
    required String vehicleId,
    int limit = 10,
  }) async {
    return await _repository.getRecentRefuelingEntries(
      vehicleId: vehicleId,
      limit: limit,
    );
  }
}

/// Use case for getting refueling entries by date range
class GetRefuelingEntriesByDateRange {
  final RefuelingRepository _repository;

  GetRefuelingEntriesByDateRange(this._repository);

  Future<List<RefuelingEntry>> call({
    required String vehicleId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _repository.getRefuelingEntriesByDateRange(
      vehicleId: vehicleId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
