/// Ecosystem integration extensions for WeatherKit
///
/// Provides seamless integration with LocationKit and SolarTermKit

import 'package:location_kit/location_kit.dart';
import 'package:solar_term_kit/solar_term_kit.dart';

import '../services/weather_service.dart';
import '../domain/weather_domain.dart';
import '../errors/weather_errors.dart';

/// Weather extension with LocationKit integration
extension WeatherLocationExtension on WeatherService {
  /// Get weather for current location using LocationKit
  ///
  /// Returns [Weather] with current weather data at device location
  /// If location permission is denied, returns [WeatherError]
  Future<Result<Weather>> getWeatherForCurrentLocation() async {
    // Import LocationService from location_kit
    final locationService = LocationService();

    // Get current location
    final locationResult = await locationService.getCurrentLocation();

    return locationResult.fold(
      (location) async {
        if (!location.hasCoordinates) {
          return Result.failure(
            WeatherError(
              type: WeatherErrorType.locationNotFound,
              message: 'Location coordinates not available',
            ),
          );
        }

        // Get weather by coordinates
        return getByLocation(
          latitude: location.latitude!,
          longitude: location.longitude!,
          language: 'zh',
        );
      },
      (error) async {
        return Result.failure(
          WeatherError(
            type: WeatherErrorType.locationNotFound,
            message: 'Failed to get current location: ${error.message}',
          ),
        );
      },
    );
  }

  /// Get weather for current location with optional city fallback
  ///
  /// If GPS location fails, tries to use [fallbackCity]
  Future<Result<Weather>> getWeatherForCurrentLocationWithFallback({
    String? fallbackCity,
  }) async {
    final locationResult = await getWeatherForCurrentLocation();

    return locationResult.fold(
      (weather) => Result.success(weather),
      (error) async {
        if (fallbackCity != null) {
          return getByCity(city: fallbackCity, language: 'zh');
        }
        return Result.failure(error);
      },
    );
  }
}

/// Weather extension with SolarTermKit integration
extension WeatherSolarTermExtension on WeatherService {
  /// Get weather with solar term information
  ///
  /// Returns [WeatherWithSolarTerm] containing weather data and current solar term
  Future<Result<WeatherWithSolarTerm>> getWeatherWithSolarTerm({
    required String city,
  }) async {
    // Get weather
    final weatherResult = await getByCity(city: city, language: 'zh');

    return weatherResult.fold(
      (weather) async {
        // Get current solar term
        final solarTerm = SolarTerms.getCurrentSolarTerm();

        // Create enhanced weather data
        final weatherWithTerm = WeatherWithSolarTerm(
          weather: weather,
          solarTerm: solarTerm,
          recommendedPoetry: _getRecommendedPoetry(weather, solarTerm),
        );

        return Result.success(weatherWithTerm);
      },
      (error) async {
        return Result.failure(error);
      },
    );
  }

  /// Get weather for current location with solar term
  Future<Result<WeatherWithSolarTerm>>
      getWeatherWithSolarTermForCurrentLocation() async {
    final weatherResult = await getWeatherForCurrentLocation();

    return weatherResult.fold(
      (weather) async {
        final solarTerm = SolarTerms.getCurrentSolarTerm();

        return Result.success(
          WeatherWithSolarTerm(
            weather: weather,
            solarTerm: solarTerm,
            recommendedPoetry: _getRecommendedPoetry(weather, solarTerm),
          ),
        );
      },
      (error) async {
        return Result.failure(error);
      },
    );
  }

  /// Get poetry recommendation based on weather and solar term
  String _getRecommendedPoetry(Weather weather, SolarTerm solarTerm) {
    // Match poetry based on weather condition and solar term
    final condition = weather.condition;
    final term = solarTerm.name;

    // Spring solar terms + weather conditions
    if (['立春', '雨水', '惊蛰', '春分', '清明', '谷雨'].contains(term)) {
      if (condition == WeatherCondition.rainy) {
        return '春雨贵如油';
      } else if (condition == WeatherCondition.clear) {
        return '春色满园关不住';
      } else if (condition == WeatherCondition.cloudy) {
        return '天街小雨润如酥';
      }
    }

    // Summer solar terms
    if (['立夏', '小满', '芒种', '夏至', '小暑', '大暑'].contains(term)) {
      if (condition == WeatherCondition.clear) {
        return '接天莲叶无穷碧';
      } else if (condition == WeatherCondition.thunderstorm) {
        return '黑云压城城欲摧';
      } else if (weather.currentTemperature! > 30) {
        return '赤日炎炎似火烧';
      }
    }

    // Autumn solar terms
    if (['立秋', '处暑', '白露', '秋分', '寒露', '霜降'].contains(term)) {
      if (condition == WeatherCondition.clear) {
        return '晴空一鹤排云上';
      } else if (condition == WeatherCondition.fog) {
        return '雾失楼台，月迷津渡';
      } else if (weather.currentTemperature! < 15) {
        return '秋风萧瑟天气凉';
      }
    }

    // Winter solar terms
    if (['立冬', '小雪', '大雪', '冬至', '小寒', '大寒'].contains(term)) {
      if (condition == WeatherCondition.snowy) {
        return '千山鸟飞绝，万径人踪灭';
      } else if (condition == WeatherCondition.clear) {
        return '墙角数枝梅，凌寒独自开';
      } else if (weather.currentTemperature! < 0) {
        return '寒风萧瑟，万物凋零';
      }
    }

    // Default recommendations based on condition
    switch (condition) {
      case WeatherCondition.clear:
        return '晴空万里，心旷神怡';
      case WeatherCondition.cloudy:
        return '云卷云舒，悠然自得';
      case WeatherCondition.rainy:
        return '细雨绵绵，诗意盎然';
      case WeatherCondition.snowy:
        return '银装素裹，分外妖娆';
      case WeatherCondition.thunderstorm:
        return '风雷激荡，气势磅礴';
      case WeatherCondition.fog:
        return '烟雨蒙蒙，如梦似幻';
      case WeatherCondition.unknown:
      default:
        return '天气无常，且行且珍惜';
    }
  }
}

/// Weather data enhanced with solar term information
class WeatherWithSolarTerm {
  const WeatherWithSolarTerm({
    required this.weather,
    required this.solarTerm,
    this.recommendedPoetry,
  });

  /// Weather data
  final Weather weather;

  /// Current solar term
  final SolarTerm solarTerm;

  /// Recommended poetry based on weather and solar term
  final String? recommendedPoetry;

  /// Get display text combining weather, solar term, and poetry
  String get displayText {
    final buffer = StringBuffer();

    buffer.write('📍 ${weather.city.name}，');
    buffer.write('${weather.condition.description}，');
    buffer.write('${weather.currentTemperature}°C\n');
    buffer.write('🌱 $solarTerm\n');

    if (recommendedPoetry != null) {
      buffer.write('📜 $recommendedPoetry');
    }

    return buffer.toString();
  }

  @override
  String toString() => displayText;
}
