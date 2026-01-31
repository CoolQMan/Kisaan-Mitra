/// Model representing the result of a crop health analysis
class CropAnalysisModel {
  final String cropType;
  final String healthStatus; // "Healthy", "Diseased", "Unknown"
  final String? diseaseName; // e.g., "Early Blight"
  final String? diseaseScientificName; // Scientific name if available
  final String? diseaseCommonNames; // Other common names (comma-separated)
  final double? probability; // Confidence score 0.0 to 1.0
  final double? healthyProbability; // Probability that crop is healthy
  final String? cause; // e.g., "Caused by Alternaria solani fungus"
  final String? description; // Full description of the disease
  final String?
      classification; // Disease classification (fungal, bacterial, etc.) - maps to 'type'
  final String? severity; // Severity level if available
  final String? spreadInfo; // How the disease spreads - maps to 'spreading'

  // Taxonomy fields
  final String? taxonomyKingdom;
  final String? taxonomyPhylum;
  final String? taxonomyClass;
  final String? taxonomyOrder;
  final String? taxonomyFamily;
  final String? taxonomyGenus;

  // Database IDs and codes
  final String? eppoCode; // EPPO database code
  final Map<String, dynamic>? eppoRegulationStatus; // Quarantine status
  final int? gbifId; // GBIF database ID

  // Wiki/External info
  final String? wikiUrl; // Link to wiki page
  final String? wikiDescription; // Description from Wikipedia

  // Symptoms
  final String? symptoms; // Disease symptoms description

  // Representative images
  final String? representativeImage; // Main disease image URL
  final List<String> representativeImages; // More disease images

  // Treatment lists
  final List<String> issues;
  final List<String> recommendations;
  final List<String> preventiveMeasures;
  final List<String> chemicalTreatments; // Chemical treatment options
  final List<String> biologicalTreatments; // Eco-friendly biological treatments
  final List<String> culturalTreatments; // Cultural/management practices
  final List<String>
      similarImages; // URLs of similar disease images from user's crop

  // Location data
  final double? latitude; // Location where analysis was done
  final double? longitude;
  final DateTime analyzedAt;

  CropAnalysisModel({
    required this.cropType,
    required this.healthStatus,
    this.diseaseName,
    this.diseaseScientificName,
    this.diseaseCommonNames,
    this.probability,
    this.healthyProbability,
    this.cause,
    this.description,
    this.classification,
    this.severity,
    this.spreadInfo,
    this.taxonomyKingdom,
    this.taxonomyPhylum,
    this.taxonomyClass,
    this.taxonomyOrder,
    this.taxonomyFamily,
    this.taxonomyGenus,
    this.eppoCode,
    this.eppoRegulationStatus,
    this.gbifId,
    this.wikiUrl,
    this.wikiDescription,
    this.symptoms,
    this.representativeImage,
    this.representativeImages = const [],
    required this.issues,
    required this.recommendations,
    required this.preventiveMeasures,
    this.chemicalTreatments = const [],
    this.biologicalTreatments = const [],
    this.culturalTreatments = const [],
    this.similarImages = const [],
    this.latitude,
    this.longitude,
    DateTime? analyzedAt,
  }) : analyzedAt = analyzedAt ?? DateTime.now();

  /// Create model from Crop.health API response
  factory CropAnalysisModel.fromCropHealthApi(Map<String, dynamic> json) {
    final result = json['result'] ?? {};
    final isHealthy = result['is_healthy'] ?? {};
    final disease = result['disease'] ?? {};
    final suggestions =
        (disease['suggestions'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    // Determine health status based on is_healthy probability
    final healthyProbability =
        (isHealthy['probability'] as num?)?.toDouble() ?? 0.5;
    String healthStatus;
    if (healthyProbability > 0.7) {
      healthStatus = 'Healthy';
    } else if (healthyProbability > 0.3) {
      healthStatus = 'Moderate';
    } else {
      healthStatus = 'Poor';
    }

    // Initialize all fields
    String? diseaseName;
    String? diseaseScientificName;
    String? diseaseCommonNames;
    double? diseaseProbability;
    String? cause;
    String? description;
    String? classification; // maps to 'type'
    String? severity;
    String? spreadInfo; // maps to 'spreading'

    // Taxonomy
    String? taxonomyKingdom;
    String? taxonomyPhylum;
    String? taxonomyClass;
    String? taxonomyOrder;
    String? taxonomyFamily;
    String? taxonomyGenus;

    // Database codes
    String? eppoCode;
    Map<String, dynamic>? eppoRegulationStatus;
    int? gbifId;

    // Wiki
    String? wikiUrl;
    String? wikiDescription;

    // Symptoms
    String? symptoms;

    // Images
    String? representativeImage;
    List<String> representativeImages = [];

    // Treatments
    List<String> chemicalTreatments = [];
    List<String> biologicalTreatments = [];
    List<String> culturalTreatments = [];
    List<String> preventiveMeasures = [];
    List<String> issues = [];
    List<String> recommendations = [];
    List<String> similarImages = [];

    if (suggestions.isNotEmpty) {
      final topSuggestion = suggestions[0];
      diseaseName = topSuggestion['name'] as String?;
      diseaseProbability = (topSuggestion['probability'] as num?)?.toDouble();

      final details = topSuggestion['details'] as Map<String, dynamic>? ?? {};

      // Basic details
      cause = details['cause'] as String?;
      description = details['description'] as String?;
      diseaseScientificName = details['scientific_name'] as String?;
      severity = details['severity'] as String?;

      // 'type' field maps to classification (e.g., "Fungi")
      classification = details['type'] as String?;

      // 'spreading' field maps to spreadInfo
      spreadInfo = details['spreading'] as String?;

      // Symptoms - can be a dict or string
      final symptomsData = details['symptoms'];
      if (symptomsData is String) {
        symptoms = symptomsData;
      } else if (symptomsData is Map) {
        // Combine all symptom descriptions
        final symptomParts = <String>[];
        symptomsData.forEach((key, value) {
          if (value is String && value.isNotEmpty) {
            symptomParts.add('$key: $value');
          }
        });
        symptoms = symptomParts.join('\n');
      }

      // Parse common names
      final commonNames = details['common_names'] as List?;
      if (commonNames != null && commonNames.isNotEmpty) {
        diseaseCommonNames = commonNames.take(5).join(', ');
      }

      // EPPO code
      eppoCode = details['eppo_code'] as String?;

      // EPPO regulation status
      if (details['eppo_regulation_status'] is Map) {
        eppoRegulationStatus =
            Map<String, dynamic>.from(details['eppo_regulation_status']);
      }

      // GBIF ID
      gbifId = details['gbif_id'] as int?;

      // Wiki URL and description
      wikiUrl = details['wiki_url'] as String?;
      wikiDescription = details['wiki_description'] as String?;

      // Taxonomy
      final taxonomy = details['taxonomy'] as Map<String, dynamic>? ?? {};
      taxonomyKingdom = taxonomy['kingdom'] as String?;
      taxonomyPhylum = taxonomy['phylum'] as String?;
      taxonomyClass = taxonomy['class'] as String?;
      taxonomyOrder = taxonomy['order'] as String?;
      taxonomyFamily = taxonomy['family'] as String?;
      taxonomyGenus = taxonomy['genus'] as String?;

      // Representative image
      representativeImage = details['image'] as String?;

      // Multiple representative images
      final imagesData = details['images'] as List?;
      if (imagesData != null) {
        for (var img in imagesData) {
          if (img is Map && img['url'] != null) {
            representativeImages.add(img['url'] as String);
          } else if (img is String) {
            representativeImages.add(img);
          }
        }
      }

      // Add wiki description or description as an issue
      if (wikiDescription != null && wikiDescription.isNotEmpty) {
        issues.add(wikiDescription);
      } else if (description != null && description.isNotEmpty) {
        issues.add(description);
      }

      // Add disease name as issue if available
      if (diseaseName != null) {
        issues.insert(0, 'Detected: $diseaseName');
      }

      // Parse treatment options
      final treatment = details['treatment'] as Map<String, dynamic>? ?? {};

      chemicalTreatments = _parseStringList(treatment['chemical']);
      biologicalTreatments = _parseStringList(treatment['biological']);
      preventiveMeasures = _parseStringList(treatment['prevention']);
      culturalTreatments = _parseStringList(treatment['cultural']);

      // Combine treatments into recommendations
      recommendations = [...chemicalTreatments, ...biologicalTreatments];

      // Parse similar images from user's crop
      final similarImagesData = topSuggestion['similar_images'] as List? ?? [];
      for (var img in similarImagesData) {
        if (img is Map && img['url'] != null) {
          similarImages.add(img['url'] as String);
        } else if (img is String) {
          similarImages.add(img);
        }
      }
    }

    // If healthy, provide positive feedback
    if (healthStatus == 'Healthy' && issues.isEmpty) {
      issues.add('No diseases or pests detected');
      recommendations.add('Continue current care practices');
      preventiveMeasures.add('Regular monitoring recommended');
    }

    return CropAnalysisModel(
      cropType: json['crop_type'] as String? ?? 'Unknown Crop',
      healthStatus: healthStatus,
      diseaseName: diseaseName,
      diseaseScientificName: diseaseScientificName,
      diseaseCommonNames: diseaseCommonNames,
      probability: diseaseProbability,
      healthyProbability: healthyProbability,
      cause: cause,
      description: description,
      classification: classification,
      severity: severity,
      spreadInfo: spreadInfo,
      taxonomyKingdom: taxonomyKingdom,
      taxonomyPhylum: taxonomyPhylum,
      taxonomyClass: taxonomyClass,
      taxonomyOrder: taxonomyOrder,
      taxonomyFamily: taxonomyFamily,
      taxonomyGenus: taxonomyGenus,
      eppoCode: eppoCode,
      eppoRegulationStatus: eppoRegulationStatus,
      gbifId: gbifId,
      wikiUrl: wikiUrl,
      wikiDescription: wikiDescription,
      symptoms: symptoms,
      representativeImage: representativeImage,
      representativeImages: representativeImages,
      issues: issues,
      recommendations: recommendations,
      preventiveMeasures: preventiveMeasures,
      chemicalTreatments: chemicalTreatments,
      biologicalTreatments: biologicalTreatments,
      culturalTreatments: culturalTreatments,
      similarImages: similarImages,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      analyzedAt: DateTime.now(),
    );
  }

  /// Legacy factory for backward compatibility
  factory CropAnalysisModel.fromJson(Map<String, dynamic> json) {
    return CropAnalysisModel(
      cropType: json['cropType'] ?? 'Unknown',
      healthStatus: json['healthStatus'] ?? 'Unknown',
      diseaseName: json['diseaseName'],
      diseaseScientificName: json['diseaseScientificName'],
      diseaseCommonNames: json['diseaseCommonNames'],
      probability: (json['probability'] as num?)?.toDouble(),
      healthyProbability: (json['healthyProbability'] as num?)?.toDouble(),
      cause: json['cause'],
      description: json['description'],
      classification: json['classification'],
      severity: json['severity'],
      spreadInfo: json['spreadInfo'],
      taxonomyKingdom: json['taxonomyKingdom'],
      taxonomyPhylum: json['taxonomyPhylum'],
      taxonomyClass: json['taxonomyClass'],
      taxonomyOrder: json['taxonomyOrder'],
      taxonomyFamily: json['taxonomyFamily'],
      taxonomyGenus: json['taxonomyGenus'],
      eppoCode: json['eppoCode'],
      eppoRegulationStatus: json['eppoRegulationStatus'],
      gbifId: json['gbifId'],
      wikiUrl: json['wikiUrl'],
      wikiDescription: json['wikiDescription'],
      symptoms: json['symptoms'],
      representativeImage: json['representativeImage'],
      representativeImages:
          List<String>.from(json['representativeImages'] ?? []),
      issues: List<String>.from(json['issues'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      preventiveMeasures: List<String>.from(json['preventiveMeasures'] ?? []),
      chemicalTreatments: List<String>.from(json['chemicalTreatments'] ?? []),
      biologicalTreatments:
          List<String>.from(json['biologicalTreatments'] ?? []),
      culturalTreatments: List<String>.from(json['culturalTreatments'] ?? []),
      similarImages: List<String>.from(json['similarImages'] ?? []),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      analyzedAt: json['analyzedAt'] != null
          ? DateTime.parse(json['analyzedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cropType': cropType,
      'healthStatus': healthStatus,
      'diseaseName': diseaseName,
      'diseaseScientificName': diseaseScientificName,
      'diseaseCommonNames': diseaseCommonNames,
      'probability': probability,
      'healthyProbability': healthyProbability,
      'cause': cause,
      'description': description,
      'classification': classification,
      'severity': severity,
      'spreadInfo': spreadInfo,
      'taxonomyKingdom': taxonomyKingdom,
      'taxonomyPhylum': taxonomyPhylum,
      'taxonomyClass': taxonomyClass,
      'taxonomyOrder': taxonomyOrder,
      'taxonomyFamily': taxonomyFamily,
      'taxonomyGenus': taxonomyGenus,
      'eppoCode': eppoCode,
      'eppoRegulationStatus': eppoRegulationStatus,
      'gbifId': gbifId,
      'wikiUrl': wikiUrl,
      'wikiDescription': wikiDescription,
      'symptoms': symptoms,
      'representativeImage': representativeImage,
      'representativeImages': representativeImages,
      'issues': issues,
      'recommendations': recommendations,
      'preventiveMeasures': preventiveMeasures,
      'chemicalTreatments': chemicalTreatments,
      'biologicalTreatments': biologicalTreatments,
      'culturalTreatments': culturalTreatments,
      'similarImages': similarImages,
      'latitude': latitude,
      'longitude': longitude,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }

  /// Helper to parse string lists from API response
  static List<String> _parseStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    if (data is String) {
      return [data];
    }
    return [];
  }

  /// Get a display-friendly probability percentage
  String get probabilityText {
    if (probability == null) return '';
    return '${(probability! * 100).toStringAsFixed(0)}%';
  }

  /// Check if this analysis detected a disease
  bool get hasDisease => diseaseName != null && healthStatus != 'Healthy';

  /// Check if taxonomy data is available
  bool get hasTaxonomy =>
      taxonomyKingdom != null ||
      taxonomyPhylum != null ||
      taxonomyGenus != null;

  /// Get formatted taxonomy string
  String get taxonomyString {
    final parts = <String>[];
    if (taxonomyKingdom != null) parts.add('Kingdom: $taxonomyKingdom');
    if (taxonomyPhylum != null) parts.add('Phylum: $taxonomyPhylum');
    if (taxonomyClass != null) parts.add('Class: $taxonomyClass');
    if (taxonomyOrder != null) parts.add('Order: $taxonomyOrder');
    if (taxonomyFamily != null) parts.add('Family: $taxonomyFamily');
    if (taxonomyGenus != null) parts.add('Genus: $taxonomyGenus');
    return parts.join(' > ');
  }
}
