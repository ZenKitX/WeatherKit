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
  for (int i = 0; i < 100; i++) {
    _testInternalOperation();
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

  final testData = Weather(
    city: City(
      name: 'Test City',
      region: 'Test Region',
      country: 'Test Country',
      latitude: 39.9042,
      longitude: 116.4074,
    ),
    currentTemperature: 25.5,
    condition: WeatherCondition.clear,
    humidity: 60,
    windSpeed: 10.5,
    currentTime: DateTime.now(),
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

  // Benchmark City creation
  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < iterations; i++) {
    City(
      name: 'Test City',
      region: 'Test Region',
      country: 'Test Country',
      latitude: 39.9042,
      longitude: 116.4074,
    );
  }

  stopwatch.stop();
  final avgTime1 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  City creation: ${avgTime1.toStringAsFixed(2)} μs/op ($iterations ops)',
  );

  // Benchmark HourlyForecast creation
  stopwatch.reset();
  stopwatch.start();

  for (int i = 0; i < iterations; i++) {
    HourlyForecast(
      time: DateTime.now(),
      temperature: 26.0,
      condition: WeatherCondition.cloudy,
      humidity: 60,
      windSpeed: 10.5,
    );
  }

  stopwatch.stop();
  final avgTime2 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  HourlyForecast creation: ${avgTime2.toStringAsFixed(2)} μs/op ($iterations ops)',
  );

  // Benchmark DailyForecast creation
  stopwatch.reset();
  stopwatch.start();

  for (int i = 0; i < iterations; i++) {
    DailyForecast(
      date: DateTime.now(),
      maxTemp: 30.0,
      minTemp: 20.0,
      condition: WeatherCondition.clear,
      sunrise: DateTime(2024, 4, 23, 6, 0),
      sunset: DateTime(2024, 4, 23, 18, 0),
      uvIndex: 8,
    );
  }

  stopwatch.stop();
  final avgTime3 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  DailyForecast creation: ${avgTime3.toStringAsFixed(2)} μs/op ($iterations ops)',
  );

  // Benchmark Weather creation
  stopwatch.reset();
  stopwatch.start();

  for (int i = 0; i < iterations; i++) {
    Weather(
      city: City(
        name: 'Beijing',
        region: 'Beijing',
        country: 'China',
        latitude: 39.9042,
        longitude: 116.4074,
      ),
      currentTemperature: 25.5,
      condition: WeatherCondition.clear,
      humidity: 60,
      windSpeed: 10.5,
      currentTime: DateTime.now(),
    );
  }

  stopwatch.stop();
  final avgTime4 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  Weather creation: ${avgTime4.toStringAsFixed(2)} μs/op ($iterations ops)',
  );
  print('');
}

// Internal operation for testing
void _testInternalOperation() {
  final result = Result.success(42);
  result.fold((data) => data, (error) => 0);
}
