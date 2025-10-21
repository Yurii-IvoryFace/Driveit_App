import 'dart:developer' as developer;

class Logger {
  static void log(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag ?? 'DriveIt',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void logBlocEvent(String blocName, String eventName, {Object? data}) {
    log('BLOC EVENT: $blocName - $eventName', tag: 'BLOC', error: data);
  }

  static void logBlocState(String blocName, String stateName, {Object? data}) {
    log('BLOC STATE: $blocName - $stateName', tag: 'BLOC', error: data);
  }

  static void logNavigation(String action, String route, {Object? data}) {
    log('NAVIGATION: $action - $route', tag: 'NAVIGATION', error: data);
  }
}
