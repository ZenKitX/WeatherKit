// ignore_for_file: avoid_print

/// Benchmark tests for WeatherKit.
///
/// Run with: dart run benchmark/weather_benchmark.dart
library;

import 'package:weather_kit/weather_kit.dart';

void main() {
  print('=== WeatherKit Performance Benchmark ===\n');

  // Warm up
  print('Warming up...');
  final warmupService = WeatherService(
    apiKey: 'test_key',
    cache: WeatherCache(),
  );
  for (int i = 0; i < 100; i++) {
    warmupService._testInternalOperation();
  }
  print('Warm up complete.\n');

  // Run benchmarks
  benchmarkResultCreation();
  benchmarkErrorCreation();
  benchmarkCacheOperations();
  benchmarkDataParsing();

  print('\n=== Benchmark Complete ===');
}

void benchmarkResultCreation() {
  print('--- Result Creation Benchmark ---');

  final stopwatch = Stopwatch()..start();
  const iterations = 100000;

  for (int i = 0; i < iterations; i++) {
    final result = Result.success(i);
    result.fold((data) => data * 2, (error) => 0);
  }

  stopwatch.stop();
  final avgTime = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  Result.success: ${avgTime.toStringAsFixed(2)} μs/op ($iterations ops)',
  );

  stopwatch.reset();
  stopwatch.start();

  for (int i = 0; i < iterations; i++) {
    final error = WeatherError.network('Test error');
    final result = Result<int>.failure(error);
    result.fold((data) => data * 2, (error) => error.message.length);
  }

  stopwatch.stop();
  final avgTime2 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  Result.failure: ${avgTime2.toStringAsFixed(2)} μs/op ($iterations ops)',
  );
  print('');
}

void benchmarkErrorCreation() {
  print('--- Error Creation Benchmark ---');

  final stopwatch = Stopwatch()..start();
  const iterations = 100000;

  for (int i = 0; i < iterations; i++) {
    WeatherError.network('Test error');
  }

  stopwatch.stop();
  final avgTime = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  WeatherError.network: ${avgTime.toStringAsFixed(2)} μs/op ($iterations ops)',
  );

  stopwatch.reset();
  stopwatch.start();

  for (int i = 0; i < iterations; i++) {
    WeatherError.parsing('Test error');
  }

  stopwatch.stop();
  final avgTime2 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  WeatherError.parsing: ${avgTime2.toStringAsFixed(2)} μs/op ($iterations ops)',
  );

  stopwatch.reset();
  stopwatch.start();

  for (int i = 0; i < iterations; i++) {
    WeatherError.apiKey('Test error');
  }

  stopwatch.stop();
  final avgTime3 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  WeatherError.apiKey: ${avgTime3.toStringAsFixed(2)} μs/op ($iterations ops)',
  );
  print('');
}

void benchmarkCacheOperations() {
  print('--- Cache Operations Benchmark ---');

  final cache = WeatherCache();
  const iterations = 10000;

  final testData = WeatherData(
    location: LocationInfo(
      name: 'Test City',
      region: 'Test Region',
      country: 'Test Country',
      lat: 39.9042,
      lon: 116.4074,
    ),
    current: CurrentWeather(
      tempC: 25.5,
      conditionText: 'Sunny',
      humidity: 60,
      windKph: 10.5,
      uvIndex: 5,
    ),
    hourly: [],
    daily: [],
  );

  // Benchmark set
  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < iterations; i++) {
    cache.set('test_key_$i', testData);
  }

  stopwatch.stop();
  final avgTimeSet = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  Cache.set: ${avgTimeSet.toStringAsFixed(2)} μs/op ($iterations ops)',
  );

  // Benchmark get
  stopwatch.reset();
  stopwatch.start();

  for (int i = 0; i < iterations; i++) {
    cache.get('test_key_$i');
  }

  stopwatch.stop();
  final avgTimeGet = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  Cache.get: ${avgTimeGet.toStringAsFixed(2)} μs/op ($iterations ops)',
  );

  // Benchmark remove
  stopwatch.reset();
  stopwatch.start();

  for (int i = 0; i < iterations; i++) {
    cache.remove('test_key_$i');
  }

  stopwatch.stop();
  final avgTimeRemove = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  Cache.remove: ${avgTimeRemove.toStringAsFixed(2)} μs/op ($iterations ops)',
  );
  print('');
}

void benchmarkDataParsing() {
  print('--- Data Parsing Benchmark ---');

  const iterations = 10000;

  // Benchmark LocationInfo creation
  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < iterations; i++) {
    LocationInfo(
      name: 'Test City',
      region: 'Test Region',
      country: 'Test Country',
      lat: 39.9042,
      lon: 116.4074,
    );
  }

  stopwatch.stop();
  final avgTime1 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  LocationInfo creation: ${avgTime1.toStringAsFixed(2)} μs/op ($iterations ops)',
  );

  // Benchmark CurrentWeather creation
  stopwatch.reset();
  stopwatch.start();

  for (int i = 0; i < iterations; i++) {
    CurrentWeather(
      tempC: 25.5,
      conditionText: 'Sunny',
      humidity: 60,
      windKph: 10.5,
      uvIndex: 5,
    );
  }

  stopwatch.stop();
  final avgTime2 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  CurrentWeather creation: ${avgTime2.toStringAsFixed(2)} μs/op ($iterations ops)',
  );

  // Benchmark HourlyForecast creation
  stopwatch.reset();
  stopwatch.start();

  for (int i = 0; i < iterations; i++) {
    HourlyForecast(
      time: DateTime.now(),
      tempC: 26.0,
      conditionText: 'Cloudy',
      chanceOfRain: 30,
    );
  }

  stopwatch.stop();
  final avgTime3 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  HourlyForecast creation: ${avgTime3.toStringAsFixed(2)} μs/op ($iterations ops)',
  );

  // Benchmark DailyForecast creation
  stopwatch.reset();
  stopwatch.start();

  for (int i = 0; i < iterations; i++) {
    DailyForecast(
      date: DateTime.now(),
      maxTempC: 30.0,
      minTempC: 20.0,
      conditionText: 'Sunny',
      chanceOfRain: 10,
    );
  }

  stopwatch.stop();
  final avgTime4 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  DailyForecast creation: ${avgTime4.toStringAsFixed(2)} μs/op ($iterations ops)',
  );
  print('');
}

// Extension method for testing
extension WeatherServiceBenchmark on WeatherService {
  void _testInternalOperation() {
    final result = Result.success(42);
    result.fold((data) => data, (error) => 0);
  }
}
