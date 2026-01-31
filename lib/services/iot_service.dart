// IoT Service for Smart Irrigation
// Handles sensor data, irrigation control, and premium tier

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kisaan_mitra/models/iot_sensor_models.dart';

class IoTService {
  // Singleton pattern
  static final IoTService _instance = IoTService._internal();
  factory IoTService() => _instance;
  IoTService._internal();

  // Premium tier status (mock - would come from backend)
  bool _isPremium = false;
  bool get isPremium => _isPremium;

  void setPremiumStatus(bool value) => _isPremium = value;

  // Current irrigation state
  IrrigationMode _currentMode = IrrigationMode.off;
  IrrigationMode get currentMode => _currentMode;

  AutoIrrigationSettings _autoSettings = const AutoIrrigationSettings();
  AutoIrrigationSettings get autoSettings => _autoSettings;

  ManualIrrigationCommand? _activeManualCommand;
  ManualIrrigationCommand? get activeManualCommand => _activeManualCommand;

  // ============================================================================
  // MOCK DATA - Fields
  // ============================================================================

  final List<FieldModel> _fields = [
    FieldModel(
      id: 'field_1',
      name: 'Main Paddy Field',
      areaAcres: 2.5,
      currentCrop: 'Rice',
      soilType: 'Clay Loam',
      sensorIds: ['sensor_1', 'sensor_2'],
      lastIrrigated: DateTime.now().subtract(const Duration(hours: 8)),
      lastWaterUsedLiters: 2500,
    ),
    FieldModel(
      id: 'field_2',
      name: 'Wheat Plot',
      areaAcres: 1.8,
      currentCrop: 'Wheat',
      soilType: 'Sandy Loam',
      sensorIds: ['sensor_3'],
      lastIrrigated: DateTime.now().subtract(const Duration(days: 2)),
      lastWaterUsedLiters: 1200,
    ),
    FieldModel(
      id: 'field_3',
      name: 'Vegetable Garden',
      areaAcres: 0.5,
      currentCrop: 'Mixed Vegetables',
      soilType: 'Loam',
      sensorIds: ['sensor_4'],
      lastIrrigated: DateTime.now().subtract(const Duration(hours: 4)),
      lastWaterUsedLiters: 400,
    ),
  ];

  List<FieldModel> get fields => _fields;
  FieldModel? getFieldById(String id) => _fields.firstWhere((f) => f.id == id);

  // ============================================================================
  // MOCK DATA - Sensors
  // ============================================================================

  final List<SensorDevice> _sensors = [
    SensorDevice(
      id: 'sensor_1',
      name: 'Moisture Sensor A',
      type: 'moisture',
      isOnline: true,
      batteryPercent: 78,
      lastSync: DateTime.now().subtract(const Duration(minutes: 5)),
      fieldId: 'field_1',
    ),
    SensorDevice(
      id: 'sensor_2',
      name: 'NPK Sensor A',
      type: 'nutrient',
      isOnline: true,
      batteryPercent: 92,
      lastSync: DateTime.now().subtract(const Duration(minutes: 3)),
      fieldId: 'field_1',
    ),
    SensorDevice(
      id: 'sensor_3',
      name: 'Moisture Sensor B',
      type: 'moisture',
      isOnline: true,
      batteryPercent: 45,
      lastSync: DateTime.now().subtract(const Duration(minutes: 10)),
      fieldId: 'field_2',
    ),
    SensorDevice(
      id: 'sensor_4',
      name: 'Moisture Sensor C',
      type: 'moisture',
      isOnline: false,
      batteryPercent: 12,
      lastSync: DateTime.now().subtract(const Duration(hours: 2)),
      fieldId: 'field_3',
    ),
  ];

  List<SensorDevice> get sensors => _sensors;
  List<SensorDevice> getSensorsForField(String fieldId) =>
      _sensors.where((s) => s.fieldId == fieldId).toList();

  // ============================================================================
  // MOCK SENSOR READINGS (Simulated real-time data)
  // ============================================================================

  final Random _random = Random();

  /// Get current soil moisture reading for a field
  SoilMoistureReading getSoilMoisture(String fieldId) {
    // Simulate realistic moisture based on field
    double baseMoisture;
    switch (fieldId) {
      case 'field_1': // Rice needs more water
        baseMoisture = 55 + _random.nextDouble() * 15;
        break;
      case 'field_2': // Wheat, less water
        baseMoisture = 35 + _random.nextDouble() * 10;
        break;
      default:
        baseMoisture = 45 + _random.nextDouble() * 10;
    }

    return SoilMoistureReading(
      moisturePercent: baseMoisture,
      optimalMin: fieldId == 'field_1' ? 50 : 40,
      optimalMax: fieldId == 'field_1' ? 80 : 70,
      timestamp: DateTime.now(),
      sensorId: 'sensor_${fieldId.split('_').last}',
    );
  }

  /// Get soil nutrient reading for a field
  SoilNutrientReading getSoilNutrients(String fieldId) {
    return SoilNutrientReading(
      nitrogen: 120 + _random.nextDouble() * 80,
      phosphorus: 25 + _random.nextDouble() * 30,
      potassium: 150 + _random.nextDouble() * 50,
      ph: 6.2 + _random.nextDouble() * 0.8,
      electricalConductivity: 0.8 + _random.nextDouble() * 0.4,
      temperature: 22 + _random.nextDouble() * 6,
      timestamp: DateTime.now(),
      sensorId: 'sensor_npk_${fieldId.split('_').last}',
    );
  }

  // ============================================================================
  // IRRIGATION CONTROL
  // ============================================================================

  /// Set irrigation mode
  void setIrrigationMode(IrrigationMode mode) {
    _currentMode = mode;
    if (mode != IrrigationMode.manual) {
      _activeManualCommand = null;
    }
  }

  /// Update auto-irrigation settings
  void updateAutoSettings(AutoIrrigationSettings settings) {
    _autoSettings = settings;
  }

  /// Start manual irrigation
  void startManualIrrigation(String fieldId, int durationMinutes) {
    _currentMode = IrrigationMode.manual;
    _activeManualCommand = ManualIrrigationCommand(
      fieldId: fieldId,
      durationMinutes: durationMinutes,
      startedAt: DateTime.now(),
      isActive: true,
    );
  }

  /// Stop manual irrigation
  void stopManualIrrigation() {
    _activeManualCommand = null;
    if (_currentMode == IrrigationMode.manual) {
      _currentMode = IrrigationMode.off;
    }
  }

  /// Check if irrigation should run (for auto mode)
  bool shouldAutoIrrigate(String fieldId) {
    if (!_autoSettings.enabled || _currentMode != IrrigationMode.auto) {
      return false;
    }

    final moisture = getSoilMoisture(fieldId);
    return moisture.moisturePercent < _autoSettings.moistureThresholdLow;
  }

  // ============================================================================
  // MOCK SCHEDULES
  // ============================================================================

  final List<IrrigationSchedule> _schedules = [
    IrrigationSchedule(
      id: 'sched_1',
      fieldId: 'field_1',
      dayOfWeek: 1, // Monday
      startTime: const TimeOfDay(hour: 6, minute: 0),
      durationMinutes: 45,
    ),
    IrrigationSchedule(
      id: 'sched_2',
      fieldId: 'field_1',
      dayOfWeek: 4, // Thursday
      startTime: const TimeOfDay(hour: 6, minute: 0),
      durationMinutes: 45,
    ),
    IrrigationSchedule(
      id: 'sched_3',
      fieldId: 'field_2',
      dayOfWeek: 2, // Tuesday
      startTime: const TimeOfDay(hour: 7, minute: 30),
      durationMinutes: 30,
    ),
    IrrigationSchedule(
      id: 'sched_4',
      fieldId: 'field_2',
      dayOfWeek: 5, // Friday
      startTime: const TimeOfDay(hour: 7, minute: 30),
      durationMinutes: 30,
    ),
  ];

  List<IrrigationSchedule> get schedules => _schedules;
  List<IrrigationSchedule> getSchedulesForField(String fieldId) =>
      _schedules.where((s) => s.fieldId == fieldId).toList();

  void addSchedule(IrrigationSchedule schedule) {
    _schedules.add(schedule);
  }

  void removeSchedule(String scheduleId) {
    _schedules.removeWhere((s) => s.id == scheduleId);
  }

  // ============================================================================
  // WATER USAGE ANALYTICS (Mock data)
  // ============================================================================

  List<WaterUsageRecord> getWaterUsageHistory(String fieldId, int days) {
    final records = <WaterUsageRecord>[];
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      // Skip some days randomly to simulate non-irrigation days
      if (_random.nextBool() || i < 3) {
        final liters = 800 + _random.nextDouble() * 1200;
        records.add(WaterUsageRecord(
          date: date,
          litersUsed: liters,
          estimatedCost: liters * 0.05, // ₹0.05 per liter
          fieldId: fieldId,
          mode: i % 3 == 0 ? IrrigationMode.auto : IrrigationMode.scheduled,
        ));
      }
    }

    return records;
  }

  double getTotalWaterUsage(String fieldId, int days) {
    return getWaterUsageHistory(fieldId, days)
        .fold(0.0, (sum, record) => sum + record.litersUsed);
  }

  double getAverageWaterUsage(String fieldId, int days) {
    final records = getWaterUsageHistory(fieldId, days);
    if (records.isEmpty) return 0;
    return records.fold(0.0, (sum, r) => sum + r.litersUsed) / records.length;
  }

  // ============================================================================
  // PREMIUM FEATURES
  // ============================================================================

  /// Features available only for premium users
  Map<String, bool> get premiumFeatures => {
        'liveNPK': _isPremium,
        'autoIrrigation': _isPremium,
        'waterAnalytics': _isPremium,
        'multiField': _isPremium,
        'scheduleControl': true, // Free feature
        'weatherAlerts': true, // Free feature
      };

  bool canAccessFeature(String feature) {
    return premiumFeatures[feature] ?? false;
  }
}
