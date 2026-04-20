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

  /// Local time
  final String localtime;

  LocationInfo({
    required this.name,
    required this.region,
    required this.country,
    required this.lat,
    required this.lon,
    required this.localtime,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? json;
    return LocationInfo(
      name: location['name'] ?? '',
      region: location['region'] ?? '',
      country: location['country'] ?? '',
      lat: (location['lat'] ?? 0).toDouble(),
      lon: (location['lon'] ?? 0).toDouble(),
      localtime: location['localtime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'region': region,
      'country': country,
      'lat': lat,
      'lon': lon,
      'localtime': localtime,
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
  int get hashCode =>
      Object.hash(name, region, country, lat, lon);

  @override
  String toString() {
    return '$name, $region, $country';
  }
}

/// Current weather conditions
class CurrentWeather {
  /// Temperature in Celsius
  final double tempC;

  /// Temperature in Fahrenheit
  final double tempF;

  /// Weather condition code
  final int conditionCode;

  /// Weather condition text
  final String conditionText;

  /// Weather icon URL
  final String icon;

  /// Wind speed in km/h
  final double windKph;

  /// Wind speed in mph
  final double windMph;

  /// Wind direction degree
  final int windDegree;

  /// Humidity percentage
  final int humidity;

  /// Feels like temperature in Celsius
  final double feelslikeC;

  /// Feels like temperature in Fahrenheit
  final double feelslikeF;

  /// Visibility in km
  final double visKm;

  /// Visibility in miles
  final double visMiles;

  /// Pressure in mb
  final double pressureMb;

  /// Pressure in inches
  final double pressureIn;

  /// UV index
  final double uv;

  CurrentWeather({
    required this.tempC,
    required this.tempF,
    required this.conditionCode,
    required this.conditionText,
    required this.icon,
    required this.windKph,
    required this.windMph,
    required this.windDegree,
    required this.humidity,
    required this.feelslikeC,
    required this.feelslikeF,
    required this.visKm,
    required this.visMiles,
    required this.pressureMb,
    required this.pressureIn,
    required this.uv,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] ?? json;
    final condition = current['condition'] ?? {};

    return CurrentWeather(
      tempC: (current['temp_c'] ?? 0).toDouble(),
      tempF: (current['temp_f'] ?? 0).toDouble(),
      conditionCode: condition['code'] ?? 0,
      conditionText: condition['text'] ?? '',
      icon: condition['icon'] ?? '',
      windKph: (current['wind_kph'] ?? 0).toDouble(),
      windMph: (current['wind_mph'] ?? 0).toDouble(),
      windDegree: current['wind_degree'] ?? 0,
      humidity: current['humidity'] ?? 0,
      feelslikeC: (current['feelslike_c'] ?? 0).toDouble(),
      feelslikeF: (current['feelslike_f'] ?? 0).toDouble(),
      visKm: (current['vis_km'] ?? 0).toDouble(),
      visMiles: (current['vis_miles'] ?? 0).toDouble(),
      pressureMb: (current['pressure_mb'] ?? 0).toDouble(),
      pressureIn: (current['pressure_in'] ?? 0).toDouble(),
      uv: (current['uv'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temp_c': tempC,
      'temp_f': tempF,
      'condition': {
        'code': conditionCode,
        'text': conditionText,
        'icon': icon,
      },
      'wind_kph': windKph,
      'wind_mph': windMph,
      'wind_degree': windDegree,
      'humidity': humidity,
      'feelslike_c': feelslikeC,
      'feelslike_f': feelslikeF,
      'vis_km': visKm,
      'vis_miles': visMiles,
      'pressure_mb': pressureMb,
      'pressure_in': pressureIn,
      'uv': uv,
    };
  }
}

/// Hourly forecast
class HourlyForecast {
  /// Time
  final String time;

  /// Temperature in Celsius
  final double tempC;

  /// Temperature in Fahrenheit
  final double tempF;

  /// Condition code
  final int conditionCode;

  /// Condition text
  final String conditionText;

  /// Icon
  final String icon;

  /// Chance of rain percentage
  final int chanceOfRain;

  HourlyForecast({
    required this.time,
    required this.tempC,
    required this.tempF,
    required this.conditionCode,
    required this.conditionText,
    required this.icon,
    required this.chanceOfRain,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: json['time'] ?? '',
      tempC: (json['temp_c'] ?? 0).toDouble(),
      tempF: (json['temp_f'] ?? 0).toDouble(),
      conditionCode: json['condition']['code'] ?? 0,
      conditionText: json['condition']['text'] ?? '',
      icon: json['condition']['icon'] ?? '',
      chanceOfRain: json['chance_of_rain'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'temp_c': tempC,
      'temp_f': tempF,
      'condition': {
        'code': conditionCode,
        'text': conditionText,
        'icon': icon,
      },
      'chance_of_rain': chanceOfRain,
    };
  }
}

/// Daily forecast
class DailyForecast {
  /// Date
  final String date;

  /// Maximum temperature in Celsius
  final double maxTempC;

  /// Maximum temperature in Fahrenheit
  final double maxTempF;

  /// Minimum temperature in Celsius
  final double minTempC;

  /// Minimum temperature in Fahrenheit
  final double minTempF;

  /// Average temperature in Celsius
  final double avgTempC;

  /// Average temperature in Fahrenheit
  final double avgTempF;

  /// Condition code
  final int conditionCode;

  /// Condition text
  final String conditionText;

  /// Icon
  final String icon;

  /// Maximum UV index
  final double maxUv;

  /// Total precipitation in mm
  final double totalprecipMm;

  /// Total precipitation in inches
  final double totalprecipIn;

  /// Chance of rain percentage
  final int dailyChanceOfRain;

  DailyForecast({
    required this.date,
    required this.maxTempC,
    required this.maxTempF,
    required this.minTempC,
    required this.minTempF,
    required this.avgTempC,
    required this.avgTempF,
    required this.conditionCode,
    required this.conditionText,
    required this.icon,
    required this.maxUv,
    required this.totalprecipMm,
    required this.totalprecipIn,
    required this.dailyChanceOfRain,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final day = json['day'] ?? {};

    return DailyForecast(
      date: json['date'] ?? '',
      maxTempC: (day['maxtemp_c'] ?? 0).toDouble(),
      maxTempF: (day['maxtemp_f'] ?? 0).toDouble(),
      minTempC: (day['mintemp_c'] ?? 0).toDouble(),
      minTempF: (day['mintemp_f'] ?? 0).toDouble(),
      avgTempC: (day['avgtemp_c'] ?? 0).toDouble(),
      avgTempF: (day['avgtemp_f'] ?? 0).toDouble(),
      conditionCode: day['condition']['code'] ?? 0,
      conditionText: day['condition']['text'] ?? '',
      icon: day['condition']['icon'] ?? '',
      maxUv: (day['uv'] ?? 0).toDouble(),
      totalprecipMm: (day['totalprecip_mm'] ?? 0).toDouble(),
      totalprecipIn: (day['totalprecip_in'] ?? 0).toDouble(),
      dailyChanceOfRain: day['daily_chance_of_rain'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': {
        'maxtemp_c': maxTempC,
        'maxtemp_f': maxTempF,
        'mintemp_c': minTempC,
        'mintemp_f': minTempF,
        'avgtemp_c': avgTempC,
        'avgtemp_f': avgTempF,
        'condition': {
          'code': conditionCode,
          'text': conditionText,
          'icon': icon,
        },
        'uv': maxUv,
        'totalprecip_mm': totalprecipMm,
        'totalprecip_in': totalprecipIn,
        'daily_chance_of_rain': dailyChanceOfRain,
      },
    };
  }
}

/// Complete weather model
class WeatherModel {
  /// Location information
  final LocationInfo location;

  /// Current weather
  final CurrentWeather current;

  /// Hourly forecast (24 hours)
  final List<HourlyForecast>? hourly;

  /// Daily forecast (7 days)
  final List<DailyForecast>? daily;

  WeatherModel({
    required this.location,
    required this.current,
    this.hourly,
    this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
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

    return WeatherModel(
      location: LocationInfo.fromJson(json),
      current: CurrentWeather.fromJson(json),
      hourly: hourlyList,
      daily: dailyList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'current': current.toJson(),
      'forecast': {
        'forecastday': daily?.map((e) => e.toJson()).toList(),
      },
    };
  }

  @override
  String toString() {
    return 'WeatherModel(location: ${location.name}, temp: ${current.tempC}°C)';
  }
}
