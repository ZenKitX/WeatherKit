import 'package:flutter/material.dart';
import 'package:weather_kit/weather_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherKit Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WeatherExamplePage(),
    );
  }
}

class WeatherExamplePage extends StatefulWidget {
  const WeatherExamplePage({super.key});

  @override
  State<WeatherExamplePage> createState() => _WeatherExamplePageState();
}

class _WeatherExamplePageState extends State<WeatherExamplePage> {
  final TextEditingController _cityController = TextEditingController(text: 'Beijing');
  late final WeatherService _weatherService;
  Result<Weather>? _result;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _weatherService = WeatherService.withWeatherAPI(
      apiKey: 'YOUR_API_KEY_HERE', // Replace with your actual API key
      cache: WeatherCache(),
    );
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    final result = await _weatherService.getWeatherByCity(
      city: _cityController.text,
      includeHourly: true,
      includeDaily: true,
    );

    setState(() {
      _result = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WeatherKit Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City Name',
                hintText: 'Enter city name (e.g., Beijing, Shanghai)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchWeather,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Get Weather'),
            ),
            const SizedBox(height: 24),
            if (_result != null) _buildResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    return _result!.fold(
      (weather) => _buildWeatherCard(weather),
      (error) => _buildErrorCard(error),
    );
  }

  Widget _buildWeatherCard(Weather weather) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              weather.city.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '${weather.city.region}, ${weather.city.country}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const Divider(height: 32),
            Row(
              children: [
                Icon(
                  _getWeatherIcon(weather.condition.name),
                  size: 48,
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                Text(
                  '${weather.currentTemperature.toStringAsFixed(1)}°C',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ],
            ),
            Text(
              weather.condition.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Humidity', '${weather.humidity}%'),
            _buildDetailRow('Wind Speed', '${weather.windSpeed.toStringAsFixed(1)} km/h'),
            const Divider(height: 32),
            Text(
              'Hourly Forecast',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: weather.hourlyForecast.take(8).length,
                itemBuilder: (context, index) {
                  final hourly = weather.hourlyForecast[index];
                  return _buildHourlyItem(hourly);
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '7-Day Forecast',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...weather.dailyForecast.map((daily) => _buildDailyItem(daily)),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyItem(HourlyForecast hourly) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              '${hourly.time.hour}:00',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Icon(
              _getWeatherIcon(hourly.condition.name),
              size: 24,
              color: Colors.blue,
            ),
            Text(
              '${hourly.temperature.toStringAsFixed(0)}°C',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyItem(DailyForecast daily) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${daily.date.day}/${daily.date.month}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Icon(
              _getWeatherIcon(daily.condition.name),
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                daily.condition.name,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              '${daily.maxTemp.toStringAsFixed(0)}° / ${daily.minTemp.toStringAsFixed(0)}°',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(WeatherError error) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Error: ${_getErrorTypeName(error.type)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.red[700],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              error.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String conditionName) {
    if (conditionName == WeatherCondition.clear.name) {
      return Icons.wb_sunny;
    } else if (conditionName == WeatherCondition.partlyCloudy.name || conditionName == WeatherCondition.cloudy.name) {
      return Icons.cloud;
    } else if (conditionName == WeatherCondition.rain.name) {
      return Icons.water_drop;
    } else if (conditionName == WeatherCondition.snow.name) {
      return Icons.ac_unit;
    } else if (conditionName == WeatherCondition.thunderstorm.name) {
      return Icons.flash_on;
    } else if (conditionName == WeatherCondition.fog.name || conditionName == WeatherCondition.mist.name) {
      return Icons.cloud_queue;
    }
    return Icons.cloud;
  }

  String _getErrorTypeName(WeatherErrorType type) {
    switch (type) {
      case WeatherErrorType.network:
        return 'Network Error';
      case WeatherErrorType.parsing:
        return 'Parsing Error';
      case WeatherErrorType.apiKey:
        return 'API Key Error';
      case WeatherErrorType.rateLimit:
        return 'Rate Limit';
      case WeatherErrorType.locationNotFound:
        return 'Location Not Found';
      case WeatherErrorType.unknown:
        return 'Unknown Error';
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}
