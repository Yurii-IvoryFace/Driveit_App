import 'package:driveit_app/features/refueling/data/dto/refueling_entry_dto.dart';
import 'package:driveit_app/features/refueling/data/refueling_local_data_source.dart';
import 'package:driveit_app/features/refueling/domain/refueling_calculator.dart';
import 'package:driveit_app/features/refueling/domain/refueling_entry.dart';
import 'package:driveit_app/features/refueling/domain/refueling_repository.dart';
import 'package:driveit_app/features/refueling/domain/refueling_summary.dart';

class RefuelingRepositoryImpl implements RefuelingRepository {
  RefuelingRepositoryImpl(this._local);

  final RefuelingLocalDataSource _local;

  @override
  Stream<List<RefuelingEntry>> watchByVehicle(String vehicleId) {
    return _local.watchByVehicle(vehicleId).map(_mapToDomain);
  }

  @override
  Future<List<RefuelingEntry>> fetchByVehicle(String vehicleId) async {
    final dtos = await _local.getByVehicle(vehicleId);
    return _mapToDomain(dtos);
  }

  @override
  Future<void> saveEntry(RefuelingEntry entry) {
    final dto = RefuelingEntryDto.fromDomain(entry);
    return _local.upsert(dto);
  }

  @override
  Future<void> deleteEntry(String id) => _local.remove(id);

  @override
  Stream<RefuelingSummary> watchSummary(String vehicleId) {
    return watchByVehicle(vehicleId).map(RefuelingCalculator.buildSummary);
  }

  List<RefuelingEntry> _mapToDomain(List<RefuelingEntryDto> dtos) {
    return dtos.map((dto) => dto.toDomain()).toList();
  }
}
