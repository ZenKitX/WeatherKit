import 'package:dio/dio.dart';
import '../domain/weather_domain.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart' as api;
import '../errors/weather_errors.dart';

/// WeatherAPI.com provider implementation
class WeatherApiProvider implements WeatherProvider {
  WeatherApiProvider._({
    required this.config,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = config.timeout;
    _dio.options.receiveTimeout = config.timeout;
  }

  /// Create provider from configuration
  factory WeatherApiProvider.create(WeatherProviderConfig config) {
    return WeatherApiProvider._(config: config);
  }

  final WeatherProviderConfig config;
  final Dio _dio;

  String get _baseUrl => config.baseUrl ?? 'https://api.weatherapi.com/v1';

  @override
  Future<Result<Weather>> getByCity({
    required String city,
    bool includeHourly = false,
    bool includeDaily = false,
    int hourlyCount = 24,
    int dailyCount = 7,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/forecast.json',
        queryParameters: {
          'key': config.apiKey,
          'q': city,
          'days': dailyCount,
          'aqi': 'no',
          'alerts': 'no',
          'lang': config.language,
        },
      );

      if (response.statusCode == 200) {
        final apiWeather = api.WeatherData.fromJson(response.data);
        final weather = WeatherApiAdapter.toDomain(apiWeather);
        return Result.success(weather);
      } else {
        return Result.failure(WeatherError.networkError('HTTP ${response.statusCode}'));
      }
    } on DioException catch (e) {
      return Result.failure(WeatherError.networkError(e.message ?? 'Network error'));
    } catch (e) {
      return Result.failure(WeatherError.unknownError(e.toString()));
    }
  }

  @override
  Future<Result<Weather>> getByLocation({
    required double latitude,
    required double longitude,
    bool includeHourly = false,
    bool includeDaily = false,
    int hourlyCount = 24,
    int dailyCount = 7,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/forecast.json',
        queryParameters: {
          'key': config.apiKey,
          'q': '$latitude,$longitude',
          'days': dailyCount,
          'aqi': 'no',
          'alerts': 'no',
          'lang': config.language,
        },
      );

      if (response.statusCode == 200) {
        final apiWeather = api.WeatherData.fromJson(response.data);
        final weather = WeatherApiAdapter.toDomain(apiWeather);
        return Result.success(weather);
      } else {
        return Result.failure(WeatherError.networkError('HTTP ${response.statusCode}'));
      }
    } on DioException catch (e) {
      return Result.failure(WeatherError.networkError(e.message ?? 'Network error'));
    } catch (e) {
      return Result.failure(WeatherError.unknownError(e.toString()));
    }
  }

  @override
  Future<Result<CitySearchResult>> searchCities({
    required String query,
    int limit = 5,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search.json',
        queryParameters: {
          'key': config.apiKey,
          'q': query,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final cities = data
            .take(limit)
            .map((e) => City.fromJson({'location': e}))
            .toList();
        return Result.success(CitySearchResult(
          cities: cities,
          hasMore: data.length > limit,
        ));
      } else {
        return Result.failure(WeatherError.networkError('HTTP ${response.statusCode}'));
      }
    } on DioException catch (e) {
      return Result.failure(WeatherError.networkError(e.message ?? 'Network error'));
    } catch (e) {
      return Result.failure(WeatherError.unknownError(e.toString()));
    }
  }
}

/// Adapter to convert WeatherAPI models to domain models
class WeatherApiAdapter {
  /// Convert WeatherAPI WeatherData to domain Weather
  static Weather toDomain(api.WeatherData apiWeather) {
    return Weather(
      city: City(
        name: apiWeather.location.name,
        region: apiWeather.location.region,
        country: apiWeather.location.country,
        latitude: apiWeather.location.lat,
        longitude: apiWeather.location.lon,
      ),
      currentTemperature: apiWeather.current.tempC,
      condition: conditionFromWeatherAPI(apiWeather.current.conditionText),
      humidity: apiWeather.current.humidity,
      windSpeed: apiWeather.current.windKph,
      currentTime: DateTime.now(),
      hourlyForecast: _convertHourly(apiWeather.forecast.hourly),
      dailyForecast: _convertDaily(apiWeather.forecast.daily),
    );
  }

  static List<HourlyForecast> _convertHourly(List<api.HourlyForecast> hourly) {
    return hourly.map((h) {
      return HourlyForecast(
        time: h.time,
        temperature: h.temperature,
        condition: conditionFromWeatherAPI(h.conditionText),
        humidity: h.humidity,
        windSpeed: h.windKph,
      );
    }).toList();
  }

  static List<DailyForecast> _convertDaily(List<api.DailyForecast> daily) {
    return daily.map((d) {
      return DailyForecast(
        date: d.date,
        maxTemp: d.maxTemp,
        minTemp: d.minTemp,
        condition: conditionFromWeatherAPI(d.conditionText),
        sunrise: d.sunrise,
        sunset: d.sunset,
        uvIndex: d.uvIndex,
      );
    }).toList();
  }
}
