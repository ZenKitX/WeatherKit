import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';

/// Weather cache service for offline support
class WeatherCache {
  static const String _cacheKeyPrefix = 'weather_cache_';
  static const String _cacheTimeKeyPrefix = 'weather_cache_time_';

  /// Default cache duration: 30 minutes
  static const Duration defaultMaxAge = Duration(minutes: 30);

  /// Save weather data to cache
  Future<void> saveWeather(String location, WeatherModel weather) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cacheKeyPrefix${location.hashCode}';
    final timeKey = '$_cacheTimeKeyPrefix${location.hashCode}';

    await prefs.setString(cacheKey, jsonEncode(weather.toJson()));
    await prefs.setString(timeKey, DateTime.now().toIso8601String());
  }

  /// Get cached weather data
  Future<WeatherModel?> getWeather(String location) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cacheKeyPrefix${location.hashCode}';
    final cacheData = prefs.getString(cacheKey);

    if (cacheData != null) {
      try {
        return WeatherModel.fromJson(jsonDecode(cacheData));
      } catch (e) {
        // Return null if JSON parsing fails
        return null;
      }
    }
    return null;
  }

  /// Check if cache is valid
  Future<bool> isCacheValid(
    String location, {
    Duration maxAge = defaultMaxAge,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final timeKey = '$_cacheTimeKeyPrefix${location.hashCode}';
    final timeStr = prefs.getString(timeKey);

    if (timeStr == null) return false;

    try {
      final cacheTime = DateTime.parse(timeStr);
      return DateTime.now().difference(cacheTime) < maxAge;
    } catch (e) {
      return false;
    }
  }

  /// Get cache time
  Future<DateTime?> getCacheTime(String location) async {
    final prefs = await SharedPreferences.getInstance();
    final timeKey = '$_cacheTimeKeyPrefix${location.hashCode}';
    final timeStr = prefs.getString(timeKey);

    if (timeStr == null) return null;

    try {
      return DateTime.parse(timeStr);
    } catch (e) {
      return null;
    }
  }

  /// Clear cache for a specific location
  Future<void> clearCache(String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_cacheKeyPrefix${location.hashCode}');
    await prefs.remove('$_cacheTimeKeyPrefix${location.hashCode}');
  }

  /// Clear all weather cache
  Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) =>
      key.startsWith(_cacheKeyPrefix) || key.startsWith(_cacheTimeKeyPrefix)
    );

    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    final prefs = await SharedPreferences.getInstance();
    int size = 0;

    final keys = prefs.getKeys().where((key) =>
      key.startsWith(_cacheKeyPrefix)
    );

    for (final key in keys) {
      final value = prefs.getString(key);
      if (value != null) {
        size += value.length;
      }
    }

    return size;
  }
}
