import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kisaan_mitra/models/weather_model.dart';
import 'package:kisaan_mitra/services/location_service.dart';

import 'ai_service.dart';

class WeatherService {
  // Singleton pattern
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();
  final AIService _aiService = AIService();
  final LocationService _locationService = LocationService();

  // Replace with your actual OpenWeather API key
  final String _apiKey = 'a0743a22a526ba4f6960c4015371faaa';

  // Base URL for OpenWeather API 2.5
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Reverse geocode using BigDataCloud (fast, free, no API key needed)
  Future<String> _reverseGeocode(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=en',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String city = data['city'] ?? data['locality'] ?? '';
        String principalSubdivision =
            data['principalSubdivision'] ?? ''; // State

        if (city.isNotEmpty && principalSubdivision.isNotEmpty) {
          return '$city, $principalSubdivision';
        } else if (city.isNotEmpty) {
          return city;
        } else if (principalSubdivision.isNotEmpty) {
          return principalSubdivision;
        }
      }
    } catch (e) {
      print('Reverse geocoding failed: $e');
    }
    return 'Unknown Location';
  }

  // Get current weather using API 2.5
  Future<WeatherModel> getCurrentWeather() async {
    final locationData = await _locationService.getCurrentLocation();

    final lat = locationData.latitude!;
    final lon = locationData.longitude!;

    // Run both API calls in parallel for faster loading
    final results = await Future.wait([
      _reverseGeocode(lat, lon),
      http.get(Uri.parse(
          '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric')),
    ]);

    final locationName = results[0] as String;
    final response = results[1] as http.Response;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return WeatherModel(
        temperature: data['main']['temp'].toDouble(),
        humidity: data['main']['humidity'].toDouble(),
        condition: data['weather'][0]['main'],
        icon: data['weather'][0]['icon'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(data['dt'] * 1000),
        location: locationName, // Use our reverse geocoded name
        rainfall: data['rain']?['1h'] ?? 0.0,
        windSpeed: data['wind']['speed'].toDouble(),
      );
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }

  // Get weather forecast for next 5 days using API 2.5
  Future<List<WeatherModel>> getWeatherForecast() async {
    final locationData = await _locationService.getCurrentLocation();

    final lat = locationData.latitude;
    final lon = locationData.longitude;

    final response = await http.get(
      Uri.parse(
          '$_baseUrl/forecast?lat=$lat&lon=$lon&units=metric&appid=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> forecastList = data['list'];
      final String cityName = data['city']['name'];
      final String countryCode = data['city']['country'];
      final String location = '$cityName, $countryCode';

      // The API returns forecast in 3-hour steps, so we need to filter to get daily forecasts
      // We'll take the forecast at noon (closest to 12:00) for each day

      Map<String, WeatherModel> dailyForecasts = {};

      for (var forecast in forecastList) {
        // Convert timestamp to DateTime
        DateTime forecastTime =
            DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);

        // Create a date string to use as a key (without time)
        String dateKey =
            '${forecastTime.year}-${forecastTime.month}-${forecastTime.day}';

        // Skip today's forecast as we already have current weather
        if (forecastTime.day == DateTime.now().day &&
            forecastTime.month == DateTime.now().month &&
            forecastTime.year == DateTime.now().year) {
          continue;
        }

        // If we haven't stored a forecast for this day yet, or if this forecast is closer to noon
        if (!dailyForecasts.containsKey(dateKey) ||
            (forecastTime.hour - 12).abs() <
                (dailyForecasts[dateKey]!.timestamp.hour - 12).abs()) {
          dailyForecasts[dateKey] = WeatherModel(
            temperature: forecast['main']['temp'].toDouble(),
            humidity: forecast['main']['humidity'].toDouble(),
            condition: forecast['weather'][0]['main'],
            icon: forecast['weather'][0]['icon'],
            timestamp: forecastTime,
            location: location,
            rainfall: forecast['rain']?['3h'] ?? 0.0,
            windSpeed: forecast['wind']['speed'].toDouble(),
          );
        }
      }

      // Convert map to list and sort by date
      List<WeatherModel> result = dailyForecasts.values.toList();
      result.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Limit to 5 days
      return result.take(5).toList();
    } else {
      throw Exception('Failed to load forecast data: ${response.statusCode}');
    }
  }

  // Get irrigation recommendations based on weather and crop type
  Future<Map<String, dynamic>> getIrrigationRecommendations(
      String cropType) async {
    try {
      // Get current weather and forecast data
      final weather = await getCurrentWeather();
      final forecast = await getWeatherForecast();

      // Format forecast data for Gemini
      List<Map<String, dynamic>> forecastData = [];
      for (var day in forecast) {
        forecastData.add({
          'date': '${day.timestamp.day}/${day.timestamp.month}',
          'temperature': day.temperature,
          'condition': day.condition,
          'rainfall': day.rainfall,
          'humidity': day.humidity,
          'windSpeed': day.windSpeed,
        });
      }

      // Prepare weather data for Gemini
      final weatherData = {
        'temperature': weather.temperature,
        'humidity': weather.humidity,
        'rainfall': weather.rainfall,
        'windSpeed': weather.windSpeed,
        'condition': weather.condition,
        'location': weather.location,
        'forecast': forecastData,
      };

      // Get AI-powered irrigation recommendations
      return await _aiService.getIrrigationRecommendations(
          cropType, weatherData);
    } catch (e) {
      print('Error getting irrigation recommendations: $e');

      // Fallback to basic recommendations if AI service fails
      bool isHot = false;
      bool isCold = false;
      bool isRainy = false;
      bool isDry = false;

      try {
        final weather = await getCurrentWeather();
        isHot = weather.temperature > 30;
        isCold = weather.temperature < 15;
        isRainy = weather.rainfall > 0;
        isDry = weather.humidity < 40;
      } catch (_) {
        // If weather data also fails, use default values
      }

      // Base recommendations on crop type and basic weather conditions
      switch (cropType.toLowerCase()) {
        case 'rice':
          return {
            'waterAmount': isRainy ? 'Low' : (isHot ? 'High' : 'Medium'),
            'frequency': isRainy ? 'Every 2 days' : 'Daily',
            'bestTime': isHot ? 'Early Morning and Evening' : 'Morning',
            'fertilizer': 'Nitrogen-rich fertilizer',
            'tips': [
              'Maintain standing water of 2-5 cm',
              'Drain field 7-10 days before harvest',
              'Monitor for pests regularly',
            ],
          };
        case 'wheat':
          return {
            'waterAmount': isRainy ? 'None' : (isDry ? 'Medium' : 'Low'),
            'frequency': isRainy
                ? 'Skip watering'
                : (isHot ? 'Every 2-3 days' : 'Every 4-5 days'),
            'bestTime': 'Early Morning',
            'fertilizer': 'Balanced NPK fertilizer',
            'tips': [
              'Avoid overwatering to prevent disease',
              'Ensure proper drainage',
              'Apply fertilizer after irrigation',
            ],
          };
        default:
          return {
            'waterAmount': isRainy ? 'Low' : (isHot ? 'High' : 'Medium'),
            'frequency': isRainy
                ? 'Skip 1-2 days'
                : (isHot ? 'Daily' : 'Every 2-3 days'),
            'bestTime': isHot ? 'Early Morning or Late Evening' : 'Morning',
            'fertilizer': 'Balanced fertilizer',
            'tips': [
              'Adjust watering based on soil moisture',
              'Avoid watering leaves to prevent fungal diseases',
              'Apply mulch to retain soil moisture',
            ],
          };
      }
    }
  }
}
