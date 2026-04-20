# WeatherKit API 参考文档

本文档提供 WeatherKit 的完整 API 参考。

## 目录

- [WeatherService](#weatherservice)
- [WeatherCache](#weathercache)
- [WeatherError](#weathererror)
- [Result](#result)
- [WeatherData](#weatherdata)
- [LocationInfo](#locationinfo)
- [CurrentWeather](#currentweather)
- [HourlyForecast](#hourlyforecast)
- [DailyForecast](#dailyforecast)

---

## WeatherService

天气服务类，用于获取天气数据。

### 构造函数

```dart
WeatherService({
  required String apiKey,
  WeatherCache? cache,
  String baseUrl = 'https://api.weatherapi.com/v1',
})
```

**参数:**
- `apiKey`: WeatherAPI.com API Key（必需）
- `cache`: 缓存实例（可选）
- `baseUrl`: API 基础 URL（可选，默认为 WeatherAPI.com）

### 方法

#### getWeatherByCity

根据城市名称获取天气数据。

```dart
Future<Result<WeatherData>> getWeatherByCity({
  required String city,
  bool includeHourly = false,
  bool includeDaily = false,
  int hourlyCount = 24,
  int dailyCount = 7,
})
```

**参数:**
- `city`: 城市名称（必需）
- `includeHourly`: 是否包含小时预报（可选，默认 false）
- `includeDaily`: 是否包含天预报（可选，默认 false）
- `hourlyCount`: 小时预报数量（可选，默认 24）
- `dailyCount`: 天预报数量（可选，默认 7）

**返回:** `Future<Result<WeatherData>>`

#### getWeatherByCoordinates

根据经纬度获取天气数据。

```dart
Future<Result<WeatherData>> getWeatherByCoordinates({
  required double lat,
  required double lon,
  bool includeHourly = false,
  bool includeDaily = false,
  int hourlyCount = 24,
  int dailyCount = 7,
})
```

**参数:**
- `lat`: 纬度（必需）
- `lon`: 经度（必需）
- `includeHourly`: 是否包含小时预报（可选，默认 false）
- `includeDaily`: 是否包含天预报（可选，默认 false）
- `hourlyCount`: 小时预报数量（可选，默认 24）
- `dailyCount`: 天预报数量（可选，默认 7）

**返回:** `Future<Result<WeatherData>>`

---

## WeatherCache

天气数据缓存类，使用 SharedPreferences 实现。

### 构造函数

```dart
WeatherCache()
```

### 方法

#### get

从缓存获取天气数据。

```dart
Future<WeatherData?> get(String key)
```

**参数:**
- `key`: 缓存键

**返回:** `Future<WeatherData?>`

#### set

将天气数据存入缓存。

```dart
Future<void> set(String key, WeatherData data, {Duration? ttl})
```

**参数:**
- `key`: 缓存键
- `data`: 天气数据
- `ttl`: 过期时间（可选）

#### remove

从缓存移除数据。

```dart
Future<void> remove(String key)
```

**参数:**
- `key`: 缓存键

#### clear

清空所有缓存。

```dart
Future<void> clear()
```

---

## WeatherError

天气错误类。

### 构造函数

```dart
WeatherError({
  required WeatherErrorType type,
  required String message,
})
```

### 静态工厂方法

```dart
WeatherError.network(String message)
WeatherError.parsing(String message)
WeatherError.apiKey(String message)
WeatherError.rateLimit(String message)
WeatherError.locationNotFound(String message)
WeatherError.unknown(String message)
```

### 属性

```dart
WeatherErrorType type  // 错误类型
String message         // 错误消息
```

---

## Result

结果类型，用于包装可能失败的操作。

### 静态工厂方法

```dart
Result.success(T data)
Result.failure(WeatherError error)
```

### 属性

```dart
bool isSuccess      // 是否成功
bool isFailure      // 是否失败
T? data            // 成功数据
WeatherError? error // 错误信息
```

### 方法

#### fold

根据成功或失败状态执行不同的回调。

```dart
R fold<R>(R Function(T data) onSuccess, R Function(WeatherError error) onFailure)
```

---

## WeatherData

天气数据模型。

### 构造函数

```dart
WeatherData({
  required LocationInfo location,
  required CurrentWeather current,
  List<HourlyForecast> hourly = const [],
  List<DailyForecast> daily = const [],
})
```

### 属性

```dart
LocationInfo location          // 位置信息
CurrentWeather current         // 当前天气
List<HourlyForecast> hourly    // 小时预报
List<DailyForecast> daily      // 天预报
```

---

## LocationInfo

位置信息模型。

### 构造函数

```dart
LocationInfo({
  required String name,
  required String region,
  required String country,
  required double lat,
  required double lon,
})
```

### 属性

```dart
String name     // 城市名称
String region   // 地区/州
String country  // 国家
double lat      // 纬度
double lon      // 经度
```

---

## CurrentWeather

当前天气模型。

### 构造函数

```dart
CurrentWeather({
  required double tempC,
  required String conditionText,
  required int humidity,
  required double windKph,
  required int uvIndex,
})
```

### 属性

```dart
double tempC         // 温度（摄氏度）
String conditionText // 天气状况文本
int humidity        // 湿度（%）
double windKph      // 风速（公里/小时）
int uvIndex         // 紫外线指数
```

---

## HourlyForecast

小时预报模型。

### 构造函数

```dart
HourlyForecast({
  required DateTime time,
  required double tempC,
  required String conditionText,
  required int chanceOfRain,
})
```

### 属性

```dart
DateTime time        // 时间
double tempC         // 温度（摄氏度）
String conditionText // 天气状况文本
int chanceOfRain     // 降雨概率（%）
```

---

## DailyForecast

天预报模型。

### 构造函数

```dart
DailyForecast({
  required DateTime date,
  required double maxTempC,
  required double minTempC,
  required String conditionText,
  required int chanceOfRain,
})
```

### 属性

```dart
DateTime date        // 日期
double maxTempC      // 最高温度（摄氏度）
double minTempC      // 最低温度（摄氏度）
String conditionText // 天气状况文本
int chanceOfRain     // 降雨概率（%）
```
