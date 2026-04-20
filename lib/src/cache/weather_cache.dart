import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';

/// Weather cache service for offline support
class WeatherCache {
  static const String _cacheKeyPrefix = 'weather_cache_';
  static const String _cacheTimeKeyPrefix = 'weather_cache_time_';

  /// Default cache duration: 30 minutes
  static const Duration defaultMaxAge = Duration(minutes: 30);

  /// Get cached weather data
  Future<WeatherData?> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cacheKeyPrefix${key.hashCode}';
    final cacheData = prefs.getString(cacheKey);

    if (cacheData != null) {
      try {
        return WeatherData.fromJson(jsonDecode(cacheData));
      } catch (e) {
        // Return null if JSON parsing fails
        return null;
      }
    }
    return null;
  }

  /// Save weather data to cache
  Future<void> set(String key, WeatherData weather, {Duration? ttl}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cacheKeyPrefix${key.hashCode}';
    final timeKey = '$_cacheTimeKeyPrefix${key.hashCode}';

    await prefs.setString(cacheKey, jsonEncode(weather.toJson()));
    await prefs.setString(timeKey, DateTime.now().toIso8601String());
  }

  /// Remove cached weather data
  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_cacheKeyPrefix${key.hashCode}');
    await prefs.remove('$_cacheTimeKeyPrefix${key.hashCode}');
  }

  /// Check if cache is valid
  Future<bool> isCacheValid(
    String key, {
    Duration maxAge = defaultMaxAge,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final timeKey = '$_cacheTimeKeyPrefix${key.hashCode}';
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
  Future<DateTime?> getCacheTime(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final timeKey = '$_cacheTimeKeyPrefix${key.hashCode}';
    final timeStr = prefs.getString(timeKey);

    if (timeStr == null) return null;

    try {
      return DateTime.parse(timeStr);
    } catch (e) {
      return null;
    }
  }

  /// Clear all weather cache
  Future<void> clear() async {
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

  // Legacy methods for backward compatibility
  @Deprecated('Use get() instead')
  Future<WeatherData?> getWeather(String location) => get(location);

  @Deprecated('Use set() instead')
  Future<void> saveWeather(String location, WeatherData weather) => set(location, weather);

  @Deprecated('Use remove() instead')
  Future<void> clearCache(String location) => remove(location);
}
