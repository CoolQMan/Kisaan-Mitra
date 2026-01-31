import 'dart:convert';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:kisaan_mitra/models/crop_analysis_model.dart';

class AIService {
  // Singleton pattern
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Crop.health API Configuration
  // TODO: Replace with your actual Crop.health API key from https://crop.kindwise.com
  final String _cropHealthApiKey =
      'MtdpQ2i33avSlWEPYvXo6yB04bcFZN0tRBU46HIYwSrNDHTaHp';
  static const String _cropHealthBaseUrl = 'https://crop.kindwise.com/api/v1';

  // Google Generative AI (kept for irrigation recommendations only)
  final String _geminiApiKey = 'AIzaSyA1Rxvtogo3o-qq7CFQcU8XzZ0Afq7H-0g';
  late final GenerativeModel _model;

  void init() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _geminiApiKey,
    );
  }

  /// Analyze crop health using Crop.health API
  ///
  /// [image] - The crop image file to analyze
  /// [cropType] - Optional crop type hint to improve accuracy
  /// [latitude] - Optional GPS latitude for region-specific detection
  /// [longitude] - Optional GPS longitude for region-specific detection
  Future<CropAnalysisModel> analyzeCropHealth(
    File image, {
    String? cropType,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Read and encode image as base64
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Build request body
      final Map<String, dynamic> requestBody = {
        'images': [base64Image],
        'similar_images': true,
      };

      // Add optional location data for better accuracy
      if (latitude != null && longitude != null) {
        requestBody['latitude'] = latitude;
        requestBody['longitude'] = longitude;
      }

      // Add datetime for seasonal context
      requestBody['datetime'] = DateTime.now().toIso8601String().split('T')[0];

      // Make API request
      final response = await http
          .post(
            Uri.parse('$_cropHealthBaseUrl/identification'),
            headers: {
              'Content-Type': 'application/json',
              'Api-Key': _cropHealthApiKey,
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        // Add crop type to response for model parsing
        responseData['crop_type'] = cropType ?? 'Crop';

        return CropAnalysisModel.fromCropHealthApi(responseData);
      } else if (response.statusCode == 401) {
        throw CropHealthApiException(
          'Invalid API key. Please check your Crop.health API configuration.',
          statusCode: 401,
        );
      } else if (response.statusCode == 429) {
        throw CropHealthApiException(
          'Service is busy. Please try again in a few moments.',
          statusCode: 429,
        );
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Unknown error occurred';
        throw CropHealthApiException(
          'Analysis failed: $errorMessage',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw CropHealthApiException(
        'No internet connection. Please check your network and try again.',
        isNetworkError: true,
      );
    } on http.ClientException {
      throw CropHealthApiException(
        'Network error. Please check your connection and try again.',
        isNetworkError: true,
      );
    } on FormatException {
      throw CropHealthApiException(
        'Invalid response from server. Please try again.',
      );
    } on CropHealthApiException {
      rethrow;
    } catch (e) {
      throw CropHealthApiException(
        'Could not analyze the image. Please try again with a clearer photo.',
      );
    }
  }

  /// Get irrigation recommendations using Google Gemini AI
  /// This function is unchanged from the original implementation
  Future<Map<String, dynamic>> getIrrigationRecommendations(
      String cropType, Map<String, dynamic> weatherData) async {
    try {
      // Initialize model if not already done
      if (!isInitialized) init();

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

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(
        content,
        generationConfig: GenerationConfig(
          temperature: 0.2,
          maxOutputTokens: 1024,
        ),
      );

      final text = response.text;
      if (text == null) {
        throw Exception('Empty response from AI for irrigation');
      }

      return _parseIrrigationResponse(text);
    } catch (e) {
      print('Exception during irrigation recommendation: $e');
      throw Exception('Error getting irrigation recommendations: $e');
    }
  }

  // Simple check to see if model is initialized
  bool get isInitialized {
    try {
      _model;
      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _parseIrrigationResponse(String text) {
    String waterAmount = 'Medium';
    String frequency = 'Every 2-3 days';
    String bestTime = 'Early Morning';
    String fertilizer = 'Balanced fertilizer';
    List<String> tips = [];

    // Split the text into lines for parsing
    final lines = text.split('\n');

    for (var line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.toLowerCase().startsWith('water amount:')) {
        waterAmount = trimmedLine.split(':').last.trim();
      } else if (trimmedLine.toLowerCase().startsWith('frequency:')) {
        frequency = trimmedLine.split(':').last.trim();
      } else if (trimmedLine.toLowerCase().startsWith('best time:')) {
        bestTime = trimmedLine.split(':').last.trim();
      } else if (trimmedLine.toLowerCase().startsWith('fertilizer:')) {
        fertilizer = trimmedLine.split(':').last.trim();
      } else if (trimmedLine.startsWith('-') || trimmedLine.startsWith('•')) {
        final tip = trimmedLine.substring(1).trim();
        if (tip.isNotEmpty) {
          tips.add(tip);
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
}

/// Exception thrown when Crop.health API request fails
class CropHealthApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetworkError;

  CropHealthApiException(
    this.message, {
    this.statusCode,
    this.isNetworkError = false,
  });

  @override
  String toString() => message;
}
