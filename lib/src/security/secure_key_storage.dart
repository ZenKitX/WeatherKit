/// Secure key storage and management for API keys
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import '../services/weather_service.dart';
import '../cache/weather_cache.dart';

/// API key source
enum KeySource {
  /// Environment variable (--dart-define)
  dartDefine,

  /// .env file
  envFile,

  /// Hardcoded string (deprecated, use only for testing)
  hardcoded,

  /// Not provided
  none,
}

/// API key validation result
class KeyValidationResult {
  KeyValidationResult({
    required this.isValid,
    this.error,
  });

  final bool isValid;
  final String? error;

  factory KeyValidationResult.success() {
    return KeyValidationResult(isValid: true);
  }

  factory KeyValidationResult.failure(String error) {
    return KeyValidationResult(isValid: false, error: error);
  }
}

/// Secure key storage for API keys
class SecureKeyStorage {
  SecureKeyStorage._();

  /// Get singleton instance
  static final SecureKeyStorage instance = SecureKeyStorage._();

  /// Get API key from multiple sources in priority order
  ///
  /// Priority:
  /// 1. Dart define (--dart-define=WEATHER_API_KEY=xxx)
  /// 2. Environment variable
  /// 3. .env file
  /// 4. Provided hardcoded value
  ///
  /// [keyName] - Name of the key (e.g., 'WEATHER_API_KEY')
  /// [hardcodedValue] - Fallback hardcoded value (deprecated)
  /// [allowHardcoded] - Allow using hardcoded value (default: false)
  ///
  /// Returns (value, source)
  static (String, KeySource) getApiKey({
    required String keyName,
    String? hardcodedValue,
    bool allowHardcoded = false,
  }) {
    // 1. Check dart-define
    final dartDefineValue = String.fromEnvironment(keyName);
    if (dartDefineValue.isNotEmpty) {
      return (dartDefineValue, KeySource.dartDefine);
    }

    // 2. Check .env file
    try {
      if (dotenv.env[keyName]?.isNotEmpty == true) {
        return (dotenv.env[keyName]!, KeySource.envFile);
      }
    } catch (e) {
      // .env loading failed, continue
    }

    // 3. Check hardcoded value
    if (hardcodedValue != null && hardcodedValue.isNotEmpty) {
      if (!allowHardcoded) {
        print(
          'Warning: Using hardcoded API key for $keyName. '
          'This is not recommended for production. '
          'Use --dart-define or .env file instead.',
        );
      }
      return (hardcodedValue, KeySource.hardcoded);
    }

    throw StateError(
      'API key "$keyName" not found. '
      'Please provide it via --dart-define, .env file, or parameter.',
    );
  }

  /// Validate API key format
  ///
  /// [apiKey] - The API key to validate
  /// [provider] - Provider name for error messages
  static KeyValidationResult validateApiKey({
    required String? apiKey,
    required String provider,
  }) {
    if (apiKey == null || apiKey.isEmpty) {
      return KeyValidationResult.failure('$provider API key is empty');
    }

    // Basic validation - adjust per provider requirements
    if (apiKey.length < 5) {
      return KeyValidationResult.failure(
        '$provider API key is too short (minimum 5 characters)',
      );
    }

    return KeyValidationResult.success();
  }

  /// Prevalidate multiple API keys
  ///
  /// [keys] - Map of provider name to API key
  static Map<String, KeyValidationResult> validateKeys(
      Map<String, String> keys) {
    final results = <String, KeyValidationResult>{};
    for (final entry in keys.entries) {
      results[entry.key] = validateApiKey(
        apiKey: entry.value,
        provider: entry.key,
      );
    }
    return results;
  }

  /// Load .env file from assets or file system
  ///
  /// [fileName] - .env file name (default: '.env')
  /// [useAssetLoader] - Load from assets (for Flutter apps)
  static Future<void> loadEnvFile({
    String fileName = '.env',
    bool useAssetLoader = true,
  }) async {
    try {
      if (useAssetLoader) {
        await dotenv.load(fileName: fileName);
      } else {
        final file = File(fileName);
        if (await file.exists()) {
          await dotenv.load(fileName: fileName);
        }
      }
    } catch (e) {
      // .env file not found or error loading - not critical
      // Keys might be provided via dart-define
    }
  }
}

/// Helper to create WeatherService with secure key loading
class WeatherServiceSecureFactory {
  /// Create WeatherService with secure API key loading
  ///
  /// Automatically loads API key from multiple sources in priority order
  static WeatherService withSecureKey({
    String keyName = 'WEATHER_API_KEY',
    String? hardcodedValue,
    bool allowHardcoded = false,
    WeatherCache? cache,
    String? baseUrl,
    bool validateOnStart = true,
  }) {
    final (apiKey, source) = SecureKeyStorage.getApiKey(
      keyName: keyName,
      hardcodedValue: hardcodedValue,
      allowHardcoded: allowHardcoded,
    );

    if (validateOnStart) {
      final validation = SecureKeyStorage.validateApiKey(
        apiKey: apiKey,
        provider: 'WeatherAPI',
      );
      if (!validation.isValid) {
        throw StateError(
          'Invalid API key: ${validation.error}\n'
          'Source: $source',
        );
      }
    }

    return WeatherService.withWeatherAPI(
      apiKey: apiKey,
      cache: cache,
      baseUrl: baseUrl,
    );
  }
}
