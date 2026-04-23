# WeatherKit

> A powerful weather service package for Flutter apps with multi-provider support, location integration, and solar term poetry recommendations.

[![CI](https://github.com/ZenKitX/WeatherKit/workflows/WeatherKit%20CI/badge.svg)](https://github.com/ZenKitX/WeatherKit/actions)
[![pub package](https://img.shields.io/pub/v/weather_kit)](https://pub.dev/packages/weather_kit)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Features

- ✅ **Multi-Provider Support**: WeatherAPI.com & 和风天气 (QWeather)
- ✅ **Provider Abstraction**: Switch between providers seamlessly
- ✅ **Independent Domain Models**: Decoupled from API responses
- ✅ **Location Integration**: One-click weather for current location
- ✅ **Solar Term Integration**: Weather with traditional Chinese solar terms
- ✅ **Poetry Recommendations**: Contextual poetry based on weather and solar terms
- ✅ **Intelligent Caching**: TTL, LRU eviction, request deduplication
- ✅ **Secure API Key Storage**: Multiple key sources with validation
- ✅ **Comprehensive Error Handling**: Result type with detailed errors

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  weather_kit: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Basic Usage

```dart
import 'package:weather_kit/weather_kit.dart';

void main() async {
  // Initialize with WeatherAPI
  final weatherService = WeatherService.withWeatherAPI(
    apiKey: 'your_api_key_here',
    cache: WeatherCache(),
  );

  // Get weather by city
  final result = await weatherService.getByCity(city: 'Beijing');

  result.fold(
    (weather) {
      print('📍 ${weather.city.name}');
      print('🌡️ ${weather.currentTemperature}°C');
      print('☁️ ${weather.condition.description}');
    },
    (error) {
      print('❌ Error: ${error.message}');
    },
  );
}
```

### Using QWeather (和风天气)

```dart
final weatherService = WeatherService.withQWeather(
  apiKey: 'your_qweather_key',
  cache: WeatherCache(),
);

final result = await weatherService.getByCity(city: '北京');
```

### Location-Based Weather

```dart
// Get weather for current device location
final result = await weatherService.getWeatherForCurrentLocation();

result.fold(
  (weather) => print('📍 Current: ${weather.city.name}'),
  (error) => print('❌ Location error: ${error.message}'),
);
```

### Weather + Solar Term + Poetry

```dart
// Get weather with solar term and poetry recommendation
final result = await weatherService.getWeatherWithSolarTerm(city: '北京');

result.fold(
  (data) {
    print('📍 ${data.weather.city.name}');
    print('🌡️ ${data.weather.currentTemperature}°C');
    print('🌱 ${data.solarTerm.name} - ${data.solarTerm.description}');
    print('📜 ${data.recommendedPoetry}');
  },
  (error) => print('❌ Error: ${error.message}'),
);
```

## API Keys

### WeatherAPI.com

- **URL**: https://www.weatherapi.com/
- **Free Tier**: 1 million calls/month
- **Coverage**: Global

### 和风天气 (QWeather)

- **URL**: https://dev.qweather.com/
- **Free Tier**: 1000 calls/day
- **Coverage**: China (best), Global

## Documentation

- [API Reference](https://pub.dev/documentation/weather_kit/latest/)

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

Made with ❤️ by [ZenKit Team](https://github.com/ZenKitX)
