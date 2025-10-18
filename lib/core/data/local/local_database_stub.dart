/// Placeholder API for a future SQLite-backed data source.
///
/// Replace this with a real implementation that talks to the user's local
/// server or embedded database once the interface is finalised.
abstract class LocalDatabase {
  Future<void> open();
  Future<void> close();
}

class NoOpLocalDatabase implements LocalDatabase {
  @override
  Future<void> close() async {}

  @override
  Future<void> open() async {}
}
