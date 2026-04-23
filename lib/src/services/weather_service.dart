import '../domain/weather_domain.dart';
import '../providers/weather_provider.dart';
import '../providers/weather_api_provider.dart';
import '../providers/qweather_provider.dart';
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

  /// Create weather service with QWeather (和风天气) provider
  ///
  /// [apiKey] - QWeather API key
  /// [cache] - Optional cache service
  /// [baseUrl] - Base URL (default: https://devapi.qweather.com/v7)
  factory WeatherService.withQWeather({
    required String apiKey,
    WeatherCache? cache,
    String? baseUrl,
  }) {
    final config = WeatherProviderConfig(
      apiKey: apiKey,
      baseUrl: baseUrl,
      language: 'zh',
    );
    final provider = QWeatherProvider.create(config);
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

    // Check for in-flight request (request deduplication)
    if (cache != null && cache!.hasInFlightRequest(cacheKey)) {
      final inFlight = cache!.getInFlightRequest(cacheKey);
      if (inFlight != null) {
        final result = await inFlight;
        return Result.success(result);
      }
    }

    // Try cache first
    if (cache != null) {
      final cached = await cache!.get(cacheKey);
      if (cached != null) {
        return Result.success(cached);
      }
    }

    // Fetch from provider
    final request = provider.getByCity(
      city: city,
      includeHourly: includeHourly,
      includeDaily: includeDaily,
      hourlyCount: hourlyCount,
      dailyCount: dailyCount,
    );

    // Register in-flight request
    if (cache != null) {
      cache!.registerInFlightRequest(cacheKey, request.then((r) => r.value!));
    }

    final result = await request;

    // Save to cache on success
    if (result.isSuccess && cache != null && result.value != null) {
      await cache!.set(cacheKey, result.value!);
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

    // Check for in-flight request
    if (cache != null && cache!.hasInFlightRequest(cacheKey)) {
      final inFlight = cache!.getInFlightRequest(cacheKey);
      if (inFlight != null) {
        final result = await inFlight;
        return Result.success(result);
      }
    }

    // Try cache first
    if (cache != null) {
      final cached = await cache!.get(cacheKey);
      if (cached != null) {
        return Result.success(cached);
      }
    }

    // Fetch from provider
    final request = provider.getByLocation(
      latitude: latitude,
      longitude: longitude,
      includeHourly: includeHourly,
      includeDaily: includeDaily,
      hourlyCount: hourlyCount,
      dailyCount: dailyCount,
    );

    // Register in-flight request
    if (cache != null) {
      cache!.registerInFlightRequest(cacheKey, request.then((r) => r.value!));
    }

    final result = await request;

    // Save to cache on success
    if (result.isSuccess && cache != null && result.value != null) {
      await cache!.set(cacheKey, result.value!);
    }

    return result;
  }

  /// Get cache statistics
  CacheStats get cacheStats {
    return cache?.stats ?? CacheStats();
  }

  /// Clear cache
  void clearCache() {
    cache?.clear();
  }

  /// Clear expired cache entries
  void clearExpiredCache() {
    cache?.clearExpired();
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
}
