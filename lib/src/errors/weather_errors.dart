/// Weather error types
enum WeatherErrorType {
  /// Network connection error
  networkError,

  /// Request timeout
  timeout,

  /// API key is invalid
  apiKeyInvalid,

  /// City not found
  cityNotFound,

  /// Server error (5xx)
  serverError,

  /// Unknown error
  unknown,
}

/// Weather error representation
class WeatherError {
  /// Type of error
  final WeatherErrorType type;

  /// Error message
  final String message;

  /// HTTP status code (if applicable)
  final int? statusCode;

  /// Additional details
  final String? details;

  WeatherError({
    required this.type,
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    return 'WeatherError: $type - $message${statusCode != null ? ' (${statusCode})' : ''}';
  }
}

/// Result type for weather service operations
class Result<T> {
  /// Success data
  final T? data;

  /// Error information
  final WeatherError? error;

  /// Whether the operation was successful
  final bool isSuccess;

  /// Private constructor
  Result._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  /// Create a success result
  factory Result.success(T data) {
    return Result._(
      data: data,
      isSuccess: true,
    );
  }

  /// Create a failure result
  factory Result.failure(WeatherError error) {
    return Result._(
      error: error,
      isSuccess: false,
    );
  }

  /// Handle result with callbacks
  R fold<R>(
    R Function(T data) onSuccess,
    R Function(WeatherError error) onFailure,
  ) {
    return isSuccess ? onSuccess(data as T) : onFailure(error!);
  }

  /// Map data if successful
  Result<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      return Result.success(mapper(data as T));
    }
    return Result.failure(error!);
  }

  /// Check if result is successful
  bool get isFailure => !isSuccess;
}
