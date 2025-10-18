import 'dart:async';

import 'package:driveit_app/features/vehicles/data/dto/vehicle_dto.dart';
import 'package:driveit_app/features/vehicles/data/vehicle_local_data_source.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_repository.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  VehicleRepositoryImpl(this._dataSource);

  final VehicleLocalDataSource _dataSource;

  @override
  Stream<List<Vehicle>> watchVehicles() async* {
    final initial = await _dataSource.getAll();
    yield _mapToDomain(initial);
    yield* _dataSource.watchAll().map(_mapToDomain);
  }

  @override
  Future<List<Vehicle>> fetchVehicles() async {
    final dtos = await _dataSource.getAll();
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<void> saveVehicle(Vehicle vehicle) {
    final dto = VehicleDto.fromDomain(vehicle);
    return _dataSource.upsert(dto);
  }

  @override
  Future<void> deleteVehicle(String id) => _dataSource.remove(id);

  @override
  Future<void> setPrimaryVehicle(String id) => _dataSource.markPrimary(id);

  List<Vehicle> _mapToDomain(List<VehicleDto> dtos) {
    return dtos.map((dto) => dto.toDomain()).toList();
  }
}
