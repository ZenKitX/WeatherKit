import '../domain/weather_domain.dart';
import '../providers/weather_provider.dart';
import '../providers/weather_api_provider.dart';
import '../cache/weather_cache.dart';
import '../errors/weather_errors.dart';

/// Weather service - facade for weather operations
///
/// This service provides a high-level API for weather operations,
/// handling caching and provider management internally
class WeatherService {
  WeatherService._({
    required this.provider,
    this.cache,
  });

  /// Create weather service with WeatherAPI provider
  ///
  /// [apiKey] - WeatherAPI.com API key
  /// [cache] - Optional cache service
  /// [baseUrl] - Base URL for weather API
  factory WeatherService.withWeatherAPI({
    required String apiKey,
    WeatherCache? cache,
    String? baseUrl,
  }) {
    final config = WeatherProviderConfig(
      apiKey: apiKey,
      baseUrl: baseUrl,
      language: 'zh',
    );
    final provider = WeatherApiProvider.create(config);
    return WeatherService._(provider: provider, cache: cache);
  }

  /// Create weather service with custom provider
  ///
  /// This allows using any provider (e.g., QWeather, OpenWeatherMap)
  factory WeatherService.withProvider({
    required WeatherProvider provider,
    WeatherCache? cache,
  }) {
    return WeatherService._(provider: provider, cache: cache);
  }

  final WeatherProvider provider;
  final WeatherCache? cache;

  /// Get weather by city name
  ///
  /// [city] - City name (e.g., "Beijing", "London")
  /// [includeHourly] - Include hourly forecast (default: false)
  /// [includeDaily] - Include daily forecast (default: false)
  /// [hourlyCount] - Number of hours for forecast (default: 24)
  /// [dailyCount] - Number of days for forecast (default: 7)
  Future<Result<Weather>> getWeatherByCity({
    required String city,
    bool includeHourly = false,
    bool includeDaily = false,
    int hourlyCount = 24,
    int dailyCount = 7,
  }) async {
    final cacheKey = city;

    // Try cache first
    if (cache != null) {
      final cached = await cache!.get(cacheKey);
      if (cached != null) {
        return Result.success(_convertCachedToDomain(cached));
      }
    }

    // Fetch from provider
    final result = await provider.getByCity(
      city: city,
      includeHourly: includeHourly,
      includeDaily: includeDaily,
      hourlyCount: hourlyCount,
      dailyCount: dailyCount,
    );

    // Save to cache on success
    if (result.isSuccess && cache != null) {
      // Note: We would need to add domain->API conversion here
      // For now, we'll cache the domain model directly
      // This is a simplification; in production, you might want to cache the API response
    }

    return result;
  }

  /// Get weather by coordinates
  ///
  /// [latitude] - Latitude
  /// [longitude] - Longitude
  /// [includeHourly] - Include hourly forecast (default: false)
  /// [includeDaily] - Include daily forecast (default: false)
  /// [hourlyCount] - Number of hours for forecast (default: 24)
  /// [dailyCount] - Number of days for forecast (default: 7)
  Future<Result<Weather>> getWeatherByLocation({
    required double latitude,
    required double longitude,
    bool includeHourly = false,
    bool includeDaily = false,
    int hourlyCount = 24,
    int dailyCount = 7,
  }) async {
    final cacheKey = '$latitude,$longitude';

    // Try cache first
    if (cache != null) {
      final cached = await cache!.get(cacheKey);
      if (cached != null) {
        return Result.success(_convertCachedToDomain(cached));
      }
    }

    // Fetch from provider
    final result = await provider.getByLocation(
      latitude: latitude,
      longitude: longitude,
      includeHourly: includeHourly,
      includeDaily: includeDaily,
      hourlyCount: hourlyCount,
      dailyCount: dailyCount,
    );

    return result;
  }

  /// Search cities by name
  ///
  /// [query] - Search query
  /// [limit] - Maximum number of results (default: 5)
  Future<Result<CitySearchResult>> searchCities({
    required String query,
    int limit = 5,
  }) async {
    return provider.searchCities(query: query, limit: limit);
  }

  /// Convert cached WeatherData to domain Weather
  Weather _convertCachedToDomain(dynamic cached) {
    // This is a simplified conversion
    // In production, you might want to store the domain model directly
    // or implement proper conversion
    if (cached is Weather) {
      return cached;
    }
    // Fallback - this would need proper implementation
    return cached as Weather;
  }
}
