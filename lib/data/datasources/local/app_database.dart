import 'package:drift/drift.dart';
import 'daos/vehicle_dao.dart';
import 'daos/transaction_dao.dart';
import 'daos/attachment_dao.dart';
import 'database_factory.dart';

part 'app_database.g.dart';

// Vehicles table
class Vehicles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get make => text()();
  TextColumn get model => text()();
  IntColumn get year => integer()();
  TextColumn get vin => text().nullable()();
  TextColumn get licensePlate => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  TextColumn get fuelType => text().nullable()();
  IntColumn get odometerKm => integer().nullable()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  RealColumn get purchasePrice => real().nullable()();
  IntColumn get purchaseOdometerKm => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Transactions table (unified for all transaction types)
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  TextColumn get type => text()(); // refueling, maintenance, insurance, etc.
  DateTimeColumn get date => dateTime()();
  RealColumn get amount => real().nullable()();
  TextColumn get currency => text().nullable()();
  IntColumn get odometerKm => integer().nullable()();

  // Refueling specific fields
  RealColumn get volumeLiters => real().nullable()();
  RealColumn get pricePerLiter => real().nullable()();
  TextColumn get fuelType => text().nullable()();
  BoolColumn get isFullTank => boolean().nullable()();

  // Service specific fields
  TextColumn get serviceType => text().nullable()();
  TextColumn get serviceProvider => text().nullable()();

  // Common fields
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Attachments table for photos and documents
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId =>
      text().references(Transactions, #id).nullable()();
  TextColumn get vehicleId => text().references(Vehicles, #id).nullable()();
  TextColumn get type => text()(); // photo, document
  TextColumn get name => text()();
  TextColumn get filePath => text()();
  IntColumn get fileSizeBytes => integer().nullable()();
  TextColumn get mimeType => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Vehicles, Transactions, Attachments])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(DatabaseFactory.createConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
  );

  // DAOs
  late final VehicleDao vehicleDao = VehicleDao(this);
  late final TransactionDao transactionDao = TransactionDao(this);
  late final AttachmentDao attachmentDao = AttachmentDao(this);
}
