import 'package:flutter/material.dart';
import '../utils/logger.dart';

class AppNavigatorObserver extends NavigatorObserver {
  static final AppNavigatorObserver _instance =
      AppNavigatorObserver._internal();
  factory AppNavigatorObserver() => _instance;
  AppNavigatorObserver._internal();

  // Callback for when we return to a tab screen
  VoidCallback? onReturnToTabScreen;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    Logger.logNavigation(
      'DID_POP',
      'Route: ${route.settings.name ?? 'Unknown'}',
      data: 'Previous: ${previousRoute?.settings.name ?? 'Unknown'}',
    );

    // Check if we're returning to a tab screen
    if (previousRoute?.settings.name == '/' ||
        previousRoute?.settings.name == null) {
      Logger.logNavigation('DID_POP', 'Returning to tab screen');
      onReturnToTabScreen?.call();
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    Logger.logNavigation(
      'DID_PUSH',
      'Route: ${route.settings.name ?? 'Unknown'}',
      data: 'Previous: ${previousRoute?.settings.name ?? 'Unknown'}',
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    Logger.logNavigation(
      'DID_REPLACE',
      'New: ${newRoute?.settings.name ?? 'Unknown'}',
      data: 'Old: ${oldRoute?.settings.name ?? 'Unknown'}',
    );
  }
}
