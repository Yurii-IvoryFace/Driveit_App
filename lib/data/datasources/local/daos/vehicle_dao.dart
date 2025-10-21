import 'package:drift/drift.dart';
import '../app_database.dart';

part 'vehicle_dao.g.dart';

@DriftAccessor(tables: [Vehicles, Transactions, Attachments])
class VehicleDao extends DatabaseAccessor<AppDatabase> with _$VehicleDaoMixin {
  VehicleDao(super.db);

  // Get all vehicles
  Future<List<Vehicle>> getAll() async {
    return await select(vehicles).get();
  }

  // Get vehicle by ID
  Future<Vehicle?> getById(String id) async {
    return await (select(
      vehicles,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // Get primary vehicle
  Future<Vehicle?> getPrimary() async {
    return await (select(
      vehicles,
    )..where((tbl) => tbl.isPrimary.equals(true))).getSingleOrNull();
  }

  // Watch all vehicles (for reactive UI)
  Stream<List<Vehicle>> watchAll() {
    return select(vehicles).watch();
  }

  // Watch vehicles with transaction count
  Stream<List<Map<String, dynamic>>> watchWithStats() {
    return select(vehicles).watch().asyncMap((vehicles) async {
      final List<Map<String, dynamic>> result = [];

      for (final vehicle in vehicles) {
        final transactionCount =
            await (select(transactions)
                  ..where((tbl) => tbl.vehicleId.equals(vehicle.id)))
                .get()
                .then((transactions) => transactions.length);

        final lastTransaction =
            await (select(transactions)
                  ..where((tbl) => tbl.vehicleId.equals(vehicle.id))
                  ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)])
                  ..limit(1))
                .getSingleOrNull();

        result.add({
          'vehicle': vehicle,
          'transactionCount': transactionCount,
          'lastTransactionDate': lastTransaction?.date,
        });
      }

      return result;
    });
  }

  // Insert vehicle
  Future<void> insert(Vehicle vehicle) async {
    await into(vehicles).insert(vehicle);
  }

  // Update vehicle
  Future<void> updateVehicle(Vehicle vehicle) async {
    await (update(
      vehicles,
    )..where((tbl) => tbl.id.equals(vehicle.id))).write(vehicle);
  }

  // Delete vehicle
  Future<void> deleteVehicle(String id) async {
    await (delete(vehicles)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Set primary vehicle (unset all others first)
  Future<void> setPrimary(String id) async {
    // First unset all primary vehicles
    await (update(vehicles)..where((tbl) => tbl.isPrimary.equals(true))).write(
      const VehiclesCompanion(isPrimary: Value(false)),
    );

    // Then set the selected vehicle as primary
    await (update(vehicles)..where((tbl) => tbl.id.equals(id))).write(
      const VehiclesCompanion(isPrimary: Value(true)),
    );
  }

  // Get vehicle with photos
  Future<Map<String, dynamic>?> getWithPhotos(String id) async {
    final vehicle = await getById(id);
    if (vehicle == null) return null;

    final photos =
        await (select(attachments)..where(
              (tbl) => tbl.vehicleId.equals(id) & tbl.type.equals('photo'),
            ))
            .get();

    return {'vehicle': vehicle, 'photos': photos};
  }

  // Get vehicle with documents
  Future<Map<String, dynamic>?> getWithDocuments(String id) async {
    final vehicle = await getById(id);
    if (vehicle == null) return null;

    final documents =
        await (select(attachments)..where(
              (tbl) => tbl.vehicleId.equals(id) & tbl.type.equals('document'),
            ))
            .get();

    return {'vehicle': vehicle, 'documents': documents};
  }
}
