class CropAnalysisModel {
  final String cropType;
  final String healthStatus;
  final List<String> issues;
  final List<String> recommendations;
  final List<String> preventiveMeasures;
  final DateTime analyzedAt;

  CropAnalysisModel({
    required this.cropType,
    required this.healthStatus,
    required this.issues,
    required this.recommendations,
    required this.preventiveMeasures,
    DateTime? analyzedAt,
  }) : analyzedAt = analyzedAt ?? DateTime.now();

  factory CropAnalysisModel.fromJson(Map<String, dynamic> json) {
    return CropAnalysisModel(
      cropType: json['cropType'],
      healthStatus: json['healthStatus'],
      issues: List<String>.from(json['issues']),
      recommendations: List<String>.from(json['recommendations']),
      preventiveMeasures: List<String>.from(json['preventiveMeasures']),
      analyzedAt: DateTime.parse(json['analyzedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cropType': cropType,
      'healthStatus': healthStatus,
      'issues': issues,
      'recommendations': recommendations,
      'preventiveMeasures': preventiveMeasures,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }
}
