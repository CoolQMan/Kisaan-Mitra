import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:kisaan_mitra/models/crop_analysis_model.dart';

class AIService {
  // Singleton pattern
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Your API key - replace with your actual key
  final String _apiKey = 'MY_API_KEY';
  final String _baseUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent';

  Future<CropAnalysisModel> analyzeCropHealth(
      File image, String cropType) async {
    try {
      // Convert image to base64
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Create a simpler request body
      final body = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Analyze this $cropType plant image for diseases, pests, or nutrient deficiencies. Do NOT use any markdown syntax or formatting in your response. Provide clear answers without asterisks, backticks, or other special characters.\n\nProvide analysis in exactly this format:\n\nHealth Status: (use only Good, Moderate, or Poor)\n\nIssues:\n- Issue 1\n- Issue 2\n\nRecommendations:\n- Recommendation 1\n- Recommendation 2\n\nPreventive Measures:\n- Measure 1\n- Measure 2"
              },
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Image}
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature":
              0.2, // Lower temperature for more predictable formatting
          "maxOutputTokens": 1024
        }
      };

      // Make API request
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];

        // Parse the response
        return _parseResponseText(text, cropType);
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to analyze crop: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception during analysis: $e');
      throw Exception('Error analyzing crop: $e');
    }
  }

  Future<Map<String, dynamic>> getIrrigationRecommendations(
      String cropType, Map<String, dynamic> weatherData) async {
    try {
      // Format weather data for the prompt
      final temperature = weatherData['temperature'];
      final humidity = weatherData['humidity'];
      final rainfall = weatherData['rainfall'];
      final windSpeed = weatherData['windSpeed'];
      final condition = weatherData['condition'];
      final location = weatherData['location'];

      // Create forecast summary if available
      String forecastSummary = '';
      if (weatherData.containsKey('forecast') &&
          weatherData['forecast'] is List) {
        final forecast = weatherData['forecast'] as List;
        forecastSummary = '\nWeather Forecast for next few days:\n';
        for (var day in forecast) {
          forecastSummary +=
              '- ${day['date']}: ${day['condition']}, ${day['temperature']}°C, Rainfall: ${day['rainfall']}mm\n';
        }
      }

      // Create the prompt for Gemini
      final prompt = '''
You are an agricultural expert AI. Provide detailed irrigation recommendations for $cropType based on the following weather conditions:

Current Weather:
- Temperature: ${temperature}°C
- Humidity: ${humidity}%
- Rainfall: ${rainfall}mm
- Wind Speed: ${windSpeed}m/s
- Weather Condition: $condition
- Location: $location
$forecastSummary

Provide irrigation recommendations in exactly this format:

Water Amount: (High, Medium, Low, or None)

Frequency: (e.g., Daily, Every 2-3 days, etc.)

Best Time: (e.g., Early Morning, Evening, etc.)

Fertilizer: (Recommend appropriate fertilizer)

Tips:
- Tip 1
- Tip 2
- Tip 3
''';

      // Create request body
      final body = {
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ],
        "generationConfig": {"temperature": 0.2, "maxOutputTokens": 1024}
      };

      // Make API request
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];

        // Parse the response
        return _parseIrrigationResponse(text);
      } else {
        print('Error response: ${response.body}');
        throw Exception(
            'Failed to get irrigation recommendations: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception during irrigation recommendation: $e');
      throw Exception('Error getting irrigation recommendations: $e');
    }
  }

  Map<String, dynamic> _parseIrrigationResponse(String text) {
    String waterAmount = 'Medium';
    String frequency = 'Every 2-3 days';
    String bestTime = 'Early Morning';
    String fertilizer = 'Balanced fertilizer';
    List<String> tips = [];

    // Split the text into sections
    final sections = text.split('\n\n');

    for (var section in sections) {
      if (section.toLowerCase().contains('water amount')) {
        final parts = section.split(':');
        if (parts.length > 1) {
          waterAmount = parts[1].trim();
        }
      } else if (section.toLowerCase().contains('frequency')) {
        final parts = section.split(':');
        if (parts.length > 1) {
          frequency = parts[1].trim();
        }
      } else if (section.toLowerCase().contains('best time')) {
        final parts = section.split(':');
        if (parts.length > 1) {
          bestTime = parts[1].trim();
        }
      } else if (section.toLowerCase().contains('fertilizer')) {
        final parts = section.split(':');
        if (parts.length > 1) {
          fertilizer = parts[1].trim();
        }
      } else if (section.toLowerCase().contains('tips')) {
        final lines = section.split('\n');
        for (var i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.startsWith('-') || line.startsWith('•')) {
            tips.add(line.substring(1).trim());
          }
        }
      }
    }

    // If parsing failed, provide default tips
    if (tips.isEmpty) {
      tips = [
        'Adjust watering based on soil moisture',
        'Avoid watering leaves to prevent fungal diseases',
        'Apply mulch to retain soil moisture',
      ];
    }

    return {
      'waterAmount': waterAmount,
      'frequency': frequency,
      'bestTime': bestTime,
      'fertilizer': fertilizer,
      'tips': tips,
    };
  }

  CropAnalysisModel _parseResponseText(String text, String cropType) {
    String healthStatus = 'Unknown';
    List<String> issues = [];
    List<String> recommendations = [];
    List<String> preventiveMeasures = [];

    // Split the text into sections
    final sections = text.split('\n\n');

    for (var section in sections) {
      if (section.toLowerCase().contains('health status')) {
        final parts = section.split(':');
        if (parts.length > 1) {
          healthStatus = parts[1].trim();
        }
      } else if (section.toLowerCase().contains('issues')) {
        final lines = section.split('\n');
        for (var i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.startsWith('-') || line.startsWith('•')) {
            issues.add(line.substring(1).trim());
          }
        }
      } else if (section.toLowerCase().contains('recommendations')) {
        final lines = section.split('\n');
        for (var i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.startsWith('-') || line.startsWith('•')) {
            recommendations.add(line.substring(1).trim());
          }
        }
      } else if (section.toLowerCase().contains('preventive measures')) {
        final lines = section.split('\n');
        for (var i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.startsWith('-') || line.startsWith('•')) {
            preventiveMeasures.add(line.substring(1).trim());
          }
        }
      }
    }

    // If parsing failed, return mock data for now
    if (issues.isEmpty) {
      return _getMockData(cropType);
    }

    return CropAnalysisModel(
      cropType: cropType,
      healthStatus: healthStatus,
      issues: issues,
      recommendations: recommendations,
      preventiveMeasures: preventiveMeasures,
    );
  }

  // Fallback mock data in case parsing fails
  CropAnalysisModel _getMockData(String cropType) {
    switch (cropType.toLowerCase()) {
      case 'rice':
        return CropAnalysisModel(
          cropType: 'Rice',
          healthStatus: 'Poor',
          issues: [
            'Bacterial Leaf Blight',
            'Nitrogen Deficiency',
          ],
          recommendations: [
            'Apply copper-based fungicide',
            'Increase nitrogen fertilizer application',
          ],
          preventiveMeasures: [
            'Use disease-resistant varieties',
            'Maintain proper spacing between plants',
          ],
        );
      default:
        return CropAnalysisModel(
          cropType: cropType,
          healthStatus: 'Moderate',
          issues: [
            'Pest Infestation',
            'Mild Water Stress',
          ],
          recommendations: [
            'Apply appropriate pesticide',
            'Increase irrigation frequency',
          ],
          preventiveMeasures: [
            'Regular monitoring for early detection',
            'Maintain consistent watering schedule',
          ],
        );
    }
  }
}
