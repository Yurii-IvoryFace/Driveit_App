import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';

/// Factory for creating database connections based on platform
class DatabaseFactory {
  static LazyDatabase createConnection() {
    return LazyDatabase(() async {
      if (kIsWeb) {
        // Web platform - use in-memory database
        // Note: Data will be lost on page refresh
        return NativeDatabase.memory();
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Mobile platforms - use native SQLite
        final dbFolder = await getApplicationDocumentsDirectory();
        final file = File(p.join(dbFolder.path, 'driveit.db'));
        return NativeDatabase(file);
      } else {
        // Desktop platforms - use in-memory database
        return NativeDatabase.memory();
      }
    });
  }
}
