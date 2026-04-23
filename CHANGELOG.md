# Changelog | 更新日志

## Table of Contents | 目录

- [English](#english)
- [中文](#中文)

---

## English

### [0.1.0] - 2026-04-23

#### Added

- Initial release of WeatherKit package
- **Core Architecture**
  - Provider abstraction pattern for multiple weather data sources
  - Independent domain models (Weather, City, Forecast)
  - Result type for error handling
  - Transparent caching with TTL, LRU eviction, and request deduplication

- **Weather Providers**
  - WeatherApiProvider (WeatherAPI.com)
  - QWeatherProvider (和风天气)
  - Provider configuration and switching

- **Security**
  - Secure API key storage
  - Multiple key sources (dart-define, .env, hardcoded)
  - API key validation

- **Ecosystem Integration**
  - LocationKit integration for current location queries
  - SolarTermKit integration for solar term information
  - Poetry recommendations based on weather and solar terms
  - One-click location + weather + poetry queries

- **Caching**
  - Configurable cache policies (TTL, max entries, stale-while-revalidate)
  - Cache statistics and performance monitoring
  - Persistent storage with SharedPreferences

- **Examples**
  - Basic weather queries
  - Provider switching examples
  - Secure key loading
  - Ecosystem integration demo

#### Documentation

- Comprehensive README with architecture overview
- API documentation for all public interfaces
- QWeather vs WeatherAPI comparison guide
- Ecosystem integration guide

#### Tested On

- Flutter 3.24.0+
- Dart 3.5.0+
- iOS and Android platforms

---

## 中文

### [0.1.0] - 2026-04-23

#### 新增

- WeatherKit 包首次发布
- **核心架构**
  - 多数据源的 Provider 抽象模式
  - 独立的域模型（Weather、City、Forecast）
  - Result 类型错误处理
  - 透明缓存，支持 TTL、LRU 淘汰和请求去重

- **天气提供者**
  - WeatherApiProvider (WeatherAPI.com)
  - QWeatherProvider (和风天气)
  - Provider 配置和切换

- **安全性**
  - 安全的 API 密钥存储
  - 多种密钥来源（dart-define、.env、硬编码）
  - API 密钥验证

- **生态系统集成**
  - LocationKit 集成用于当前位置查询
  - SolarTermKit 集成用于节气信息
  - 基于天气和节气的诗词推荐
  - 一键位置 + 天气 + 诗词查询

- **缓存**
  - 可配置的缓存策略（TTL、最大条目数、stale-while-revalidate）
  - 缓存统计和性能监控
  - 使用 SharedPreferences 持久化存储

- **示例**
  - 基础天气查询
  - Provider 切换示例
  - 安全密钥加载
  - 生态系统集成演示

#### 文档

- 包含架构概览的完整 README
- 所有公共接口的 API 文档
- QWeather vs WeatherAPI 对比指南
- 生态系统集成指南

#### 测试环境

- Flutter 3.24.0+
- Dart 3.5.0+
- iOS 和 Android 平台
