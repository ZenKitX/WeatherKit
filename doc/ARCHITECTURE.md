# WeatherKit 架构设计

本文档描述 WeatherKit 项目的架构设计原则和实现方案。

## 目录

1. [设计原则](#设计原则)
2. [目录结构](#目录结构)
3. [模块划分](#模块划分)
4. [数据流](#数据流)
5. [错误处理](#错误处理)
6. [缓存策略](#缓存策略)

## 设计原则

### 1. 简单性原则 (Simplicity)

WeatherKit 提供简单直观的 API，易于理解和使用。

**优势:**

- 快速上手
- 减少学习成本
- 降低出错概率

### 2. 单一职责原则 (Single Responsibility Principle)

每个类只负责一个明确的功能。

**示例:**

- `WeatherService` 只负责天气数据获取
- `WeatherCache` 只负责数据缓存
- `WeatherError` 只负责错误定义

### 3. 类型安全 (Type Safety)

使用 `Result<T>` 类型确保类型安全的错误处理。

**优势:**

- 编译时检查
- 避免空指针异常
- 明确的错误传播

### 4. 性能优先 (Performance First)

优化常见操作的性能。

**优势:**

- 快速的数据获取
- 高效的缓存机制
- 低内存占用

## 目录结构

```
lib/
├── weather_kit.dart              # 主导出文件
└── src/
    ├── cache/
    │   └── weather_cache.dart    # 缓存实现
    ├── errors/
    │   └── weather_errors.dart   # 错误类型定义
    ├── models/
    │   └── weather_model.dart    # 数据模型
    └── services/
        └── weather_service.dart  # 天气服务

test/                             # 测试目录
└── weather_test.dart

doc/                              # 文档目录
├── API.md
└── ARCHITECTURE.md

.github/workflows/                # CI/CD 配置
└── dart.yml
```

## 模块划分

### Models（数据模型）

定义数据结构。

#### WeatherData

**职责:**

- 表示完整的天气数据
- 包含位置、当前天气、预报信息

#### LocationInfo

**职责:**

- 表示地理位置信息
- 包含城市、地区、国家、坐标

#### CurrentWeather / HourlyForecast / DailyForecast

**职责:**

- 表示不同时间粒度的天气数据
- 提供温度、天气状况、湿度等信息

### Errors（错误处理）

定义错误类型和结果类型。

#### WeatherError

**职责:**

- 定义错误类型
- 包含错误消息

**错误类型:**

- `network`: 网络错误
- `parsing`: 数据解析错误
- `apiKey`: API Key 错误
- `rateLimit`: 速率限制
- `locationNotFound`: 位置未找到
- `unknown`: 未知错误

#### Result<T>

**职责:**

- 包装可能失败的操作
- 提供类型安全的错误处理

**优势:**

- 避免异常
- 明确错误传播
- 支持链式操作

### Services（服务层）

实现业务逻辑和 API 调用。

#### WeatherService

**职责:**

- 获取天气数据
- 管理缓存
- 处理错误

**主要方法:**

- `getWeatherByCity`: 根据城市获取天气
- `getWeatherByCoordinates`: 根据坐标获取天气

### Cache（缓存层）

实现数据缓存。

#### WeatherCache

**职责:**

- 缓存天气数据
- 管理过期时间
- 提供缓存 API

**实现:**

- 使用 SharedPreferences
- 支持 TTL（生存时间）
- 自动清理过期数据

## 数据流

### 获取天气数据流程

```
1. 调用 getWeatherByCity(city: 'Beijing')
   ↓
2. 检查缓存
   ↓
3a. 缓存命中 → 返回缓存数据
   ↓
3b. 缓存未命中 → 发起 API 请求
   ↓
4. 解析响应数据
   ↓
5. 存入缓存
   ↓
6. 返回 Result<WeatherData>
```

### 错误处理流程

```
1. 检测错误
   ↓
2. 创建对应的 WeatherError
   ↓
3. 返回 Result.failure(error)
   ↓
4. 调用者使用 fold 处理结果
```

## 错误处理

### Result<T> 模式

```dart
final result = await weatherService.getWeatherByCity(city: 'Beijing');

result.fold(
  (weather) {
    // 成功处理
    print('Temperature: ${weather.current.tempC}');
  },
  (error) {
    // 错误处理
    print('Error: ${error.message}');
  },
);
```

### 错误类型映射

| API 错误 | WeatherErrorType | 处理方式 |
|---------|-----------------|---------|
| 网络错误 | network | 提示检查网络 |
| 400 错误 | parsing | 提示参数错误 |
| 401 错误 | apiKey | 提示 API Key 无效 |
| 429 错误 | rateLimit | 提示稍后重试 |
| 4006 错误 | locationNotFound | 提示位置不存在 |
| 其他 | unknown | 提示未知错误 |

## 缓存策略

### 缓存键格式

```
weather_{city}_{hourly}_{daily}
```

示例:
- `weather_Beijing_false_false`
- `weather_Beijing_true_true`

### TTL 策略

| 数据类型 | TTL | 原因 |
|---------|-----|------|
| 当前天气 | 30 分钟 | 天气变化较快 |
| 小时预报 | 1 小时 | 预报有一定有效期 |
| 天预报 | 6 小时 | 长期预报有效期更长 |

### 缓存清理

- 启动时清理过期数据
- 每次写入时检查并清理
- 手动调用 `clear()` 清理所有缓存

## 性能优化

### 1. 懒加载

预报数据默认不获取，需要时才请求。

### 2. 并发请求

支持多个并发天气请求，避免阻塞。

### 3. 缓存优先

优先使用缓存数据，减少 API 调用。

## 扩展指南

### 添加新的天气数据源

1. 实现 `WeatherService` 接口
2. 适配数据模型
3. 注册到服务容器

### 添加新的缓存策略

1. 继承 `WeatherCache`
2. 实现自定义缓存逻辑
3. 替换默认缓存实例
