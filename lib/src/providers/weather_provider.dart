import '../domain/weather_domain.dart';
import '../errors/weather_errors.dart';

/// Abstract interface for weather providers
///
/// This allows switching between different weather APIs
/// without changing the application code
abstract class WeatherProvider {
  /// Get weather by city name
  ///
  /// [city] - City name (e.g., "Beijing", "London")
  /// [includeHourly] - Include hourly forecast
  /// [includeDaily] - Include daily forecast
  /// [hourlyCount] - Number of hours for forecast (default: 24)
  /// [dailyCount] - Number of days for forecast (default: 7)
  Future<Result<Weather>> getByCity({
    required String city,
    bool includeHourly = false,
    bool includeDaily = false,
    int hourlyCount = 24,
    int dailyCount = 7,
  });

  /// Get weather by coordinates
  ///
  /// [latitude] - Latitude
  /// [longitude] - Longitude
  /// [includeHourly] - Include hourly forecast
  /// [includeDaily] - Include daily forecast
  /// [hourlyCount] - Number of hours for forecast (default: 24)
  /// [dailyCount] - Number of days for forecast (default: 7)
  Future<Result<Weather>> getByLocation({
    required double latitude,
    required double longitude,
    bool includeHourly = false,
    bool includeDaily = false,
    int hourlyCount = 24,
    int dailyCount = 7,
  });

  /// Search cities by name
  ///
  /// [query] - Search query
  /// [limit] - Maximum number of results (default: 5)
  Future<Result<CitySearchResult>> searchCities({
    required String query,
    int limit = 5,
  });
}

/// Configuration for weather provider
class WeatherProviderConfig {
  WeatherProviderConfig({
    required this.apiKey,
    this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    this.language = 'zh',
  });

  final String apiKey;
  final String? baseUrl;
  final Duration timeout;
  final String language;
}
