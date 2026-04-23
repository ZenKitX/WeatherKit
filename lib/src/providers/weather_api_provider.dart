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
        return Result.failure(WeatherError.network('HTTP ${response.statusCode}'));
      }
    } on DioException catch (e) {
      return Result.failure(WeatherError.network(e.message ?? 'Network error'));
    } catch (e) {
      return Result.failure(WeatherError.unknown(e.toString()));
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
        return Result.failure(WeatherError.network('HTTP ${response.statusCode}'));
      }
    } on DioException catch (e) {
      return Result.failure(WeatherError.network(e.message ?? 'Network error'));
    } catch (e) {
      return Result.failure(WeatherError.unknown(e.toString()));
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
        return Result.failure(WeatherError.network('HTTP ${response.statusCode}'));
      }
    } on DioException catch (e) {
      return Result.failure(WeatherError.network(e.message ?? 'Network error'));
    } catch (e) {
      return Result.failure(WeatherError.unknown(e.toString()));
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
      hourlyForecast: _convertHourly(apiWeather.hourly),
      dailyForecast: _convertDaily(apiWeather.daily),
    );
  }

  static List<HourlyForecast> _convertHourly(List<api.HourlyForecast> hourly) {
    return hourly.map((h) {
      return HourlyForecast(
        time: h.time,
        temperature: h.tempC,
        condition: conditionFromWeatherAPI(h.conditionText),
        humidity: 0, // API hourly doesn't have humidity
        windSpeed: 0.0, // API hourly doesn't have wind speed
      );
    }).toList();
  }

  static List<DailyForecast> _convertDaily(List<api.DailyForecast> daily) {
    return daily.map((d) {
      // Parse sunrise/sunset from "HH:MM AM/PM" format
      DateTime parseTime(String timeStr) {
        final parts = timeStr.split(' ');
        final timeParts = parts[0].split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final isPM = parts.length > 1 && parts[1] == 'PM';
        final adjustedHour = isPM && hour != 12 ? hour + 12 : (hour == 12 && !isPM ? 0 : hour);
        return DateTime(d.date.year, d.date.month, d.date.day, adjustedHour, minute);
      }

      return DailyForecast(
        date: d.date,
        maxTemp: d.maxTempC,
        minTemp: d.minTempC,
        condition: conditionFromWeatherAPI(d.conditionText),
        sunrise: parseTime(d.sunrise),
        sunset: parseTime(d.sunset),
        uvIndex: d.uvIndex,
      );
    }).toList();
  }
}
