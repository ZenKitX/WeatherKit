/// WeatherKit - A weather service package for Flutter apps
///
/// This package provides:
/// - Weather data fetching from multiple providers (WeatherAPI, QWeather, etc.)
/// - Provider abstraction for easy switching between APIs
/// - Independent domain models
/// - Weather data parsing and modeling
/// - Local caching for offline support
/// - Comprehensive error handling
///
/// Usage:
/// ```dart
/// // Using WeatherAPI (default)
/// final weatherService = WeatherService.withWeatherAPI(
///   apiKey: 'your_api_key',
///   cache: WeatherCache(),
/// );
///
/// // Or use custom provider
/// final customProvider = MyCustomProvider();
/// final weatherService = WeatherService.withProvider(
///   provider: customProvider,
///   cache: WeatherCache(),
/// );
///
/// final result = await weatherService.getWeatherByCity('Beijing');
/// result.fold(
///   (weather) => print('Temperature: ${weather.currentTemperature}°C'),
///   (error) => print('Error: ${error.message}'),
/// );
/// ```

library;

export 'src/services/weather_service.dart';
export 'src/providers/weather_provider.dart';
export 'src/providers/weather_api_provider.dart';
export 'src/providers/qweather_provider.dart';
export 'src/domain/weather_domain.dart';
export 'src/models/weather_model.dart';
export 'src/cache/weather_cache.dart';
export 'src/errors/weather_errors.dart';
export 'src/security/secure_key_storage.dart';
