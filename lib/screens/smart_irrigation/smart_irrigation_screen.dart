import 'package:flutter/material.dart';
import 'package:kisaan_mitra/models/weather_model.dart';
import 'package:kisaan_mitra/services/weather_service.dart';
import 'package:kisaan_mitra/widgets/smart_irrigation/weather_card.dart';
import 'package:kisaan_mitra/widgets/smart_irrigation/irrigation_recommendation_card.dart';
import 'package:intl/intl.dart';

class SmartIrrigationScreen extends StatefulWidget {
  const SmartIrrigationScreen({Key? key}) : super(key: key);

  @override
  State<SmartIrrigationScreen> createState() => _SmartIrrigationScreenState();
}

class _SmartIrrigationScreenState extends State<SmartIrrigationScreen> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _cropController = TextEditingController();

  WeatherModel? _currentWeather;
  List<WeatherModel>? _forecast;
  Map<String, dynamic>? _recommendations;
  bool _isLoading = true;
  bool _isLoadingRecommendations = false;
  bool _weatherAlertsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  @override
  void dispose() {
    _cropController.dispose();
    super.dispose();
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final weather = await _weatherService.getCurrentWeather();
      final forecast = await _weatherService.getWeatherForecast();

      setState(() {
        _currentWeather = weather;
        _forecast = forecast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading weather data: $e')),
      );
    }
  }

  Future<void> _getRecommendations() async {
    if (_cropController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a crop type')),
      );
      return;
    }

    setState(() {
      _isLoadingRecommendations = true;
    });

    try {
      final recommendations = await _weatherService.getIrrigationRecommendations(
        _cropController.text,
      );

      setState(() {
        _recommendations = recommendations;
        _isLoadingRecommendations = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRecommendations = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting recommendations: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Irrigation'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Weather
            const Text(
              'Current Weather',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            WeatherCard(weather: _currentWeather!),
            const SizedBox(height: 24),

            // Weather Forecast
            const Text(
              '5-Day Forecast',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _forecast!.length,
                itemBuilder: (context, index) {
                  final weather = _forecast![index];
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(weather.timestamp),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Icon(
                          weather.condition.contains('Sunny')
                              ? Icons.wb_sunny
                              : Icons.cloud,
                          color: Colors.orange,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${weather.temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          weather.condition,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Irrigation Recommendations
            const Text(
              'Irrigation Recommendations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cropController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Crop Type',
                      hintText: 'e.g., Rice, Wheat, Cotton',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.grass),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoadingRecommendations
                      ? null
                      : _getRecommendations,
                  child: _isLoadingRecommendations
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Get Tips'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_recommendations != null)
              IrrigationRecommendationCard(
                recommendations: _recommendations!,
                cropType: _cropController.text,
              ),
            const SizedBox(height: 24),

            // Weather Alerts
            const Text(
              'Weather Alerts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Enable Weather Alerts'),
              subtitle: const Text(
                'Get notified about extreme weather conditions',
              ),
              value: _weatherAlertsEnabled,
              onChanged: (value) {
                setState(() {
                  _weatherAlertsEnabled = value;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Weather alerts enabled'
                          : 'Weather alerts disabled',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
