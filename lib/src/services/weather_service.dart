import 'package:dio/dio.dart';
import '../models/weather_model.dart';
import '../cache/weather_cache.dart';
import '../errors/weather_errors.dart';

/// Weather service for fetching weather data
class WeatherService {
  final Dio _dio;
  final String apiKey;
  final WeatherCache? cache;
  final String baseUrl;

  /// Create weather service
  ///
  /// [apiKey] - WeatherAPI.com API key
  /// [cache] - Optional cache service for offline support
  /// [baseUrl] - Base URL for weather API (default: https://api.weatherapi.com/v1)
  WeatherService({
    required this.apiKey,
    this.cache,
    String? baseUrl,
  })  : baseUrl = baseUrl ?? 'https://api.weatherapi.com/v1',
        _dio = Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /// Get weather by city name
  ///
  /// [city] - City name (e.g., "Beijing", "London")
  /// [includeHourly] - Include hourly forecast (default: false)
  /// [includeDaily] - Include daily forecast (default: false)
  /// [hourlyCount] - Number of hours for forecast (default: 24)
  /// [dailyCount] - Number of days for forecast (default: 7)
  Future<Result<WeatherData>> getWeatherByCity({
    required String city,
    bool includeHourly = false,
    bool includeDaily = false,
    int hourlyCount = 24,
    int dailyCount = 7,
  }) async {
    final cacheKey = '$city';

    // Try cache first
    if (cache != null) {
      final cached = await cache!.get(cacheKey);
      if (cached != null) {
        return Result.success(cached);
      }
    }

    try {
      final response = await _dio.get(
        '$baseUrl/forecast.json',
        queryParameters: {
          'key': apiKey,
          'q': city,
          'days': dailyCount,
          'aqi': 'no',
          'alerts': 'no',
          'lang': 'zh',
        },
      );

      if (response.statusCode == 200) {
        final weather = WeatherData.fromJson(response.data);

        // Save to cache
        if (cache != null) {
          await cache!.set(cacheKey, weather);
        }

        return Result.success(weather);
      } else if (response.statusCode == 401) {
        return Result.failure(
          WeatherError.apiKey('API Key 无效，请检查配置'),
        );
      } else if (response.statusCode == 400) {
        return Result.failure(
          WeatherError.locationNotFound('城市不存在，请检查拼写'),
        );
      } else if (response.statusCode == 403) {
        return Result.failure(
          WeatherError.rateLimit('API 访问受限，请检查权限'),
        );
      } else {
        return Result.failure(
          WeatherError.unknown('服务器错误 (${response.statusCode})'),
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Result.failure(
          WeatherError.network('连接超时，请检查网络'),
        );
      } else if (e.type == DioExceptionType.connectionError) {
        return Result.failure(
          WeatherError.network('网络连接失败，请检查网络设置'),
        );
      } else if (e.type == DioExceptionType.badResponse) {
        return Result.failure(
          WeatherError.parsing('服务器响应错误: ${e.response?.statusCode}'),
        );
      } else {
        return Result.failure(
          WeatherError.unknown('未知错误: ${e.message}'),
        );
      }
    } catch (e) {
      return Result.failure(
        WeatherError.unknown('未知错误: ${e.toString()}'),
      );
    }
  }

  /// Get weather by latitude and longitude
  ///
  /// [lat] - Latitude
  /// [lon] - Longitude
  /// [includeHourly] - Include hourly forecast (default: false)
  /// [includeDaily] - Include daily forecast (default: false)
  /// [hourlyCount] - Number of hours for forecast (default: 24)
  /// [dailyCount] - Number of days for forecast (default: 7)
  Future<Result<WeatherData>> getWeatherByCoordinates({
    required double lat,
    required double lon,
    bool includeHourly = false,
    bool includeDaily = false,
    int hourlyCount = 24,
    int dailyCount = 7,
  }) async {
    final cacheKey = '$lat,$lon';

    // Try cache first
    if (cache != null) {
      final cached = await cache!.get(cacheKey);
      if (cached != null) {
        return Result.success(cached);
      }
    }

    try {
      final response = await _dio.get(
        '$baseUrl/forecast.json',
        queryParameters: {
          'key': apiKey,
          'q': '$lat,$lon',
          'days': dailyCount,
          'lang': 'zh',
        },
      );

      if (response.statusCode == 200) {
        final weather = WeatherData.fromJson(response.data);

        // Save to cache
        if (cache != null) {
          await cache!.set(cacheKey, weather);
        }

        return Result.success(weather);
      } else {
        return Result.failure(
          WeatherError.unknown('服务器错误 (${response.statusCode})'),
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        return Result.failure(
          WeatherError.network('网络连接失败'),
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Result.failure(
          WeatherError.network('连接超时'),
        );
      } else {
        return Result.failure(
          WeatherError.unknown('未知错误: ${e.message}'),
        );
      }
    } catch (e) {
      return Result.failure(
        WeatherError.unknown('未知错误: ${e.toString()}'),
      );
    }
  }

  /// Search cities
  ///
  /// [query] - Search query (e.g., "Bei")
  Future<Result<List<LocationInfo>>> searchCities(String query) async {
    try {
      final response = await _dio.get(
        '$baseUrl/search.json',
        queryParameters: {
          'key': apiKey,
          'q': query,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final locations = data
            .map((e) => LocationInfo.fromJson({'location': e}))
            .toList();

        return Result.success(locations);
      } else {
        return Result.failure(
          WeatherError.unknown('服务器错误 (${response.statusCode})'),
        );
      }
    } on DioException catch (e) {
      return Result.failure(
        WeatherError.network('网络连接失败'),
      );
    } catch (e) {
      return Result.failure(
        WeatherError.unknown('未知错误: ${e.toString()}'),
      );
    }
  }
}
