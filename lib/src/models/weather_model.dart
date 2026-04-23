/// Location information
class LocationInfo {
  LocationInfo({
    required this.name,
    required this.region,
    required this.country,
    required this.lat,
    required this.lon,
  });

  /// Create LocationInfo from JSON
  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? json;
    return LocationInfo(
      name: location['name'] ?? '',
      region: location['region'] ?? '',
      country: location['country'] ?? '',
      lat: (location['lat'] ?? 0).toDouble(),
      lon: (location['lon'] ?? 0).toDouble(),
    );
  }

  /// City name
  final String name;

  /// Region/state
  final String region;

  /// Country
  final String country;

  /// Latitude
  final double lat;

  /// Longitude
  final double lon;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'region': region,
      'country': country,
      'lat': lat,
      'lon': lon,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationInfo &&
        other.name == name &&
        other.region == region &&
        other.country == country &&
        other.lat == lat &&
        other.lon == lon;
  }

  @override
  int get hashCode => Object.hash(name, region, country, lat, lon);

  @override
  String toString() => '$name, $region, $country';
}

/// Current weather conditions
class CurrentWeather {
  CurrentWeather({
    required this.tempC,
    required this.conditionText,
    required this.humidity,
    required this.windKph,
    required this.uvIndex,
  });

  /// Create CurrentWeather from JSON
  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] ?? json;
    final condition = current['condition'] ?? {};

    return CurrentWeather(
      tempC: (current['temp_c'] ?? 0).toDouble(),
      conditionText: condition['text'] ?? '',
      humidity: current['humidity'] ?? 0,
      windKph: (current['wind_kph'] ?? 0).toDouble(),
      uvIndex: current['uv'] ?? 0,
    );
  }

  /// Temperature in Celsius
  final double tempC;

  /// Weather condition text
  final String conditionText;

  /// Humidity percentage
  final int humidity;

  /// Wind speed in km/h
  final double windKph;

  /// UV index
  final int uvIndex;

  Map<String, dynamic> toJson() {
    return {
      'temp_c': tempC,
      'condition_text': conditionText,
      'humidity': humidity,
      'wind_kph': windKph,
      'uv': uvIndex,
    };
  }

  @override
  String toString() =>
      'CurrentWeather: $tempC°C, $conditionText, Humidity: $humidity%';
}

/// Hourly weather forecast
class HourlyForecast {
  HourlyForecast({
    required this.time,
    required this.tempC,
    required this.conditionText,
    required this.isDay,
  });

  /// Create HourlyForecast from JSON
  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.parse(json['time']),
      tempC: (json['temp_c'] ?? 0).toDouble(),
      conditionText: json['condition_text'] ?? json['condition']?['text'] ?? '',
      isDay: json['is_day'] == 1,
    );
  }

  /// Forecast time
  final DateTime time;

  /// Temperature in Celsius
  final double tempC;

  /// Weather condition
  final String conditionText;

  /// Is daytime (1) or nighttime (0)
  final bool isDay;

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'temp_c': tempC,
      'condition_text': conditionText,
      'is_day': isDay ? 1 : 0,
    };
  }

  @override
  String toString() => '${time.hour}:00 - $tempC°C, $conditionText';
}

/// Daily weather forecast
class DailyForecast {
  DailyForecast({
    required this.date,
    required this.maxTempC,
    required this.minTempC,
    required this.conditionText,
    required this.sunrise,
    required this.sunset,
    required this.uvIndex,
  });

  /// Create DailyForecast from JSON
  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.parse(json['date']),
      maxTempC: (json['maxtemp_c'] ?? 0).toDouble(),
      minTempC: (json['mintemp_c'] ?? 0).toDouble(),
      conditionText:
          json['condition_text'] ?? json['day']?['condition']?['text'] ?? '',
      sunrise: json['sunrise'] ?? '',
      sunset: json['sunset'] ?? '',
      uvIndex: json['uv'] ?? 0,
    );
  }

  /// Date
  final DateTime date;

  /// Maximum temperature in Celsius
  final double maxTempC;

  /// Minimum temperature in Celsius
  final double minTempC;

  /// Weather condition
  final String conditionText;

  /// Sunrise time
  final String sunrise;

  /// Sunset time
  final String sunset;

  /// UV index
  final int uvIndex;

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'maxtemp_c': maxTempC,
      'mintemp_c': minTempC,
      'condition_text': conditionText,
      'sunrise': sunrise,
      'sunset': sunset,
      'uv': uvIndex,
    };
  }

  @override
  String toString() =>
      '${date.day}/${date.month}: ${minTempC.toInt()}°C~${maxTempC.toInt()}°C, $conditionText';
}

/// Complete weather data
class WeatherData {
  WeatherData({
    required this.location,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  /// Create WeatherData from WeatherAPI response
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final forecastDayList = json['forecast']?['forecastday'] as List?;

    final hourlyList = forecastDayList?.expand((day) {
          final hourData = day['hour'] as List?;
          if (hourData == null) return [];
          return hourData.map((h) => HourlyForecast.fromJson(h));
        }).toList() ??
        [];

    final dailyList =
        forecastDayList?.map((day) => DailyForecast.fromJson(day)).toList() ??
            [];

    return WeatherData(
      location: LocationInfo.fromJson(json),
      current: CurrentWeather.fromJson(json),
      hourly: hourlyList.cast<HourlyForecast>(),
      daily: dailyList.cast<DailyForecast>(),
    );
  }

  /// Location information
  final LocationInfo location;

  /// Current weather
  final CurrentWeather current;

  /// Hourly forecast (24 hours)
  final List<HourlyForecast> hourly;

  /// Daily forecast
  final List<DailyForecast> daily;

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'current': current.toJson(),
      'hourly': hourly.map((h) => h.toJson()).toList(),
      'daily': daily.map((d) => d.toJson()).toList(),
    };
  }

  /// Get current temperature with unit
  String get temperatureDisplay => '${current.tempC.toInt()}°C';

  /// Get weather icon code (simplified)
  String get weatherIcon => _getWeatherIconCode(current.conditionText);

  String _getWeatherIconCode(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('sunny') || lower.contains('clear')) return '01d';
    if (lower.contains('cloud')) return '02d';
    if (lower.contains('rain') || lower.contains('drizzle')) return '10d';
    if (lower.contains('snow')) return '13d';
    if (lower.contains('thunder')) return '11d';
    if (lower.contains('mist') || lower.contains('fog')) return '50d';
    return '01d';
  }

  @override
  String toString() =>
      'WeatherData(${location.name}: ${current.tempC}°C, ${current.conditionText})';
}
