import 'package:flutter_test/flutter_test.dart';
import 'package:weather_kit/weather_kit.dart';

void main() {
  group('WeatherError', () {
    test('should create network error', () {
      final error = WeatherError.network('Network connection failed');
      expect(error.type, WeatherErrorType.network);
      expect(error.message, 'Network connection failed');
    });

    test('should create parsing error', () {
      final error = WeatherError.parsing('Failed to parse response');
      expect(error.type, WeatherErrorType.parsing);
      expect(error.message, 'Failed to parse response');
    });

    test('should create API key error', () {
      final error = WeatherError.apiKey('Invalid API key');
      expect(error.type, WeatherErrorType.apiKey);
      expect(error.message, 'Invalid API key');
    });

    test('should create rate limit error', () {
      final error = WeatherError.rateLimit('Rate limit exceeded');
      expect(error.type, WeatherErrorType.rateLimit);
      expect(error.message, 'Rate limit exceeded');
    });

    test('should create location not found error', () {
      final error = WeatherError.locationNotFound('City not found');
      expect(error.type, WeatherErrorType.locationNotFound);
      expect(error.message, 'City not found');
    });

    test('should create unknown error', () {
      final error = WeatherError.unknown('Unknown error occurred');
      expect(error.type, WeatherErrorType.unknown);
      expect(error.message, 'Unknown error occurred');
    });
  });

  group('Result', () {
    test('should create success result', () {
      final result = Result.success(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.data, equals(42));
    });

    test('should create failure result', () {
      final error = WeatherError.network('Failed');
      final result = Result<int>.failure(error);
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, equals(error));
    });

    test('fold should execute success callback', () {
      final result = Result.success(10);
      final value = result.fold(
        (data) => data * 2,
        (error) => 0,
      );
      expect(value, equals(20));
    });

    test('fold should execute failure callback', () {
      final error = WeatherError.network('Failed');
      final result = Result<int>.failure(error);
      final value = result.fold(
        (data) => data * 2,
        (error) => error.message.length,
      );
      expect(value, equals(6));
    });
  });

  group('LocationInfo', () {
    test('should create location info', () {
      final location = LocationInfo(
        name: 'Beijing',
        region: 'Beijing',
        country: 'China',
        lat: 39.9042,
        lon: 116.4074,
      );
      expect(location.name, 'Beijing');
      expect(location.region, 'Beijing');
      expect(location.country, 'China');
      expect(location.lat, 39.9042);
      expect(location.lon, 116.4074);
    });
  });

  group('CurrentWeather', () {
    test('should create current weather', () {
      final weather = CurrentWeather(
        tempC: 25.5,
        conditionText: 'Sunny',
        humidity: 60,
        windKph: 10.5,
        uvIndex: 5,
      );
      expect(weather.tempC, 25.5);
      expect(weather.conditionText, 'Sunny');
      expect(weather.humidity, 60);
      expect(weather.windKph, 10.5);
      expect(weather.uvIndex, 5);
    });
  });

  group('HourlyForecast', () {
    test('should create hourly forecast', () {
      final time = DateTime(2024, 4, 20, 12, 0);
      final forecast = HourlyForecast(
        time: time,
        tempC: 26.0,
        conditionText: 'Cloudy',
        isDay: true,
      );
      expect(forecast.time, time);
      expect(forecast.tempC, 26.0);
      expect(forecast.conditionText, 'Cloudy');
      expect(forecast.isDay, true);
    });
  });

  group('DailyForecast', () {
    test('should create daily forecast', () {
      final date = DateTime(2024, 4, 20);
      final forecast = DailyForecast(
        date: date,
        maxTempC: 30.0,
        minTempC: 20.0,
        conditionText: 'Sunny',
        sunrise: '06:00',
        sunset: '18:00',
        uvIndex: 8,
      );
      expect(forecast.date, date);
      expect(forecast.maxTempC, 30.0);
      expect(forecast.minTempC, 20.0);
      expect(forecast.conditionText, 'Sunny');
      expect(forecast.sunrise, '06:00');
      expect(forecast.sunset, '18:00');
      expect(forecast.uvIndex, 8);
    });
  });

  group('WeatherData', () {
    test('should create complete weather data', () {
      final location = LocationInfo(
        name: 'Shanghai',
        region: 'Shanghai',
        country: 'China',
        lat: 31.2304,
        lon: 121.4737,
      );
      final current = CurrentWeather(
        tempC: 28.0,
        conditionText: 'Sunny',
        humidity: 65,
        windKph: 12.0,
        uvIndex: 6,
      );
      final weatherData = WeatherData(
        location: location,
        current: current,
        hourly: [],
        daily: [],
      );
      expect(weatherData.location.name, 'Shanghai');
      expect(weatherData.current.tempC, 28.0);
      expect(weatherData.hourly, isEmpty);
      expect(weatherData.daily, isEmpty);
    });
  });
}
