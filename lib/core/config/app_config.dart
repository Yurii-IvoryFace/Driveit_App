/// Simple runtime configuration holder for swapping data sources.
class AppConfig {
  const AppConfig({required this.apiBaseUrl, this.useInMemoryStorage = true});

  final String apiBaseUrl;
  final bool useInMemoryStorage;
}
