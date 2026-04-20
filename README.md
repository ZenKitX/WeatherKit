# WeatherKit

A weather service package for Flutter apps. Provides weather data fetching, parsing, and caching.

## Features

- ✅ Weather data fetching from WeatherAPI.com
- ✅ Support for city name and coordinates
- ✅ 24-hour and 7-day forecasts
- ✅ Local caching for offline support
- ✅ Comprehensive error handling
- ✅ Multi-language support

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  weather_kit:
    git:
      url: https://github.com/ZenKitX/WeatherKit.git
      ref: main
```

## Usage

### Basic Usage

```dart
import 'package:weather_kit/weather_kit.dart';

void main() async {
  // Initialize weather service
  final weatherService = WeatherService(
    apiKey: 'your_api_key_here',
    cache: WeatherCache(), // Optional cache
  );

  // Get weather by city
  final result = await weatherService.getWeatherByCity(city: 'Beijing');

  result.fold(
    (weather) {
      print('Temperature: ${weather.current.tempC}°C');
      print('Condition: ${weather.current.conditionText}');
      print('Location: ${weather.location.name}');
    },
    (error) {
      print('Error: ${error.message}');
    },
  );
}
```

### Get Weather by Location

```dart
final result = await weatherService.getWeatherByLocation(
  lat: 39.9042,
  lon: 116.4074,
);

result.fold(
  (weather) => print('Weather: ${weather.current.tempC}°C'),
  (error) => print('Error: ${error.message}'),
);
```

### Search Cities

```dart
final result = await weatherService.searchCities('Bei');

result.fold(
  (cities) {
    for (final city in cities) {
      print('${city.name}, ${city.country}');
    }
  },
  (error) => print('Error: ${error.message}'),
);
```

### Cache Management

```dart
// Check if cache is valid
final isValid = await cache.isCacheValid('Beijing');

// Get cached weather
final cachedWeather = await cache.getWeather('Beijing');

// Clear cache
await cache.clearCache('Beijing');
await cache.clearAllCache();
```

## Weather Model

```dart
class WeatherModel {
  LocationInfo location;    // Location information
  CurrentWeather current;   // Current weather
  List<HourlyForecast>? hourly;  // 24-hour forecast
  List<DailyForecast>? daily;    // 7-day forecast
}
```

## Error Handling

```dart
enum WeatherErrorType {
  networkError,    // Network connection error
  timeout,         // Request timeout
  apiKeyInvalid,   // API key is invalid
  cityNotFound,    // City not found
  serverError,     // Server error (5xx)
  unknown,         // Unknown error
}
```

## API Key

Get your free API key from [WeatherAPI.com](https://www.weatherapi.com/):

- Free tier: 1 million calls per month
- No credit card required
- Includes current weather, forecast, and more

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
