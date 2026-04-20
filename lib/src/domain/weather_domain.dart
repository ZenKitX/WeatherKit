/// Domain models for WeatherKit - independent of any specific API
library;

/// Weather condition codes (independent of API)
enum WeatherCondition {
  clear,
  partlyCloudy,
  cloudy,
  rain,
  snow,
  thunderstorm,
  fog,
  mist,
  unknown,
}

/// Convert WeatherAPI condition to domain model
WeatherCondition conditionFromWeatherAPI(String condition) {
  final text = condition.toLowerCase();
  if (text.contains('rain') || text.contains('drizzle') || text.contains('shower')) {
    return WeatherCondition.rain;
  } else if (text.contains('snow') || text.contains('sleet') || text.contains('blizzard')) {
    return WeatherCondition.snow;
  } else if (text.contains('thunder') || text.contains('storm')) {
    return WeatherCondition.thunderstorm;
  } else if (text.contains('cloud')) {
    return text.contains('partly') ? WeatherCondition.partlyCloudy : WeatherCondition.cloudy;
  } else if (text.contains('fog') || text.contains('haze')) {
    return WeatherCondition.fog;
  } else if (text.contains('mist')) {
    return WeatherCondition.mist;
  } else if (text.contains('clear') || text.contains('sunny')) {
    return WeatherCondition.clear;
  }
  return WeatherCondition.unknown;
}

/// Domain model for city/location
class City {
  City({
    required this.name,
    required this.region,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String region;
  final String country;
  final double latitude;
  final double longitude;

  factory City.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? json;
    return City(
      name: location['name'] ?? '',
      region: location['region'] ?? '',
      country: location['country'] ?? '',
      latitude: (location['lat'] ?? 0).toDouble(),
      longitude: (location['lon'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'region': region,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is City &&
        other.name == name &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(name, latitude, longitude);

  @override
  String toString() => '$name, $country';
}

/// Hourly forecast
class HourlyForecast {
  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
  });

  final DateTime time;
  final double temperature;
  final WeatherCondition condition;
  final int humidity;
  final double windSpeed;
}

/// Daily forecast
class DailyForecast {
  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.condition,
    required this.sunrise,
    required this.sunset,
    required this.uvIndex,
  });

  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final WeatherCondition condition;
  final DateTime sunrise;
  final DateTime sunset;
  final int uvIndex;
}

/// Domain model for weather data (independent of API structure)
class Weather {
  Weather({
    required this.city,
    required this.currentTemperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.currentTime,
    this.hourlyForecast = const [],
    this.dailyForecast = const [],
  });

  final City city;
  final double currentTemperature;
  final WeatherCondition condition;
  final int humidity;
  final double windSpeed;
  final DateTime currentTime;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;
}

/// Search result for city
class CitySearchResult {
  CitySearchResult({
    required this.cities,
    required this.hasMore,
  });

  final List<City> cities;
  final bool hasMore;
}
