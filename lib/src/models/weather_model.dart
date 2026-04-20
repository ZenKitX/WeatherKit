/// Location information
class LocationInfo {
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

  LocationInfo({
    required this.name,
    required this.region,
    required this.country,
    required this.lat,
    required this.lon,
  });

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

  CurrentWeather({
    required this.tempC,
    required this.conditionText,
    required this.humidity,
    required this.windKph,
    required this.uvIndex,
  });

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

  Map<String, dynamic> toJson() {
    return {
      'temp_c': tempC,
      'condition': {'text': conditionText},
      'humidity': humidity,
      'wind_kph': windKph,
      'uv': uvIndex,
    };
  }
}

/// Hourly forecast
class HourlyForecast {
  /// Time
  final DateTime time;

  /// Temperature in Celsius
  final double tempC;

  /// Weather condition text
  final String conditionText;

  /// Chance of rain percentage
  final int chanceOfRain;

  HourlyForecast({
    required this.time,
    required this.tempC,
    required this.conditionText,
    required this.chanceOfRain,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.parse(json['time']),
      tempC: (json['temp_c'] ?? 0).toDouble(),
      conditionText: json['condition']['text'] ?? '',
      chanceOfRain: json['chance_of_rain'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'temp_c': tempC,
      'condition': {'text': conditionText},
      'chance_of_rain': chanceOfRain,
    };
  }
}

/// Daily forecast
class DailyForecast {
  /// Date
  final DateTime date;

  /// Maximum temperature in Celsius
  final double maxTempC;

  /// Minimum temperature in Celsius
  final double minTempC;

  /// Weather condition text
  final String conditionText;

  /// Chance of rain percentage
  final int chanceOfRain;

  DailyForecast({
    required this.date,
    required this.maxTempC,
    required this.minTempC,
    required this.conditionText,
    required this.chanceOfRain,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final day = json['day'] ?? {};

    return DailyForecast(
      date: DateTime.parse(json['date']),
      maxTempC: (day['maxtemp_c'] ?? 0).toDouble(),
      minTempC: (day['mintemp_c'] ?? 0).toDouble(),
      conditionText: day['condition']['text'] ?? '',
      chanceOfRain: day['daily_chance_of_rain'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().substring(0, 10),
      'day': {
        'maxtemp_c': maxTempC,
        'mintemp_c': minTempC,
        'condition': {'text': conditionText},
        'daily_chance_of_rain': chanceOfRain,
      },
    };
  }
}

/// Complete weather model
class WeatherData {
  /// Location information
  final LocationInfo location;

  /// Current weather
  final CurrentWeather current;

  /// Hourly forecast
  final List<HourlyForecast> hourly;

  /// Daily forecast
  final List<DailyForecast> daily;

  WeatherData({
    required this.location,
    required this.current,
    List<HourlyForecast>? hourly,
    List<DailyForecast>? daily,
  })  : hourly = hourly ?? const [],
        daily = daily ?? const [];

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final forecast = json['forecast'] ?? {};

    List<HourlyForecast>? hourlyList;
    if (forecast['forecastday'] != null) {
      final forecastDays = forecast['forecastday'] as List;
      if (forecastDays.isNotEmpty) {
        final hours = forecastDays[0]['hour'] as List;
        hourlyList = hours.map((e) => HourlyForecast.fromJson(e)).toList();
      }
    }

    List<DailyForecast>? dailyList;
    if (forecast['forecastday'] != null) {
      dailyList = (forecast['forecastday'] as List)
          .map((e) => DailyForecast.fromJson(e))
          .toList();
    }

    return WeatherData(
      location: LocationInfo.fromJson(json),
      current: CurrentWeather.fromJson(json),
      hourly: hourlyList ?? const [],
      daily: dailyList ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'current': current.toJson(),
      'forecast': {
        'forecastday': [
          {
            'hour': hourly.map((e) => e.toJson()).toList(),
          },
          ...daily.map((e) => e.toJson()).toList(),
        ],
      },
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeatherData &&
        other.location == location &&
        other.current == current;
  }

  @override
  int get hashCode => Object.hash(location, current);
}
