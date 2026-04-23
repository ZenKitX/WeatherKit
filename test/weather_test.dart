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

  group('City', () {
    test('should create city', () {
      final city = City(
        name: 'Beijing',
        region: 'Beijing',
        country: 'China',
        latitude: 39.9042,
        longitude: 116.4074,
      );
      expect(city.name, 'Beijing');
      expect(city.region, 'Beijing');
      expect(city.country, 'China');
      expect(city.latitude, 39.9042);
      expect(city.longitude, 116.4074);
    });
  });

  group('WeatherCondition', () {
    test('should parse weather conditions', () {
      expect(conditionFromWeatherAPI('rain'), WeatherCondition.rain);
      expect(conditionFromWeatherAPI('sunny'), WeatherCondition.clear);
      expect(conditionFromWeatherAPI('cloudy'), WeatherCondition.cloudy);
      expect(conditionFromWeatherAPI('snow'), WeatherCondition.snow);
    });
  });

  group('Weather', () {
    test('should create weather', () {
      final weather = Weather(
        city: City(
          name: 'Beijing',
          region: 'Beijing',
          country: 'China',
          latitude: 39.9042,
          longitude: 116.4074,
        ),
        currentTemperature: 25.5,
        condition: WeatherCondition.clear,
        humidity: 60,
        windSpeed: 10.0,
        currentTime: DateTime.now(),
      );
      expect(weather.currentTemperature, 25.5);
      expect(weather.condition, WeatherCondition.clear);
      expect(weather.humidity, 60);
      expect(weather.windSpeed, 10.0);
    });
  });

  group('HourlyForecast', () {
    test('should create hourly forecast', () {
      final forecast = HourlyForecast(
        time: DateTime.now(),
        temperature: 20.0,
        condition: WeatherCondition.clear,
        humidity: 60,
        windSpeed: 10.0,
      );
      expect(forecast.temperature, 20.0);
      expect(forecast.condition, WeatherCondition.clear);
      expect(forecast.humidity, 60);
      expect(forecast.windSpeed, 10.0);
    });
  });

  group('DailyForecast', () {
    test('should create daily forecast', () {
      final forecast = DailyForecast(
        date: DateTime.now(),
        maxTemp: 30.0,
        minTemp: 20.0,
        condition: WeatherCondition.clear,
        sunrise: DateTime(2024, 4, 23, 6, 0),
        sunset: DateTime(2024, 4, 23, 18, 0),
        uvIndex: 5,
      );
      expect(forecast.maxTemp, 30.0);
      expect(forecast.minTemp, 20.0);
      expect(forecast.condition, WeatherCondition.clear);
      expect(forecast.uvIndex, 5);
    });
  });
}
