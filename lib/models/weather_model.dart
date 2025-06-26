class WeatherModel {
  final double temperature;
  final double humidity;
  final String condition;
  final String icon;
  final DateTime timestamp;
  final String location;
  final double rainfall;
  final double windSpeed;

  WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.condition,
    required this.icon,
    required this.timestamp,
    required this.location,
    required this.rainfall,
    required this.windSpeed,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
      condition: json['condition'],
      icon: json['icon'],
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'],
      rainfall: json['rainfall'].toDouble(),
      windSpeed: json['windSpeed'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'condition': condition,
      'icon': icon,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'rainfall': rainfall,
      'windSpeed': windSpeed,
    };
  }
}
