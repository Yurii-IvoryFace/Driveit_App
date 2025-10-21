class AppConstants {
  const AppConstants._();

  // App Info
  static const String appName = 'DriveIt';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'driveit.db';
  static const int databaseVersion = 1;

  // Storage
  static const String imagesDirectory = 'images';
  static const String documentsDirectory = 'documents';

  // Image compression
  static const int imageQuality = 85;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minVehicleYear = 1950;
  static const int maxVehicleYear = 2030;
  static const int maxNameLength = 100;
  static const int maxNotesLength = 1000;

  // Currency
  static const String defaultCurrency = 'USD';
  static const List<String> supportedCurrencies = [
    'USD',
    'EUR',
    'UAH',
    'GBP',
    'CAD',
    'AUD',
  ];

  // Distance units
  static const String defaultDistanceUnit = 'km';
  static const List<String> supportedDistanceUnits = ['km', 'miles'];

  // Fuel types
  static const List<String> fuelTypes = [
    'Gasoline',
    'Diesel',
    'Electric',
    'Hybrid',
    'LPG',
    'CNG',
  ];

  // Transaction types
  static const List<String> transactionTypes = [
    'refueling',
    'maintenance',
    'insurance',
    'parking',
    'toll',
    'carWash',
    'other',
  ];
}
