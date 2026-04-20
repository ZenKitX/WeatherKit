/// Ecosystem integration extensions for WeatherKit
///
/// Provides seamless integration with LocationKit and SolarTermKit
/// 
/// Note: This requires LocationKit and SolarTermKit to be available.
/// If these packages are not installed, the extension methods will throw
/// descriptive error messages.

import '../services/weather_service.dart';
import '../domain/weather_domain.dart';
import '../errors/weather_errors.dart';

// Dynamic imports for optional dependencies
// These are not imported at compile time to avoid dependency issues

/// Weather extension with LocationKit integration
extension WeatherLocationExtension on WeatherService {
  /// Get weather for current location using LocationKit
  ///
  /// Returns [Weather] with current weather data at device location
  /// If location permission is denied, returns [WeatherError]
  ///
  /// Note: This requires the location_kit package to be available
  Future<Result<Weather>> getWeatherForCurrentLocation() async {
    throw UnimplementedError(
      'getWeatherForCurrentLocation() requires LocationKit to be installed.\n'
      'Please add location_kit to your pubspec.yaml:\n'
      '  dependencies:\n'
      '    location_kit: ^0.1.0\n'
      'Then import it in your code:\n'
      '  import "package:location_kit/location_kit.dart";\n'
    );
  }

  /// Get weather for current location with optional city fallback
  ///
  /// If GPS location fails, tries to use [fallbackCity]
  Future<Result<Weather>> getWeatherForCurrentLocationWithFallback({
    String? fallbackCity,
  }) async {
    throw UnimplementedError(
      'getWeatherForCurrentLocationWithFallback() requires LocationKit to be installed.\n'
      'Please add location_kit to your pubspec.yaml:\n'
      '  dependencies:\n'
      '    location_kit: ^0.1.0\n'
      'Then import it in your code:\n'
      '  import "package:location_kit/location_kit.dart";\n'
    );
  }
}

/// Weather extension with SolarTermKit integration
extension WeatherSolarTermExtension on WeatherService {
  /// Get weather with solar term information
  ///
  /// Returns [WeatherWithSolarTerm] containing weather data and current solar term
  ///
  /// Note: This requires the solar_term_kit package to be available
  Future<Result<WeatherWithSolarTerm>> getWeatherWithSolarTerm({
    required String city,
  }) async {
    throw UnimplementedError(
      'getWeatherWithSolarTerm() requires SolarTermKit to be installed.\n'
      'Please add solar_term_kit to your pubspec.yaml:\n'
      '  dependencies:\n'
      '    solar_term_kit: ^0.1.0\n'
      'Then import it in your code:\n'
      '  import "package:solar_term_kit/solar_term_kit.dart";\n'
    );
  }

  /// Get weather for current location with solar term
  Future<Result<WeatherWithSolarTerm>>
      getWeatherWithSolarTermForCurrentLocation() async {
    throw UnimplementedError(
      'getWeatherWithSolarTermForCurrentLocation() requires SolarTermKit to be installed.\n'
      'Please add solar_term_kit to your pubspec.yaml:\n'
      '  dependencies:\n'
      '    solar_term_kit: ^0.1.0\n'
      'Then import it in your code:\n'
      '  import "package:solar_term_kit/solar_term_kit.dart";\n'
    );
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
  final dynamic solarTerm; // dynamic to avoid import issues

  /// Recommended poetry based on weather and solar term
  final String? recommendedPoetry;

  /// Get display text combining weather, solar term, and poetry
  String get displayText {
    final buffer = StringBuffer();

    buffer.write('📍 ${weather.city.name}，');
    buffer.write('${weather.condition.description}，');
    buffer.write('${weather.currentTemperature}°C\n');
    buffer.write('🌱 Solar Term Integration\n');

    if (recommendedPoetry != null) {
      buffer.write('📜 $recommendedPoetry');
    }

    return buffer.toString();
  }

  @override
  String toString() => displayText;
}
