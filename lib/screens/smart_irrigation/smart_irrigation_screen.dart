import 'package:flutter/material.dart';
import 'package:kisaan_mitra/models/weather_model.dart';
import 'package:kisaan_mitra/services/weather_service.dart';
import 'package:kisaan_mitra/services/iot_service.dart';
import 'package:kisaan_mitra/services/localization_service.dart';
import 'package:kisaan_mitra/widgets/smart_irrigation/weather_card.dart';
import 'package:kisaan_mitra/widgets/smart_irrigation/irrigation_recommendation_card.dart';
import 'package:kisaan_mitra/widgets/common/language_toggle.dart';
import 'package:kisaan_mitra/screens/smart_irrigation/iot_dashboard_screen.dart';
import 'package:kisaan_mitra/screens/smart_irrigation/irrigation_control_screen.dart';
import 'package:intl/intl.dart';

class SmartIrrigationScreen extends StatefulWidget {
  const SmartIrrigationScreen({Key? key}) : super(key: key);

  @override
  State<SmartIrrigationScreen> createState() => _SmartIrrigationScreenState();
}

class _SmartIrrigationScreenState extends State<SmartIrrigationScreen>
    with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  final IoTService _iotService = IoTService();
  final TextEditingController _cropController = TextEditingController();
  late TabController _tabController;

  WeatherModel? _currentWeather;
  List<WeatherModel>? _forecast;
  Map<String, dynamic>? _recommendations;
  bool _isLoading = true;
  bool _isLoadingRecommendations = false;
  bool _weatherAlertsEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadWeatherData();
  }

  @override
  void dispose() {
    _cropController.dispose();
    _tabController.dispose();
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
      final recommendations =
          await _weatherService.getIrrigationRecommendations(
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
        title: Text(loc.smartIrrigation),
        actions: const [LanguageToggle()],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
                icon: const Icon(Icons.cloud),
                text: loc.isHindi ? 'मौसम' : 'Weather'),
            Tab(
              icon: Stack(
                children: [
                  const Icon(Icons.sensors),
                  if (!_iotService.isPremium)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock,
                            size: 10, color: Colors.white),
                      ),
                    ),
                ],
              ),
              text: loc.isHindi ? 'आईओटी सेंसर' : 'IoT Sensors',
            ),
            Tab(
                icon: const Icon(Icons.water_drop),
                text: loc.isHindi ? 'नियंत्रण' : 'Control'),
            Tab(
                icon: const Icon(Icons.analytics),
                text: loc.isHindi ? 'विश्लेषण' : 'Analytics'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Weather & Recommendations
                _buildWeatherTab(),
                // Tab 2: IoT Dashboard (Premium)
                const IoTDashboardScreen(),
                // Tab 3: Irrigation Control
                const IrrigationControlScreen(),
                // Tab 4: Water Analytics
                _buildAnalyticsTab(),
              ],
            ),
    );
  }

  Widget _buildWeatherTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Weather
          Text(
            loc.currentWeather,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          WeatherCard(weather: _currentWeather!),
          const SizedBox(height: 24),

          // Weather Forecast
          Text(
            loc.fiveDayForecast,
            style: const TextStyle(
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
                        _getWeatherIcon(weather.condition),
                        color: _getWeatherIconColor(weather.condition),
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
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Irrigation Recommendations
          Text(
            loc.irrigationRecommendations,
            style: const TextStyle(
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
                  decoration: InputDecoration(
                    labelText: loc.enterCropType,
                    hintText: loc.cropTypeHintShort,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.grass),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed:
                    _isLoadingRecommendations ? null : _getRecommendations,
                child: _isLoadingRecommendations
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(loc.getAdvice),
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
          Text(
            loc.weatherAlerts,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text(loc.isHindi
                ? 'मौसम अलर्ट सक्षम करें'
                : 'Enable Weather Alerts'),
            subtitle: Text(
              loc.isHindi
                  ? 'अत्यधिक मौसम स्थितियों के बारे में सूचना प्राप्त करें'
                  : 'Get notified about extreme weather conditions',
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
                        ? (loc.isHindi
                            ? 'मौसम अलर्ट सक्षम'
                            : 'Weather alerts enabled')
                        : (loc.isHindi
                            ? 'मौसम अलर्ट अक्षम'
                            : 'Weather alerts disabled'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return Icons.wb_sunny;
      case 'clouds':
      case 'cloudy':
        return Icons.cloud;
      case 'rain':
      case 'drizzle':
        return Icons.umbrella;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
      case 'haze':
        return Icons.blur_on;
      default:
        return Icons.cloud;
    }
  }

  Color _getWeatherIconColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return Colors.orange;
      case 'clouds':
      case 'cloudy':
        return Colors.grey;
      case 'rain':
      case 'drizzle':
        return Colors.blue;
      case 'thunderstorm':
        return Colors.deepPurple;
      case 'snow':
        return Colors.lightBlue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAnalyticsTab() {
    final fields = _iotService.fields;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.isHindi ? 'पानी उपयोग विश्लेषण' : 'Water Usage Analytics',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Summary Cards
          Row(
            children: [
              Expanded(
                  child: _buildAnalyticCard(loc.isHindi ? 'आज' : 'Today',
                      '2,450 L', Icons.today, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildAnalyticCard(
                      loc.isHindi ? 'इस सप्ताह' : 'This Week',
                      '15.2K L',
                      Icons.date_range,
                      Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildAnalyticCard(
                      loc.isHindi ? 'अनुमानित लागत' : 'Est. Cost',
                      '₹762',
                      Icons.currency_rupee,
                      Colors.orange)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildAnalyticCard(loc.isHindi ? 'बचत' : 'Savings',
                      '18%', Icons.savings, Colors.purple)),
            ],
          ),
          const SizedBox(height: 24),

          // Usage by Field
          Text(
            loc.isHindi ? 'खेत अनुसार उपयोग' : 'Usage by Field',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...fields.map((field) {
            final usage = _iotService.getTotalWaterUsage(field.id, 7);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(field.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${field.currentCrop} • ${field.areaAcres} acres',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${(usage / 1000).toStringAsFixed(1)}K L',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('Last 7 days',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                        loc.isHindi
                            ? 'पानी बचाने के सुझाव'
                            : 'Water Saving Tips',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTip(loc.isHindi
                    ? 'सब्जियों के लिए ड्रिप सिंचाई से 40% तक पानी बचाएं'
                    : 'Use drip irrigation for vegetables to save up to 40% water'),
                _buildTip(loc.isHindi
                    ? 'वाष्पीकरण हानि कम करने के लिए सुबह जल्दी सिंचाई करें'
                    : 'Irrigate early morning to reduce evaporation losses'),
                _buildTip(loc.isHindi
                    ? 'मिट्टी नमी के आधार पर अनुकूलित करने के लिए ऑटो-मोड सक्षम करें'
                    : 'Enable auto-mode to optimize based on soil moisture'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style:
                  TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
          const SizedBox(width: 8),
          Expanded(
              child:
                  Text(text, style: TextStyle(color: Colors.green.shade700))),
        ],
      ),
    );
  }
}
