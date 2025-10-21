import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _themeKey = 'theme_mode';
  static const String _distanceUnitKey = 'distance_unit';
  static const String _volumeUnitKey = 'volume_unit';
  static const String _currencyKey = 'currency';
  static const String _languageKey = 'language';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _autoSyncKey = 'auto_sync_enabled';
  static const String _dataRetentionKey = 'data_retention_days';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('AppPreferences not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Theme preferences
  static AppThemeMode get themeMode {
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    return AppThemeMode.values[themeIndex];
  }

  static Future<void> setThemeMode(AppThemeMode mode) async {
    await prefs.setInt(_themeKey, mode.index);
  }

  // Distance unit preferences
  static DistanceUnit get distanceUnit {
    final unitString = prefs.getString(_distanceUnitKey) ?? 'km';
    return DistanceUnit.values.firstWhere(
      (unit) => unit.value == unitString,
      orElse: () => DistanceUnit.kilometers,
    );
  }

  static Future<void> setDistanceUnit(DistanceUnit unit) async {
    await prefs.setString(_distanceUnitKey, unit.value);
  }

  // Volume unit preferences
  static VolumeUnit get volumeUnit {
    final unitString = prefs.getString(_volumeUnitKey) ?? 'L';
    return VolumeUnit.values.firstWhere(
      (unit) => unit.value == unitString,
      orElse: () => VolumeUnit.liters,
    );
  }

  static Future<void> setVolumeUnit(VolumeUnit unit) async {
    await prefs.setString(_volumeUnitKey, unit.value);
  }

  // Currency preferences
  static String get currency {
    return prefs.getString(_currencyKey) ?? '₴';
  }

  static Future<void> setCurrency(String currency) async {
    await prefs.setString(_currencyKey, currency);
  }

  // Language preferences
  static String get language {
    return prefs.getString(_languageKey) ?? 'en';
  }

  static Future<void> setLanguage(String language) async {
    await prefs.setString(_languageKey, language);
  }

  // Notification preferences
  static bool get notificationsEnabled {
    return prefs.getBool(_notificationsKey) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    await prefs.setBool(_notificationsKey, enabled);
  }

  // Auto sync preferences
  static bool get autoSyncEnabled {
    return prefs.getBool(_autoSyncKey) ?? false;
  }

  static Future<void> setAutoSyncEnabled(bool enabled) async {
    await prefs.setBool(_autoSyncKey, enabled);
  }

  // Data retention preferences
  static int get dataRetentionDays {
    return prefs.getInt(_dataRetentionKey) ?? 365;
  }

  static Future<void> setDataRetentionDays(int days) async {
    await prefs.setInt(_dataRetentionKey, days);
  }

  // Clear all preferences
  static Future<void> clearAll() async {
    await prefs.clear();
  }

  // Reset to defaults
  static Future<void> resetToDefaults() async {
    await setThemeMode(AppThemeMode.system);
    await setDistanceUnit(DistanceUnit.kilometers);
    await setVolumeUnit(VolumeUnit.liters);
    await setCurrency('₴');
    await setLanguage('en');
    await setNotificationsEnabled(true);
    await setAutoSyncEnabled(false);
    await setDataRetentionDays(365);
  }
}

enum AppThemeMode { system, light, dark }

enum DistanceUnit {
  kilometers('km', 'Kilometers'),
  miles('mi', 'Miles');

  const DistanceUnit(this.value, this.displayName);

  final String value;
  final String displayName;

  double convertFromKilometers(double km) {
    switch (this) {
      case DistanceUnit.kilometers:
        return km;
      case DistanceUnit.miles:
        return km * 0.621371;
    }
  }

  double convertToKilometers(double value) {
    switch (this) {
      case DistanceUnit.kilometers:
        return value;
      case DistanceUnit.miles:
        return value / 0.621371;
    }
  }
}

enum VolumeUnit {
  liters('L', 'Liters'),
  gallons('gal', 'Gallons (US)'),
  imperialGallons('imp gal', 'Gallons (Imperial)');

  const VolumeUnit(this.value, this.displayName);

  final String value;
  final String displayName;

  double convertFromLiters(double liters) {
    switch (this) {
      case VolumeUnit.liters:
        return liters;
      case VolumeUnit.gallons:
        return liters * 0.264172;
      case VolumeUnit.imperialGallons:
        return liters * 0.219969;
    }
  }

  double convertToLiters(double value) {
    switch (this) {
      case VolumeUnit.liters:
        return value;
      case VolumeUnit.gallons:
        return value / 0.264172;
      case VolumeUnit.imperialGallons:
        return value / 0.219969;
    }
  }
}

class Currency {
  final String symbol;
  final String code;
  final String name;

  const Currency({
    required this.symbol,
    required this.code,
    required this.name,
  });

  static const List<Currency> supportedCurrencies = [
    Currency(symbol: '₴', code: 'UAH', name: 'Ukrainian Hryvnia'),
    Currency(symbol: '\$', code: 'USD', name: 'US Dollar'),
    Currency(symbol: '€', code: 'EUR', name: 'Euro'),
    Currency(symbol: '£', code: 'GBP', name: 'British Pound'),
    Currency(symbol: '¥', code: 'JPY', name: 'Japanese Yen'),
    Currency(symbol: '₽', code: 'RUB', name: 'Russian Ruble'),
    Currency(symbol: 'zł', code: 'PLN', name: 'Polish Zloty'),
    Currency(symbol: 'Kč', code: 'CZK', name: 'Czech Koruna'),
  ];

  static Currency? fromCode(String code) {
    try {
      return supportedCurrencies.firstWhere(
        (currency) => currency.code == code,
      );
    } catch (e) {
      return null;
    }
  }

  static Currency? fromSymbol(String symbol) {
    try {
      return supportedCurrencies.firstWhere(
        (currency) => currency.symbol == symbol,
      );
    } catch (e) {
      return null;
    }
  }
}
