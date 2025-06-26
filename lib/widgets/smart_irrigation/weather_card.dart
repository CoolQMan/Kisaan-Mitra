import 'package:flutter/material.dart';
import 'package:kisaan_mitra/models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherCard({
    Key? key,
    required this.weather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  weather.condition.contains('Sunny')
                      ? Icons.wb_sunny
                      : weather.condition.contains('Cloud')
                      ? Icons.cloud
                      : weather.condition.contains('Rain')
                      ? Icons.water_drop
                      : Icons.air,
                  color: _getWeatherIconColor(weather.condition),
                  size: 48,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        weather.condition,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        weather.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(
                  context,
                  Icons.water_drop,
                  '${weather.humidity.toStringAsFixed(0)}%',
                  'Humidity',
                ),
                _buildWeatherDetail(
                  context,
                  Icons.grain,
                  '${weather.rainfall.toStringAsFixed(1)} mm',
                  'Rainfall',
                ),
                _buildWeatherDetail(
                  context,
                  Icons.air,
                  '${weather.windSpeed.toStringAsFixed(1)} km/h',
                  'Wind',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(
      BuildContext context,
      IconData icon,
      String value,
      String label,
      ) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getWeatherIconColor(String condition) {
    if (condition.contains('Sunny')) {
      return Colors.orange;
    } else if (condition.contains('Cloud')) {
      return Colors.grey;
    } else if (condition.contains('Rain')) {
      return Colors.blue;
    } else {
      return Colors.blueGrey;
    }
  }
}
