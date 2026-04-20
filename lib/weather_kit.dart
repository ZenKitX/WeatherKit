/// WeatherKit - A weather service package for Flutter apps
///
/// This package provides:
/// - Weather data fetching from WeatherAPI.com
/// - Weather data parsing and modeling
/// - Local caching for offline support
/// - Comprehensive error handling
///
/// Usage:
/// ```dart
/// final weatherService = WeatherService(
///   apiKey: 'your_api_key',
///   cache: WeatherCache(),
/// );
///
/// final result = await weatherService.getWeatherByCity('Beijing');
/// result.fold(
///   (weather) => print('Temperature: ${weather.current.tempC}°C'),
///   (error) => print('Error: ${error.message}'),
/// );
/// ```

export 'src/services/weather_service.dart';
export 'src/models/weather_model.dart';
export 'src/cache/weather_cache.dart';
export 'src/errors/weather_errors.dart';
