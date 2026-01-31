import 'package:flutter/material.dart';
import 'package:kisaan_mitra/models/crop_analysis_model.dart';

/// Disease preset types for consistent theming across PDF and UI
enum DiseasePreset {
  healthy, // Green - no issues
  mild, // Yellow - minor issues
  moderate, // Orange - needs attention
  severe, // Red - critical issue
  fungal, // Purple tint - fungal diseases
  bacterial, // Blue tint - bacterial diseases
  viral, // Pink tint - viral diseases
  pest, // Brown tint - pest damage
  nutrient, // Teal tint - nutrient deficiency
}

/// Theme data for a disease preset
class DiseaseThemeData {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final String label;
  final String labelHindi;

  const DiseaseThemeData({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.label,
    required this.labelHindi,
  });

  /// Get gradient colors for headers
  List<Color> get gradientColors => [primaryColor, secondaryColor];
}

/// Utility class for disease theming
class DiseaseThemeHelper {
  /// Determine disease preset based on analysis result
  static DiseasePreset getPreset(CropAnalysisModel result) {
    if (result.healthStatus == 'Healthy') return DiseasePreset.healthy;

    // Check classification for specific disease types
    final classification = result.classification?.toLowerCase() ?? '';
    final diseaseName = result.diseaseName?.toLowerCase() ?? '';
    final taxonomyKingdom = result.taxonomyKingdom?.toLowerCase() ?? '';

    // Check for fungal diseases
    if (classification.contains('fung') ||
        taxonomyKingdom == 'fungi' ||
        diseaseName.contains('rust') ||
        diseaseName.contains('blight') ||
        diseaseName.contains('mildew') ||
        diseaseName.contains('rot') ||
        diseaseName.contains('smut') ||
        diseaseName.contains('wilt') ||
        diseaseName.contains('spot')) {
      return DiseasePreset.fungal;
    }

    // Check for bacterial diseases
    if (classification.contains('bacteri') ||
        taxonomyKingdom == 'bacteria' ||
        diseaseName.contains('bacterial') ||
        diseaseName.contains('canker') ||
        diseaseName.contains('scab')) {
      return DiseasePreset.bacterial;
    }

    // Check for viral diseases
    if (classification.contains('viral') ||
        classification.contains('virus') ||
        diseaseName.contains('mosaic') ||
        diseaseName.contains('curl') ||
        diseaseName.contains('yellows') ||
        diseaseName.contains('streak')) {
      return DiseasePreset.viral;
    }

    // Check for pest damage
    if (classification.contains('pest') ||
        classification.contains('insect') ||
        diseaseName.contains('aphid') ||
        diseaseName.contains('mite') ||
        diseaseName.contains('worm') ||
        diseaseName.contains('borer') ||
        diseaseName.contains('beetle') ||
        diseaseName.contains('fly')) {
      return DiseasePreset.pest;
    }

    // Check for nutrient deficiency
    if (classification.contains('nutrient') ||
        classification.contains('deficiency') ||
        diseaseName.contains('deficiency') ||
        diseaseName.contains('chlorosis') ||
        diseaseName.contains('necrosis')) {
      return DiseasePreset.nutrient;
    }

    // Determine by probability/severity
    final probability = result.probability ?? 0.5;
    if (probability > 0.8) return DiseasePreset.severe;
    if (probability > 0.5) return DiseasePreset.moderate;
    return DiseasePreset.mild;
  }

  /// Get theme data for a preset
  static DiseaseThemeData getThemeData(DiseasePreset preset) {
    switch (preset) {
      case DiseasePreset.healthy:
        return const DiseaseThemeData(
          primaryColor: Color(0xFF4CAF50),
          secondaryColor: Color(0xFF26A69A),
          backgroundColor: Color(0xFFE8F5E9),
          textColor: Color(0xFF1B5E20),
          icon: Icons.check_circle,
          label: 'Healthy Crop',
          labelHindi: 'स्वस्थ फसल',
        );
      case DiseasePreset.mild:
        return const DiseaseThemeData(
          primaryColor: Color(0xFFFFC107),
          secondaryColor: Color(0xFFFFB300),
          backgroundColor: Color(0xFFFFF8E1),
          textColor: Color(0xFFF57F17),
          icon: Icons.info_outline,
          label: 'Mild Infection',
          labelHindi: 'हल्का संक्रमण',
        );
      case DiseasePreset.moderate:
        return const DiseaseThemeData(
          primaryColor: Color(0xFFFF9800),
          secondaryColor: Color(0xFFF57C00),
          backgroundColor: Color(0xFFFFF3E0),
          textColor: Color(0xFFE65100),
          icon: Icons.warning_amber_rounded,
          label: 'Moderate Infection',
          labelHindi: 'मध्यम संक्रमण',
        );
      case DiseasePreset.severe:
        return const DiseaseThemeData(
          primaryColor: Color(0xFFF44336),
          secondaryColor: Color(0xFFD32F2F),
          backgroundColor: Color(0xFFFFEBEE),
          textColor: Color(0xFFB71C1C),
          icon: Icons.error,
          label: 'Severe Infection',
          labelHindi: 'गंभीर संक्रमण',
        );
      case DiseasePreset.fungal:
        return const DiseaseThemeData(
          primaryColor: Color(0xFF9C27B0),
          secondaryColor: Color(0xFF7B1FA2),
          backgroundColor: Color(0xFFF3E5F5),
          textColor: Color(0xFF4A148C),
          icon: Icons.spa,
          label: 'Fungal Disease',
          labelHindi: 'फफूंद रोग',
        );
      case DiseasePreset.bacterial:
        return const DiseaseThemeData(
          primaryColor: Color(0xFF2196F3),
          secondaryColor: Color(0xFF1976D2),
          backgroundColor: Color(0xFFE3F2FD),
          textColor: Color(0xFF0D47A1),
          icon: Icons.scatter_plot,
          label: 'Bacterial Disease',
          labelHindi: 'जीवाणु रोग',
        );
      case DiseasePreset.viral:
        return const DiseaseThemeData(
          primaryColor: Color(0xFFE91E63),
          secondaryColor: Color(0xFFC2185B),
          backgroundColor: Color(0xFFFCE4EC),
          textColor: Color(0xFF880E4F),
          icon: Icons.coronavirus,
          label: 'Viral Disease',
          labelHindi: 'विषाणु रोग',
        );
      case DiseasePreset.pest:
        return const DiseaseThemeData(
          primaryColor: Color(0xFF795548),
          secondaryColor: Color(0xFF5D4037),
          backgroundColor: Color(0xFFEFEBE9),
          textColor: Color(0xFF3E2723),
          icon: Icons.bug_report,
          label: 'Pest Damage',
          labelHindi: 'कीट क्षति',
        );
      case DiseasePreset.nutrient:
        return const DiseaseThemeData(
          primaryColor: Color(0xFF00BCD4),
          secondaryColor: Color(0xFF0097A7),
          backgroundColor: Color(0xFFE0F7FA),
          textColor: Color(0xFF006064),
          icon: Icons.water_drop,
          label: 'Nutrient Deficiency',
          labelHindi: 'पोषक तत्व की कमी',
        );
    }
  }

  /// Get theme directly from a CropAnalysisModel
  static DiseaseThemeData getThemeFromResult(CropAnalysisModel result) {
    return getThemeData(getPreset(result));
  }
}
