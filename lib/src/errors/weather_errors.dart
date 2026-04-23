/// Weather error types
enum WeatherErrorType {
  /// Network connection error
  network,

  /// Data parsing error
  parsing,

  /// API key is invalid
  apiKey,

  /// Rate limit exceeded
  rateLimit,

  /// Location not found
  locationNotFound,

  /// Unknown error
  unknown,
}

/// Weather error representation
class WeatherError {
  WeatherError({
    required this.type,
    required this.message,
  });

  /// Create network error
  factory WeatherError.network(String message) {
    return WeatherError(type: WeatherErrorType.network, message: message);
  }

  /// Create parsing error
  factory WeatherError.parsing(String message) {
    return WeatherError(type: WeatherErrorType.parsing, message: message);
  }

  /// Create API key error
  factory WeatherError.apiKey(String message) {
    return WeatherError(type: WeatherErrorType.apiKey, message: message);
  }

  /// Create rate limit error
  factory WeatherError.rateLimit(String message) {
    return WeatherError(type: WeatherErrorType.rateLimit, message: message);
  }

  /// Create location not found error
  factory WeatherError.locationNotFound(String message) {
    return WeatherError(
        type: WeatherErrorType.locationNotFound, message: message);
  }

  /// Create unknown error
  factory WeatherError.unknown(String message) {
    return WeatherError(type: WeatherErrorType.unknown, message: message);
  }

  /// Type of error
  final WeatherErrorType type;

  /// Error message
  final String message;

  @override
  String toString() {
    return 'WeatherError: $type - $message';
  }
}

/// Result type for weather service operations
class Result<T> {
  Result._({
    required this.data,
    required this.error,
    required this.isSuccess,
  });

  /// Create a success result
  factory Result.success(T data) {
    return Result._(
      data: data,
      error: null,
      isSuccess: true,
    );
  }

  /// Create a failure result
  factory Result.failure(WeatherError error) {
    return Result._(
      data: null,
      error: error,
      isSuccess: false,
    );
  }

  /// Success data
  final T? data;

  /// Error information
  final WeatherError? error;

  /// Whether the operation was successful
  final bool isSuccess;

  /// Handle result with callbacks
  R fold<R>(
    R Function(T data) onSuccess,
    R Function(WeatherError error) onFailure,
  ) {
    return isSuccess ? onSuccess(data as T) : onFailure(error!);
  }

  /// Check if result is successful
  bool get isFailure => !isSuccess;
}
