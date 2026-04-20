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
  /// [days] - Number of days for forecast (1-10, default: 7)
  /// [lang] - Language code (default: zh for Chinese)
  /// [aqi] - Include air quality data (default: yes)
  /// [alerts] - Include weather alerts (default: yes)
  Future<Result<WeatherModel>> getWeatherByCity({
    required String city,
    int days = 7,
    String lang = 'zh',
    String aqi = 'yes',
    String alerts = 'yes',
  }) async {
    // Try cache first
    if (cache != null) {
      final isCacheValid = await cache!.isCacheValid(city);
      if (isCacheValid) {
        final cachedWeather = await cache!.getWeather(city);
        if (cachedWeather != null) {
          return Result.success(cachedWeather);
        }
      }
    }

    try {
      final response = await _dio.get(
        '$baseUrl/forecast.json',
        queryParameters: {
          'key': apiKey,
          'q': city,
          'days': days,
          'aqi': aqi,
          'alerts': alerts,
          'lang': lang,
        },
      );

      if (response.statusCode == 200) {
        final weather = WeatherModel.fromJson(response.data);

        // Save to cache
        if (cache != null) {
          await cache!.saveWeather(city, weather);
        }

        return Result.success(weather);
      } else if (response.statusCode == 401) {
        return Result.failure(
          WeatherError(
            type: WeatherErrorType.apiKeyInvalid,
            message: 'API Key 无效，请检查配置',
            statusCode: response.statusCode,
          ),
        );
      } else if (response.statusCode == 400) {
        return Result.failure(
          WeatherError(
            type: WeatherErrorType.cityNotFound,
            message: '城市不存在，请检查拼写',
            statusCode: response.statusCode,
          ),
        );
      } else if (response.statusCode == 403) {
        return Result.failure(
          WeatherError(
            type: WeatherErrorType.serverError,
            message: 'API 访问受限，请检查权限',
            statusCode: response.statusCode,
          ),
        );
      } else {
        return Result.failure(
          WeatherError(
            type: WeatherErrorType.serverError,
            message: '服务器错误 (${response.statusCode})',
            statusCode: response.statusCode,
          ),
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Result.failure(
          WeatherError(
            type: WeatherErrorType.timeout,
            message: '连接超时，请检查网络',
            details: e.message,
          ),
        );
      } else if (e.type == DioExceptionType.connectionError) {
        return Result.failure(
          WeatherError(
            type: WeatherErrorType.networkError,
            message: '网络连接失败，请检查网络设置',
            details: e.message,
          ),
        );
      } else if (e.type == DioExceptionType.badResponse) {
        return Result.failure(
          WeatherError(
            type: WeatherErrorType.serverError,
            message: '服务器响应错误',
            statusCode: e.response?.statusCode,
            details: e.message,
          ),
        );
      } else {
        return Result.failure(
          WeatherError(
            type: WeatherErrorType.unknown,
            message: '未知错误',
            details: e.message,
          ),
        );
      }
    } catch (e) {
      return Result.failure(
        WeatherError(
          type: WeatherErrorType.unknown,
          message: '未知错误',
          details: e.toString(),
        ),
      );
    }
  }

  /// Get weather by latitude and longitude
  ///
  /// [lat] - Latitude
  /// [lon] - Longitude
  /// [days] - Number of days for forecast (1-10, default: 7)
  /// [lang] - Language code (default: zh for Chinese)
  Future<Result<WeatherModel>> getWeatherByLocation({
    required double lat,
    required double lon,
    int days = 7,
    String lang = 'zh',
  }) async {
    final locationKey = '$lat,$lon';

    // Try cache first
    if (cache != null) {
      final isCacheValid = await cache!.isCacheValid(locationKey);
      if (isCacheValid) {
        final cachedWeather = await cache!.getWeather(locationKey);
        if (cachedWeather != null) {
          return Result.success(cachedWeather);
        }
      }
    }

    try {
      final response = await _dio.get(
        '$baseUrl/forecast.json',
        queryParameters: {
          'key': apiKey,
          'q': '$lat,$lon',
          'days': days,
          'lang': lang,
        },
      );

      if (response.statusCode == 200) {
        final weather = WeatherModel.fromJson(response.data);

        // Save to cache
        if (cache != null) {
          await cache!.saveWeather(locationKey, weather);
        }

        return Result.success(weather);
      } else {
        return Result.failure(
          WeatherError(
            type: WeatherErrorType.serverError,
            message: '服务器错误 (${response.statusCode})',
            statusCode: response.statusCode,
          ),
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        return Result.failure(
          WeatherError(
            type: WeatherErrorType.networkError,
            message: '网络连接失败',
            details: e.message,
          ),
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Result.failure(
          WeatherError(
            type: WeatherErrorType.timeout,
            message: '连接超时',
            details: e.message,
          ),
        );
      } else {
        return Result.failure(
          WeatherError(
            type: WeatherErrorType.unknown,
            message: '未知错误',
            details: e.message,
          ),
        );
      }
    } catch (e) {
      return Result.failure(
        WeatherError(
          type: WeatherErrorType.unknown,
          message: '未知错误',
          details: e.toString(),
        ),
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
          WeatherError(
            type: WeatherErrorType.serverError,
            message: '服务器错误 (${response.statusCode})',
            statusCode: response.statusCode,
          ),
        );
      }
    } on DioException catch (e) {
      return Result.failure(
        WeatherError(
          type: WeatherErrorType.networkError,
          message: '网络连接失败',
          details: e.message,
        ),
      );
    } catch (e) {
      return Result.failure(
        WeatherError(
          type: WeatherErrorType.unknown,
          message: '未知错误',
          details: e.toString(),
        ),
      );
    }
  }

  /// Get current weather only (simplified)
  Future<Result<WeatherModel>> getCurrentWeather(String location) async {
    return getWeatherByCity(city: location, days: 1);
  }
}
