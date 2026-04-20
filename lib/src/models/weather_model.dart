/// Complete weather data
class WeatherData {
  /// Create WeatherData from WeatherAPI response
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final forecastDayList = json['forecast']?['forecastday'] as List?;
    
    final hourlyList = forecastDayList
            ?.expand((day) {
              final hourData = day['hour'] as List?;
              if (hourData == null) return [];
              return hourData.map((h) => HourlyForecast.fromJson(h));
            })
            .toList() ??
        [];
    
    final dailyList = forecastDayList
            ?.map((day) => DailyForecast.fromJson(day))
            .toList() ??
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

  WeatherData({
    required this.location,
    required this.current,
    required this.hourly,
    required this.daily,
  });

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
