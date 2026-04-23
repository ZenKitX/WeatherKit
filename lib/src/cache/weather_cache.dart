import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/weather_domain.dart';

/// Cache policy configuration
class CachePolicy {
  const CachePolicy({
    this.ttl = const Duration(minutes: 30),
    this.maxEntries = 50,
    this.staleWhileRevalidate = false,
    this.useLRU = true,
  });

  /// Time-to-live for cache entries
  final Duration ttl;

  /// Maximum number of entries in cache
  final int maxEntries;

  /// Return stale data while revalidating in background
  final bool staleWhileRevalidate;

  /// Use LRU (Least Recently Used) eviction policy
  final bool useLRU;

  /// Default cache policy
  static const defaultPolicy = CachePolicy();

  /// Aggressive caching (longer TTL, more entries)
  static const aggressive = CachePolicy(
    ttl: Duration(hours: 2),
    maxEntries: 100,
    staleWhileRevalidate: true,
  );

  /// Conservative caching (shorter TTL, fewer entries)
  static const conservative = CachePolicy(
    ttl: Duration(minutes: 10),
    maxEntries: 20,
    staleWhileRevalidate: false,
  );
}

/// Cache entry metadata
class _CacheEntry<T> {
  _CacheEntry({
    required this.data,
    required this.timestamp,
    required this.accessCount,
  });

  final T data;
  final DateTime timestamp;
  int accessCount;
}

/// Cache statistics
class CacheStats {
  CacheStats({
    this.hits = 0,
    this.misses = 0,
    this.size = 0,
    this.totalSizeBytes = 0,
  });

  final int hits;
  final int misses;
  final int size;
  final int totalSizeBytes;

  int get totalRequests => hits + misses;

  double get hitRate => totalRequests > 0 ? hits / totalRequests : 0.0;

  double get missRate => totalRequests > 0 ? misses / totalRequests : 0.0;

  CacheStats copyWith({
    int? hits,
    int? misses,
    int? size,
    int? totalSizeBytes,
  }) {
    return CacheStats(
      hits: hits ?? this.hits,
      misses: misses ?? this.misses,
      size: size ?? this.size,
      totalSizeBytes: totalSizeBytes ?? this.totalSizeBytes,
    );
  }

  @override
  String toString() {
    return 'CacheStats(hits: $hits, misses: $misses, size: $size, '
        'hitRate: ${(hitRate * 100).toStringAsFixed(1)}%)';
  }
}

/// Transparent cache with policy-based management and statistics
class WeatherCache {
  static const String _cacheKeyPrefix = 'weather_cache_';
  static const String _cacheTimeKeyPrefix = 'weather_cache_time_';
  static const String _cacheAccessKeyPrefix = 'weather_cache_access_';

  final CachePolicy policy;
  final Map<String, _CacheEntry<String>> _memoryCache;
  final Random _random;

  /// In-flight requests to avoid duplicate API calls
  final Map<String, Future<Weather>> _inFlightRequests = {};

  WeatherCache({
    this.policy = CachePolicy.defaultPolicy,
  })  : _memoryCache = {},
        _random = Random();

  /// Get current cache statistics
  CacheStats get stats {
    return _memoryCache.isEmpty
        ? CacheStats()
        : CacheStats(
            hits: _hits,
            misses: _misses,
            size: _memoryCache.length,
            totalSizeBytes: _totalSizeBytes,
          );
  }

  int _hits = 0;
  int _misses = 0;
  int get _totalSizeBytes => _memoryCache.values
      .fold<int>(0, (sum, entry) => sum + entry.data.length);

  /// Get cached weather data
  Future<Weather?> get(String key) async {
    // Check in-flight requests first
    if (_inFlightRequests.containsKey(key)) {
      return await _inFlightRequests[key];
    }

    final entry = _memoryCache[key];

    if (entry == null) {
      _misses++;
      return null;
    }

    // Check TTL
    final age = DateTime.now().difference(entry.timestamp);
    if (age > policy.ttl && !policy.staleWhileRevalidate) {
      _misses++;
      // Clean up expired entry
      _remove(key);
      return null;
    }

    _hits++;
    entry.accessCount++;

    // Try to parse JSON
    try {
      final jsonData = jsonDecode(entry.data);
      // Convert JSON back to Weather domain model
      return _parseWeatherFromJson(jsonData);
    } catch (e) {
      // Cache corrupted, remove it
      _remove(key);
      _misses++;
      return null;
    }
  }

  /// Save weather data to cache
  Future<void> set(String key, Weather weather) async {
    final jsonStr = jsonEncode(weather);

    // Check max entries limit
    if (_memoryCache.length >= policy.maxEntries) {
      _evictOldest();
    }

    _memoryCache[key] = _CacheEntry(
      data: jsonStr,
      timestamp: DateTime.now(),
      accessCount: 0,
    );

    // Also persist to SharedPreferences for durability
    await _persistToDisk(key, jsonStr);
  }

  /// Remove cached weather data
  void remove(String key) {
    _remove(key);
  }

  void _remove(String key) {
    _memoryCache.remove(key);
    _inFlightRequests.remove(key);
    _removeFromDisk(key);
  }

  /// Check if cache is valid
  Future<bool> isCacheValid(String key) async {
    final entry = _memoryCache[key];
    if (entry == null) return false;

    final age = DateTime.now().difference(entry.timestamp);
    return age < policy.ttl;
  }

  /// Get cache entry age
  Duration? getAge(String key) {
    final entry = _memoryCache[key];
    return entry != null ? DateTime.now().difference(entry.timestamp) : null;
  }

  /// Register an in-flight request
  void registerInFlightRequest(String key, Future<Weather> request) {
    _inFlightRequests[key] = request;

    // Clean up when request completes
    request.then((_) {
      _inFlightRequests.remove(key);
    }).catchError((_) {
      _inFlightRequests.remove(key);
    });
  }

  /// Check if there's an in-flight request for this key
  bool hasInFlightRequest(String key) {
    return _inFlightRequests.containsKey(key);
  }

  /// Get in-flight request
  Future<Weather>? getInFlightRequest(String key) {
    return _inFlightRequests[key];
  }

  /// Clear all cache
  void clear() {
    _memoryCache.clear();
    _hits = 0;
    _misses = 0;
    _clearDisk();
  }

  /// Clear expired cache entries
  void clearExpired() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _memoryCache.entries) {
      if (now.difference(entry.value.timestamp) > policy.ttl) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _remove(key);
    }
  }

  /// Evict oldest entry based on policy
  void _evictOldest() {
    if (_memoryCache.isEmpty) return;

    if (policy.useLRU) {
      // Find least recently accessed (lowest accessCount)
      String? oldestKey;
      int minAccess = 0x7FFFFFFF;

      for (final entry in _memoryCache.entries) {
        if (entry.value.accessCount < minAccess) {
          minAccess = entry.value.accessCount;
          oldestKey = entry.key;
        }
      }

      if (oldestKey != null) {
        _remove(oldestKey);
      }
    } else {
      // Random eviction
      final keys = _memoryCache.keys.toList();
      if (keys.isNotEmpty) {
        final randomKey = keys[_random.nextInt(keys.length)];
        _remove(randomKey);
      }
    }
  }

  /// Reset statistics
  void resetStats() {
    _hits = 0;
    _misses = 0;
  }

  // Disk persistence methods

  Future<void> _persistToDisk(String key, String data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cacheKeyPrefix${key.hashCode}';
    final timeKey = '$_cacheTimeKeyPrefix${key.hashCode}';
    final accessKey = '$_cacheAccessKeyPrefix${key.hashCode}';

    final entry = _memoryCache[key]!;
    await prefs.setString(cacheKey, data);
    await prefs.setString(timeKey, entry.timestamp.toIso8601String());
    await prefs.setInt(accessKey, entry.accessCount);
  }

  Future<void> _removeFromDisk(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_cacheKeyPrefix${key.hashCode}');
    await prefs.remove('$_cacheTimeKeyPrefix${key.hashCode}');
    await prefs.remove('$_cacheAccessKeyPrefix${key.hashCode}');
  }

  Future<void> _clearDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) =>
      key.startsWith(_cacheKeyPrefix) ||
      key.startsWith(_cacheTimeKeyPrefix) ||
      key.startsWith(_cacheAccessKeyPrefix)
    );

    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Load cache from disk (call on startup)
  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKeys = prefs.getKeys().where((key) =>
      key.startsWith(_cacheKeyPrefix)
    );

    for (final cacheKey in cacheKeys) {
      try {
        final data = prefs.getString(cacheKey);
        if (data != null) {
          final timeKey = cacheKey.replaceFirst(_cacheKeyPrefix, _cacheTimeKeyPrefix);
          final accessKey = cacheKey.replaceFirst(_cacheKeyPrefix, _cacheAccessKeyPrefix);

          final timeStr = prefs.getString(timeKey);
          final accessCount = prefs.getInt(accessKey) ?? 0;

          if (timeStr != null) {
            final timestamp = DateTime.parse(timeStr);
            // Check if expired
            if (DateTime.now().difference(timestamp) <= policy.ttl) {
              final originalKey = cacheKey.substring(_cacheKeyPrefix.length);
              _memoryCache[originalKey] = _CacheEntry(
                data: data,
                timestamp: timestamp,
                accessCount: accessCount,
              );
            }
          }
        }
      } catch (e) {
        // Skip corrupted entries
      }
    }
  }

  /// Parse Weather from JSON
  Weather _parseWeatherFromJson(Map<String, dynamic> json) {
    return Weather(
      city: City.fromJson(json['city'] ?? {}),
      currentTemperature: (json['currentTemperature'] ?? 0).toDouble(),
      condition: _parseCondition(json['condition']),
      humidity: json['humidity'] ?? 0,
      windSpeed: (json['windSpeed'] ?? 0).toDouble(),
      currentTime: DateTime.parse(json['currentTime']),
      hourlyForecast: (json['hourlyForecast'] as List?)
          ?.map((e) => _parseHourlyForecast(e))
          .toList() ?? [],
      dailyForecast: (json['dailyForecast'] as List?)
          ?.map((e) => _parseDailyForecast(e))
          .toList() ?? [],
    );
  }

  WeatherCondition _parseCondition(dynamic value) {
    if (value is WeatherCondition) return value;
    if (value is String) {
      return WeatherCondition.values.firstWhere(
        (e) => e.name == value,
        orElse: () => WeatherCondition.unknown,
      );
    }
    return WeatherCondition.unknown;
  }

  HourlyForecast _parseHourlyForecast(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.parse(json['time']),
      temperature: (json['temperature'] ?? 0).toDouble(),
      condition: _parseCondition(json['condition']),
      humidity: json['humidity'] ?? 0,
      windSpeed: (json['windSpeed'] ?? 0).toDouble(),
    );
  }

  DailyForecast _parseDailyForecast(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.parse(json['date']),
      maxTemp: (json['maxTemp'] ?? 0).toDouble(),
      minTemp: (json['minTemp'] ?? 0).toDouble(),
      condition: _parseCondition(json['condition']),
      sunrise: DateTime.parse(json['sunrise']),
      sunset: DateTime.parse(json['sunset']),
      uvIndex: json['uvIndex'] ?? 0,
    );
  }

  // Legacy methods for backward compatibility
  @Deprecated('Use get() instead')
  Future<Weather?> getWeather(String location) => get(location);

  @Deprecated('Use set() instead')
  Future<void> saveWeather(String location, Weather weather) => set(location, weather);

  @Deprecated('Use remove() instead')
  Future<void> clearCache(String location) async {
    remove(location);
  }
}
