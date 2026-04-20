import 'package:weather_kit/weather_kit.dart';

/// QWeather (和风天气) provider implementation
///
/// Supports:
/// - City location search
/// - Current weather
/// - Hourly forecast (24 hours)
/// - Daily forecast (7 days)
class QWeatherProvider implements WeatherProvider {
  factory QWeatherProvider.create(WeatherProviderConfig config) {
    return QWeatherProvider._(config: config);
  }

  QWeatherProvider._({required this.config});

  @override
  final WeatherProviderConfig config;

  @override
  Future<Result<Weather>> getByCity({
    required String city,
    bool includeForecast = true,
    String language = 'en',
  }) async {
    try {
      // Step 1: Search city to get location ID
      final cities = await _searchCity(city, language);
      if (cities.isEmpty) {
        return Result.failure(
          WeatherError(
            type: WeatherErrorType.cityNotFound,
            message: 'City not found: $city',
          ),
        );
      }

      final locationId = cities.first.locationId;

      // Step 2: Get current weather
      final current = await _getCurrentWeather(locationId);

      // Step 3: Get forecast if requested
      List<HourlyForecast>? hourly;
      List<DailyForecast>? daily;

      if (includeForecast) {
        hourly = await _getHourlyForecast(locationId);
        daily = await _getDailyForecast(locationId);
      }

      // Step 4: Build domain model
      final weather = Weather(
        city: cities.first.toCity(),
        condition: _parseCondition(current.condition),
        currentTemperature: current.temp.toDouble(),
        humidity: current.humidity.toDouble(),
        windSpeed: current.windSpeed.toDouble(),
        feelsLike: current.feelsLike?.toDouble(),
        hourly: hourly,
        daily: daily,
      );

      return Result.success(weather);
    } on WeatherError catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(
        WeatherError(
          type: WeatherErrorType.unknown,
          message: 'Failed to get weather: $e',
        ),
      );
    }
  }

  @override
  Future<Result<Weather>> getByLocation({
    required double latitude,
    required double longitude,
    bool includeForecast = true,
    String language = 'en',
  }) async {
    try {
      // Use coordinates to get location ID
      final locationId = await _getLocationByCoordinates(latitude, longitude);

      // Reuse getByCity with location ID
      return await _getByLocationId(
        locationId: locationId,
        includeForecast: includeForecast,
        language: language,
      );
    } on WeatherError catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(
        WeatherError(
          type: WeatherErrorType.unknown,
          message: 'Failed to get weather by location: $e',
        ),
      );
    }
  }

  @override
  Future<Result<List<City>>> searchCities({
    required String query,
    String language = 'en',
  }) async {
    try {
      final cities = await _searchCity(query, language);
      final cityList = cities.map((c) => c.toCity()).toList();
      return Result.success(cityList);
    } catch (e) {
      return Result.failure(
        WeatherError(
          type: WeatherErrorType.unknown,
          message: 'Failed to search cities: $e',
        ),
      );
    }
  }

  // Private methods

  Future<List<_QWeatherLocation>> _searchCity(
    String query,
    String language,
  ) async {
    // Simplified: In production, make actual API call
    // For now, return mock data based on query
    if (query.contains('北京') || query.toLowerCase().contains('beijing')) {
      return [
        _QWeatherLocation(
          name: '北京',
          locationId: '101010100',
          country: 'CN',
          adm1: '北京',
          adm2: '北京',
          lat: 39.9042,
          lon: 116.4074,
        ),
      ];
    } else if (query.contains('上海') || query.toLowerCase().contains('shanghai')) {
      return [
        _QWeatherLocation(
          name: '上海',
          locationId: '101020100',
          country: 'CN',
          adm1: '上海',
          adm2: '上海',
          lat: 31.2304,
          lon: 121.4737,
        ),
      ];
    }

    return [];
  }

  Future<String> _getLocationByCoordinates(double lat, double lon) async {
    // In production: Call QWeather Geo Lookup API
    // For now, return mock location ID
    return '101010100';
  }

  Future<Result<Weather>> _getByLocationId({
    required String locationId,
    bool includeForecast = true,
    String language = 'en',
  }) async {
    final current = await _getCurrentWeather(locationId);

    List<HourlyForecast>? hourly;
    List<DailyForecast>? daily;

    if (includeForecast) {
      hourly = await _getHourlyForecast(locationId);
      daily = await _getDailyForecast(locationId);
    }

    final weather = Weather(
      city: City(name: 'Unknown', country: 'CN'),
      condition: _parseCondition(current.condition),
      currentTemperature: current.temp.toDouble(),
      humidity: current.humidity.toDouble(),
      windSpeed: current.windSpeed.toDouble(),
      feelsLike: current.feelsLike?.toDouble(),
      hourly: hourly,
      daily: daily,
    );

    return Result.success(weather);
  }

  Future<_QWeatherCurrent> _getCurrentWeather(String locationId) async {
    // In production: Call QWeather Now API
    // https://devapi.qweather.com/v7/weather/now?location={locationId}&key={key}
    return _QWeatherCurrent(
      temp: 25,
      condition: '100',
      humidity: 60,
      windSpeed: 10,
      feelsLike: 26,
    );
  }

  Future<List<HourlyForecast>> _getHourlyForecast(String locationId) async {
    // In production: Call QWeather Hourly Forecast API
    // https://devapi.qweather.com/v7/weather/24h?location={locationId}&key={key}
    final now = DateTime.now();
    return List.generate(24, (index) {
      final time = now.add(Duration(hours: index));
      return HourlyForecast(
        time: time,
        temperature: 20.0 + (index % 10),
        condition: WeatherCondition.clear,
      );
    });
  }

  Future<List<DailyForecast>> _getDailyForecast(String locationId) async {
    // In production: Call QWeather Daily Forecast API
    // https://devapi.qweather.com/v7/weather/7d?location={locationId}&key={key}
    final today = DateTime.now();
    return List.generate(7, (index) {
      final date = today.add(Duration(days: index));
      return DailyForecast(
        date: date,
        maxTemperature: 25.0 + (index % 5),
        minTemperature: 15.0 + (index % 5),
        condition: WeatherCondition.clear,
      );
    });
  }

  WeatherCondition _parseCondition(String conditionCode) {
    // QWeather condition codes
    // https://dev.qweather.com/docs/standard/weather-icon/
    switch (conditionCode) {
      // Clear
      case '100':
      case '150':
        return WeatherCondition.clear;
      // Cloudy
      case '101':
      case '102':
      case '103':
      case '104':
        return WeatherCondition.cloudy;
      // Rain
      case '300':
      case '301':
      case '302':
      case '303':
      case '304':
      case '305':
      case '306':
      case '307':
      case '308':
      case '309':
      case '310':
      case '311':
      case '312':
      case '313':
      case '314':
      case '315':
      case '316':
      case '317':
      case '318':
      case '399':
        return WeatherCondition.rainy;
      // Snow
      case '400':
      case '401':
      case '402':
      case '403':
      case '404':
      case '405':
      case '406':
      case '407':
      case '408':
      case '409':
      case '410':
      case '499':
        return WeatherCondition.snowy;
      // Thunderstorm
      case '302':
        return WeatherCondition.thunderstorm;
      // Fog
      case '501':
      case '502':
      case '503':
      case '504':
      case '507':
      case '508':
      case '509':
      case '510':
      case '511':
      case '512':
      case '513':
      case '514':
      case '515':
        return WeatherCondition.fog;
      default:
        return WeatherCondition.unknown;
    }
  }

  String _formatDateForQWeather(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}${date.hour.toString().padLeft(2, '0')}';
  }
}

// Internal models for QWeather API response

class _QWeatherLocation {
  final String name;
  final String locationId;
  final String country;
  final String adm1;
  final String adm2;
  final double lat;
  final double lon;

  _QWeatherLocation({
    required this.name,
    required this.locationId,
    required this.country,
    required this.adm1,
    required this.adm2,
    required this.lat,
    required this.lon,
  });

  City toCity() {
    return City(
      name: name,
      country: country,
      region: adm1,
      latitude: lat,
      longitude: lon,
    );
  }
}

class _QWeatherCurrent {
  final int temp;
  final String condition;
  final int humidity;
  final int windSpeed;
  final int? feelsLike;

  _QWeatherCurrent({
    required this.temp,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    this.feelsLike,
  });
}
