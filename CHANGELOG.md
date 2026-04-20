# Changelog

All notable changes to the WeatherKit package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-04-20

### Added
- Initial release of WeatherKit package
- **Core Architecture**
  - Provider abstraction pattern for multiple weather data sources
  - Independent domain models (Weather, City, Forecast)
  - Result type for error handling
  - Transparent caching with TTL, LRU eviction, and request deduplication

- **Weather Providers**
  - WeatherApiProvider (WeatherAPI.com)
  - QWeatherProvider (和风天气)
  - Provider configuration and switching

- **Security**
  - Secure API key storage
  - Multiple key sources (dart-define, .env, hardcoded)
  - API key validation

- **Ecosystem Integration**
  - LocationKit integration for current location queries
  - SolarTermKit integration for solar term information
  - Poetry recommendations based on weather and solar terms
  - One-click location + weather + poetry queries

- **Caching**
  - Configurable cache policies (TTL, max entries, stale-while-revalidate)
  - Cache statistics and performance monitoring
  - Persistent storage with SharedPreferences

- **Examples**
  - Basic weather queries
  - Provider switching examples
  - Secure key loading
  - Ecosystem integration demo

### Documentation
- Comprehensive README with architecture overview
- API documentation for all public interfaces
- QWeather vs WeatherAPI comparison guide
- Ecosystem integration guide

### Tested On
- Flutter 3.24.0+
- Dart 3.11.0+
- iOS and Android platforms

---

## [Unreleased]

### Planned
- Support for more weather providers
- Unit tests for all providers
- Integration tests for ecosystem features
- GitHub Actions CI configuration
- Pub.dev publication
