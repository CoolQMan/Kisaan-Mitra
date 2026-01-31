// IoT Sensor Models for Smart Irrigation
// Includes soil sensors, irrigation control, and field management

import 'package:flutter/material.dart';

// ============================================================================
// SENSOR MODELS
// ============================================================================

/// Soil moisture reading from IoT sensor
class SoilMoistureReading {
  final double moisturePercent; // 0-100%
  final double optimalMin;
  final double optimalMax;
  final DateTime timestamp;
  final String sensorId;

  const SoilMoistureReading({
    required this.moisturePercent,
    this.optimalMin = 40,
    this.optimalMax = 70,
    required this.timestamp,
    required this.sensorId,
  });

  bool get isOptimal =>
      moisturePercent >= optimalMin && moisturePercent <= optimalMax;
  bool get needsWater => moisturePercent < optimalMin;
  bool get isOverwatered => moisturePercent > optimalMax;

  String get status {
    if (needsWater) return 'Low - Needs Water';
    if (isOverwatered) return 'High - Stop Irrigation';
    return 'Optimal';
  }

  Color get statusColor {
    if (needsWater) return Colors.red;
    if (isOverwatered) return Colors.orange;
    return Colors.green;
  }
}

/// Soil nutrient levels (NPK)
class SoilNutrientReading {
  final double nitrogen; // mg/kg
  final double phosphorus; // mg/kg
  final double potassium; // mg/kg
  final double ph; // 0-14
  final double electricalConductivity; // mS/cm (salinity)
  final double temperature; // °C (soil temp)
  final DateTime timestamp;
  final String sensorId;

  const SoilNutrientReading({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.ph,
    required this.electricalConductivity,
    required this.temperature,
    required this.timestamp,
    required this.sensorId,
  });

  String get nitrogenLevel =>
      nitrogen > 250 ? 'High' : (nitrogen > 100 ? 'Medium' : 'Low');
  String get phosphorusLevel =>
      phosphorus > 50 ? 'High' : (phosphorus > 20 ? 'Medium' : 'Low');
  String get potassiumLevel =>
      potassium > 200 ? 'High' : (potassium > 100 ? 'Medium' : 'Low');

  String get phStatus {
    if (ph < 5.5) return 'Too Acidic';
    if (ph > 7.5) return 'Too Alkaline';
    return 'Optimal';
  }

  Color get phColor {
    if (ph < 5.5 || ph > 7.5) return Colors.red;
    if (ph < 6.0 || ph > 7.0) return Colors.orange;
    return Colors.green;
  }
}

/// IoT sensor device status
class SensorDevice {
  final String id;
  final String name;
  final String type; // moisture, nutrient, weather
  final bool isOnline;
  final int batteryPercent;
  final DateTime lastSync;
  final String fieldId;

  const SensorDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.isOnline,
    required this.batteryPercent,
    required this.lastSync,
    required this.fieldId,
  });

  bool get needsBatteryReplace => batteryPercent < 20;
}

// ============================================================================
// IRRIGATION CONTROL MODELS
// ============================================================================

/// Irrigation mode
enum IrrigationMode {
  off, // System off
  manual, // Manual control only
  auto, // Fully automatic based on sensors
  scheduled // Time-based schedule
}

extension IrrigationModeExtension on IrrigationMode {
  String get displayName {
    switch (this) {
      case IrrigationMode.off:
        return 'Off';
      case IrrigationMode.manual:
        return 'Manual';
      case IrrigationMode.auto:
        return 'Auto (Smart)';
      case IrrigationMode.scheduled:
        return 'Scheduled';
    }
  }

  String get description {
    switch (this) {
      case IrrigationMode.off:
        return 'Irrigation system is turned off';
      case IrrigationMode.manual:
        return 'Control irrigation manually';
      case IrrigationMode.auto:
        return 'Automatic based on soil moisture & weather';
      case IrrigationMode.scheduled:
        return 'Runs at scheduled times';
    }
  }

  IconData get icon {
    switch (this) {
      case IrrigationMode.off:
        return Icons.power_settings_new;
      case IrrigationMode.manual:
        return Icons.touch_app;
      case IrrigationMode.auto:
        return Icons.auto_mode;
      case IrrigationMode.scheduled:
        return Icons.schedule;
    }
  }
}

/// Auto-irrigation settings
class AutoIrrigationSettings {
  final bool enabled;
  final double moistureThresholdLow; // Start irrigation when below this
  final double moistureThresholdHigh; // Stop irrigation when above this
  final bool pauseOnRain; // Stop if rain predicted
  final bool pauseOnHighHumidity; // Stop if humidity > 80%
  final TimeOfDay preferredStartTime;
  final TimeOfDay preferredEndTime;
  final int maxDurationMinutes;
  final List<String> activeFieldIds;

  const AutoIrrigationSettings({
    this.enabled = false,
    this.moistureThresholdLow = 35,
    this.moistureThresholdHigh = 65,
    this.pauseOnRain = true,
    this.pauseOnHighHumidity = true,
    this.preferredStartTime = const TimeOfDay(hour: 6, minute: 0),
    this.preferredEndTime = const TimeOfDay(hour: 8, minute: 0),
    this.maxDurationMinutes = 30,
    this.activeFieldIds = const [],
  });

  AutoIrrigationSettings copyWith({
    bool? enabled,
    double? moistureThresholdLow,
    double? moistureThresholdHigh,
    bool? pauseOnRain,
    bool? pauseOnHighHumidity,
    TimeOfDay? preferredStartTime,
    TimeOfDay? preferredEndTime,
    int? maxDurationMinutes,
    List<String>? activeFieldIds,
  }) {
    return AutoIrrigationSettings(
      enabled: enabled ?? this.enabled,
      moistureThresholdLow: moistureThresholdLow ?? this.moistureThresholdLow,
      moistureThresholdHigh:
          moistureThresholdHigh ?? this.moistureThresholdHigh,
      pauseOnRain: pauseOnRain ?? this.pauseOnRain,
      pauseOnHighHumidity: pauseOnHighHumidity ?? this.pauseOnHighHumidity,
      preferredStartTime: preferredStartTime ?? this.preferredStartTime,
      preferredEndTime: preferredEndTime ?? this.preferredEndTime,
      maxDurationMinutes: maxDurationMinutes ?? this.maxDurationMinutes,
      activeFieldIds: activeFieldIds ?? this.activeFieldIds,
    );
  }
}

/// Manual irrigation trigger
class ManualIrrigationCommand {
  final String fieldId;
  final int durationMinutes;
  final DateTime startedAt;
  final bool isActive;

  const ManualIrrigationCommand({
    required this.fieldId,
    required this.durationMinutes,
    required this.startedAt,
    this.isActive = true,
  });

  DateTime get estimatedEndTime =>
      startedAt.add(Duration(minutes: durationMinutes));
  int get remainingMinutes {
    final remaining = estimatedEndTime.difference(DateTime.now()).inMinutes;
    return remaining > 0 ? remaining : 0;
  }
}

/// Scheduled irrigation slot
class IrrigationSchedule {
  final String id;
  final String fieldId;
  final int dayOfWeek; // 1-7 (Monday-Sunday)
  final TimeOfDay startTime;
  final int durationMinutes;
  final bool isEnabled;

  const IrrigationSchedule({
    required this.id,
    required this.fieldId,
    required this.dayOfWeek,
    required this.startTime,
    required this.durationMinutes,
    this.isEnabled = true,
  });

  String get dayName {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dayOfWeek - 1];
  }
}

// ============================================================================
// FIELD MODEL
// ============================================================================

/// Farmer's field/plot
class FieldModel {
  final String id;
  final String name;
  final double areaAcres;
  final String currentCrop;
  final String soilType; // clay, loam, sandy, etc.
  final List<String> sensorIds;
  final DateTime? lastIrrigated;
  final double? lastWaterUsedLiters;

  const FieldModel({
    required this.id,
    required this.name,
    required this.areaAcres,
    required this.currentCrop,
    required this.soilType,
    this.sensorIds = const [],
    this.lastIrrigated,
    this.lastWaterUsedLiters,
  });
}

// ============================================================================
// WATER USAGE ANALYTICS
// ============================================================================

/// Daily water usage record
class WaterUsageRecord {
  final DateTime date;
  final double litersUsed;
  final double estimatedCost; // in ₹
  final String fieldId;
  final IrrigationMode mode;

  const WaterUsageRecord({
    required this.date,
    required this.litersUsed,
    required this.estimatedCost,
    required this.fieldId,
    required this.mode,
  });
}
