import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:kisaan_mitra/models/crop_analysis_model.dart';
import 'package:intl/intl.dart';

/// Supported languages for PDF export
enum ReportLanguage { english, hindi }

/// Disease severity/type presets for styling
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

/// Service for generating PDF reports for crop analysis results
class PdfReportService {
  pw.Font? _regularFont;
  pw.Font? _boldFont;

  // Translation callback for Hindi (to be set from outside if translation API is available)
  Future<String> Function(String text)? translateToHindi;

  /// Load Hindi fonts for PDF
  Future<void> _loadFonts() async {
    if (_regularFont == null) {
      try {
        final regularData = await rootBundle
            .load('assets/fonts/NotoSansDevanagari-Regular.ttf');
        final boldData =
            await rootBundle.load('assets/fonts/NotoSansDevanagari-Bold.ttf');
        _regularFont = pw.Font.ttf(regularData);
        _boldFont = pw.Font.ttf(boldData);
      } catch (e) {
        // Fallback to built-in fonts if Hindi fonts not available
        _regularFont = null;
        _boldFont = null;
      }
    }
  }

  /// Determine disease preset based on analysis result
  DiseasePreset _getDiseasePreset(CropAnalysisModel result) {
    if (result.healthStatus == 'Healthy') return DiseasePreset.healthy;

    // Check classification for specific disease types
    final classification = result.classification?.toLowerCase() ?? '';
    final diseaseName = result.diseaseName?.toLowerCase() ?? '';

    if (classification.contains('fungal') ||
        classification.contains('fungus') ||
        diseaseName.contains('rust') ||
        diseaseName.contains('blight') ||
        diseaseName.contains('mildew') ||
        diseaseName.contains('rot')) {
      return DiseasePreset.fungal;
    }

    if (classification.contains('bacterial') ||
        classification.contains('bacteria')) {
      return DiseasePreset.bacterial;
    }

    if (classification.contains('viral') ||
        classification.contains('virus') ||
        diseaseName.contains('mosaic') ||
        diseaseName.contains('curl')) {
      return DiseasePreset.viral;
    }

    if (classification.contains('pest') ||
        classification.contains('insect') ||
        diseaseName.contains('aphid') ||
        diseaseName.contains('mite') ||
        diseaseName.contains('worm') ||
        diseaseName.contains('borer')) {
      return DiseasePreset.pest;
    }

    if (classification.contains('nutrient') ||
        classification.contains('deficiency') ||
        diseaseName.contains('deficiency') ||
        diseaseName.contains('chlorosis')) {
      return DiseasePreset.nutrient;
    }

    // Determine by probability/severity
    final probability = result.probability ?? 0.5;
    if (probability > 0.8) return DiseasePreset.severe;
    if (probability > 0.5) return DiseasePreset.moderate;
    return DiseasePreset.mild;
  }

  /// Get colors for disease preset
  Map<String, PdfColor> _getPresetColors(DiseasePreset preset) {
    switch (preset) {
      case DiseasePreset.healthy:
        return {
          'primary': PdfColor.fromHex('#4CAF50'),
          'background': PdfColor.fromHex('#E8F5E9'),
          'accent': PdfColor.fromHex('#81C784'),
        };
      case DiseasePreset.mild:
        return {
          'primary': PdfColor.fromHex('#FFC107'),
          'background': PdfColor.fromHex('#FFF8E1'),
          'accent': PdfColor.fromHex('#FFD54F'),
        };
      case DiseasePreset.moderate:
        return {
          'primary': PdfColor.fromHex('#FF9800'),
          'background': PdfColor.fromHex('#FFF3E0'),
          'accent': PdfColor.fromHex('#FFB74D'),
        };
      case DiseasePreset.severe:
        return {
          'primary': PdfColor.fromHex('#F44336'),
          'background': PdfColor.fromHex('#FFEBEE'),
          'accent': PdfColor.fromHex('#EF5350'),
        };
      case DiseasePreset.fungal:
        return {
          'primary': PdfColor.fromHex('#9C27B0'),
          'background': PdfColor.fromHex('#F3E5F5'),
          'accent': PdfColor.fromHex('#BA68C8'),
        };
      case DiseasePreset.bacterial:
        return {
          'primary': PdfColor.fromHex('#2196F3'),
          'background': PdfColor.fromHex('#E3F2FD'),
          'accent': PdfColor.fromHex('#64B5F6'),
        };
      case DiseasePreset.viral:
        return {
          'primary': PdfColor.fromHex('#E91E63'),
          'background': PdfColor.fromHex('#FCE4EC'),
          'accent': PdfColor.fromHex('#F06292'),
        };
      case DiseasePreset.pest:
        return {
          'primary': PdfColor.fromHex('#795548'),
          'background': PdfColor.fromHex('#EFEBE9'),
          'accent': PdfColor.fromHex('#A1887F'),
        };
      case DiseasePreset.nutrient:
        return {
          'primary': PdfColor.fromHex('#00BCD4'),
          'background': PdfColor.fromHex('#E0F7FA'),
          'accent': PdfColor.fromHex('#4DD0E1'),
        };
    }
  }

  /// Get preset label
  String _getPresetLabel(DiseasePreset preset, Map<String, String> labels) {
    final isHindi = labels['appName'] == 'किसान मित्र';
    switch (preset) {
      case DiseasePreset.healthy:
        return isHindi ? 'स्वस्थ फसल' : 'Healthy Crop';
      case DiseasePreset.mild:
        return isHindi ? 'हल्का संक्रमण' : 'Mild Infection';
      case DiseasePreset.moderate:
        return isHindi ? 'मध्यम संक्रमण' : 'Moderate Infection';
      case DiseasePreset.severe:
        return isHindi ? 'गंभीर संक्रमण' : 'Severe Infection';
      case DiseasePreset.fungal:
        return isHindi ? 'फफूंद रोग' : 'Fungal Disease';
      case DiseasePreset.bacterial:
        return isHindi ? 'जीवाणु रोग' : 'Bacterial Disease';
      case DiseasePreset.viral:
        return isHindi ? 'विषाणु रोग' : 'Viral Disease';
      case DiseasePreset.pest:
        return isHindi ? 'कीट क्षति' : 'Pest Damage';
      case DiseasePreset.nutrient:
        return isHindi ? 'पोषक तत्व की कमी' : 'Nutrient Deficiency';
    }
  }

  /// Generate and save a PDF report for crop analysis
  Future<String> generateCropAnalysisReport(
    CropAnalysisModel result, {
    ReportLanguage language = ReportLanguage.english,
  }) async {
    // Load Hindi fonts if needed
    if (language == ReportLanguage.hindi) {
      await _loadFonts();
    }

    final pdf = pw.Document();

    // Get labels based on language
    final labels = _getLabels(language);

    // Get disease preset for styling
    final preset = _getDiseasePreset(result);
    final presetColors = _getPresetColors(preset);

    // Create theme with Hindi font if available
    final theme = language == ReportLanguage.hindi && _regularFont != null
        ? pw.ThemeData.withFont(
            base: _regularFont!,
            bold: _boldFont ?? _regularFont!,
          )
        : null;

    // Translate content if Hindi and translator is available
    CropAnalysisModel translatedResult = result;
    if (language == ReportLanguage.hindi && translateToHindi != null) {
      translatedResult = await _translateResult(result);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: theme,
        header: (context) =>
            _buildHeader(translatedResult, presetColors['primary']!, labels),
        footer: (context) => _buildFooter(context, labels),
        build: (context) => [
          pw.SizedBox(height: 16),

          // Disease Detection Banner (styled by preset)
          _buildDiseaseBanner(translatedResult, preset, presetColors, labels),
          pw.SizedBox(height: 16),

          // Health Status with probability
          _buildHealthStatusCard(translatedResult, presetColors, labels),
          pw.SizedBox(height: 16),

          // Wiki Description (if available)
          if (translatedResult.wikiDescription != null &&
              translatedResult.wikiDescription!.isNotEmpty) ...[
            _buildDetailSection(
              labels['wikiDescription'] ?? 'Wikipedia Description',
              translatedResult.wikiDescription!,
              PdfColor.fromHex('#1976D2'),
              linkUrl: translatedResult.wikiUrl,
            ),
            pw.SizedBox(height: 12),
          ],

          // Symptoms (if available)
          if (translatedResult.symptoms != null &&
              translatedResult.symptoms!.isNotEmpty) ...[
            _buildDetailSection(
              labels['symptoms'] ?? 'Symptoms',
              translatedResult.symptoms!,
              PdfColor.fromHex('#E65100'),
            ),
            pw.SizedBox(height: 12),
          ],

          // Scientific Taxonomy (if available)
          if (translatedResult.hasTaxonomy) ...[
            _buildTaxonomySection(translatedResult, labels),
            pw.SizedBox(height: 12),
          ],

          // EPPO Code and GBIF ID (if available)
          if (translatedResult.eppoCode != null ||
              translatedResult.gbifId != null) ...[
            _buildDatabaseCodesSection(translatedResult, labels),
            pw.SizedBox(height: 12),
          ],

          // Full Description (if available and different from wiki)
          if (translatedResult.description != null &&
              translatedResult.description!.isNotEmpty &&
              translatedResult.description !=
                  translatedResult.wikiDescription) ...[
            _buildDetailSection(
              labels['description']!,
              translatedResult.description!,
              PdfColor.fromHex('#607D8B'),
            ),
            pw.SizedBox(height: 12),
          ],

          // Cause of Disease
          if (translatedResult.cause != null &&
              translatedResult.cause!.isNotEmpty) ...[
            _buildDetailSection(
              labels['cause']!,
              translatedResult.cause!,
              PdfColor.fromHex('#FF5722'),
            ),
            pw.SizedBox(height: 12),
          ],

          // How It Spreads
          if (translatedResult.spreadInfo != null &&
              translatedResult.spreadInfo!.isNotEmpty) ...[
            _buildDetailSection(
              labels['spreadInfo']!,
              translatedResult.spreadInfo!,
              PdfColor.fromHex('#FF9800'),
            ),
            pw.SizedBox(height: 12),
          ],

          // Chemical Treatments
          if (translatedResult.chemicalTreatments.isNotEmpty) ...[
            _buildTreatmentCard(
              labels['chemicalTreatment']!,
              translatedResult.chemicalTreatments,
              PdfColor.fromHex('#9C27B0'),
              warning: labels['chemicalWarning'],
            ),
            pw.SizedBox(height: 12),
          ],

          // Biological Treatments
          if (translatedResult.biologicalTreatments.isNotEmpty) ...[
            _buildTreatmentCard(
              labels['biologicalTreatment']!,
              translatedResult.biologicalTreatments,
              PdfColor.fromHex('#4CAF50'),
              badge: labels['ecoFriendly'],
            ),
            pw.SizedBox(height: 12),
          ],

          // Cultural/Management Practices
          if (translatedResult.culturalTreatments.isNotEmpty) ...[
            _buildListSection(
              labels['culturalPractices']!,
              translatedResult.culturalTreatments,
              PdfColor.fromHex('#00BCD4'),
            ),
            pw.SizedBox(height: 12),
          ],

          // Preventive Measures
          if (translatedResult.preventiveMeasures.isNotEmpty) ...[
            _buildListSection(
              labels['preventiveMeasures']!,
              translatedResult.preventiveMeasures,
              PdfColor.fromHex('#009688'),
            ),
            pw.SizedBox(height: 12),
          ],

          // Technical Details
          _buildTechnicalDetailsCard(translatedResult, labels),
          pw.SizedBox(height: 16),
        ],
      ),
    );

    // Save the PDF
    final directory = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${directory.path}/CropReports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final langSuffix = language == ReportLanguage.hindi ? '_HI' : '_EN';
    final fileName =
        'CropReport_${result.cropType.replaceAll(' ', '_')}_$timestamp$langSuffix.pdf';
    final filePath = '${reportsDir.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  /// Get localized labels
  Map<String, String> _getLabels(ReportLanguage language) {
    if (language == ReportLanguage.hindi) {
      return {
        'appName': 'किसान मित्र',
        'reportTitle': 'फसल स्वास्थ्य विश्लेषण रिपोर्ट',
        'generatedOn': 'बनाया गया:',
        'healthAssessment': 'स्वास्थ्य मूल्यांकन',
        'cropType': 'फसल का प्रकार:',
        'status': 'स्थिति:',
        'healthScore': 'स्वास्थ्य स्कोर:',
        'detectedDisease': 'पहचाना गया रोग',
        'match': 'मिलान',
        'scientificName': 'वैज्ञानिक नाम:',
        'alsoKnownAs': 'अन्य नाम:',
        'classification': 'वर्गीकरण:',
        'severity': 'गंभीरता:',
        'description': 'विवरण',
        'cause': 'रोग का कारण',
        'spreadInfo': 'फैलने की जानकारी',
        'chemicalTreatment': 'रासायनिक उपचार',
        'chemicalWarning':
            'सुरक्षा गियर का उपयोग करें और निर्देशों का पालन करें',
        'biologicalTreatment': 'जैविक उपचार',
        'ecoFriendly': 'पर्यावरण अनुकूल',
        'culturalPractices': 'प्रबंधन अभ्यास',
        'preventiveMeasures': 'निवारक उपाय',
        'recommendations': 'सिफारिशें',
        'technicalDetails': 'तकनीकी विवरण',
        'confidenceScore': 'विश्वास स्कोर:',
        'healthyProbability': 'स्वस्थ संभावना:',
        'analysisLocation': 'स्थान:',
        'analyzedOn': 'विश्लेषण तिथि:',
        'footerText': 'किसान मित्र - AI कृषि सहायक',
        'page': 'पृष्ठ',
        'of': 'का',
        'healthy': 'स्वस्थ',
        'moderate': 'मध्यम',
        'poor': 'खराब',
        'noDisease': 'कोई रोग नहीं पाया गया',
        'cropHealthy': 'आपकी फसल स्वस्थ दिखती है!',
        'wikiDescription': 'विकिपीडिया विवरण',
        'symptoms': 'लक्षण',
        'taxonomy': 'वैज्ञानिक वर्गीकरण',
        'kingdom': 'जगत',
        'phylum': 'संघ',
        'class': 'वर्ग',
        'order': 'गण',
        'family': 'कुल',
        'genus': 'वंश',
        'databaseCodes': 'डेटाबेस आईडी:',
      };
    }

    return {
      'appName': 'Kisaan Mitra',
      'reportTitle': 'Crop Health Analysis Report',
      'generatedOn': 'Generated:',
      'healthAssessment': 'Health Assessment',
      'cropType': 'Crop Type:',
      'status': 'Status:',
      'healthScore': 'Health Score:',
      'detectedDisease': 'Detected Disease',
      'match': 'match',
      'scientificName': 'Scientific Name:',
      'alsoKnownAs': 'Also Known As:',
      'classification': 'Classification:',
      'severity': 'Severity:',
      'description': 'Description',
      'cause': 'Cause of Disease',
      'spreadInfo': 'How It Spreads',
      'chemicalTreatment': 'Chemical Treatment',
      'chemicalWarning': 'Use protective gear and follow safety guidelines',
      'biologicalTreatment': 'Biological Treatment',
      'ecoFriendly': 'Eco-Friendly',
      'culturalPractices': 'Management Practices',
      'preventiveMeasures': 'Preventive Measures',
      'recommendations': 'Recommendations',
      'technicalDetails': 'Technical Details',
      'confidenceScore': 'Confidence:',
      'healthyProbability': 'Healthy Probability:',
      'analysisLocation': 'Location:',
      'analyzedOn': 'Analyzed:',
      'footerText': 'Kisaan Mitra - AI Farming Assistant',
      'page': 'Page',
      'of': 'of',
      'healthy': 'Healthy',
      'moderate': 'Moderate',
      'poor': 'Poor',
      'noDisease': 'No Disease Detected',
      'cropHealthy': 'Your crop appears healthy!',
      'wikiDescription': 'Wikipedia Description',
      'symptoms': 'Symptoms',
      'taxonomy': 'Scientific Taxonomy',
      'kingdom': 'Kingdom',
      'phylum': 'Phylum',
      'class': 'Class',
      'order': 'Order',
      'family': 'Family',
      'genus': 'Genus',
      'databaseCodes': 'Database IDs:',
    };
  }

  /// Translate result content to Hindi
  Future<CropAnalysisModel> _translateResult(CropAnalysisModel result) async {
    if (translateToHindi == null) return result;

    try {
      return CropAnalysisModel(
        cropType: await translateToHindi!(result.cropType),
        healthStatus: result.healthStatus,
        diseaseName: result.diseaseName != null
            ? await translateToHindi!(result.diseaseName!)
            : null,
        diseaseScientificName: result.diseaseScientificName,
        diseaseCommonNames: result.diseaseCommonNames,
        probability: result.probability,
        healthyProbability: result.healthyProbability,
        cause: result.cause != null
            ? await translateToHindi!(result.cause!)
            : null,
        description: result.description != null
            ? await translateToHindi!(result.description!)
            : null,
        classification: result.classification != null
            ? await translateToHindi!(result.classification!)
            : null,
        severity: result.severity != null
            ? await translateToHindi!(result.severity!)
            : null,
        spreadInfo: result.spreadInfo != null
            ? await translateToHindi!(result.spreadInfo!)
            : null,
        issues:
            await Future.wait(result.issues.map((i) => translateToHindi!(i))),
        recommendations: await Future.wait(
            result.recommendations.map((r) => translateToHindi!(r))),
        preventiveMeasures: await Future.wait(
            result.preventiveMeasures.map((p) => translateToHindi!(p))),
        chemicalTreatments: await Future.wait(
            result.chemicalTreatments.map((c) => translateToHindi!(c))),
        biologicalTreatments: await Future.wait(
            result.biologicalTreatments.map((b) => translateToHindi!(b))),
        culturalTreatments: await Future.wait(
            result.culturalTreatments.map((c) => translateToHindi!(c))),
        similarImages: result.similarImages,
        latitude: result.latitude,
        longitude: result.longitude,
        analyzedAt: result.analyzedAt,
      );
    } catch (e) {
      return result;
    }
  }

  pw.Widget _buildHeader(CropAnalysisModel result, PdfColor primaryColor,
      Map<String, String> labels) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
            bottom: pw.BorderSide(color: PdfColors.grey300, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                labels['appName']!,
                style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor),
              ),
              pw.Text(labels['reportTitle']!,
                  style: const pw.TextStyle(
                      fontSize: 12, color: PdfColors.grey700)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(labels['generatedOn']!,
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey600)),
              pw.Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(result.analyzedAt),
                style:
                    pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context, Map<String, String> labels) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 12),
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(labels['footerText']!,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          pw.Text(
            '${labels['page']!} ${context.pageNumber} ${labels['of']!} ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDiseaseBanner(
    CropAnalysisModel result,
    DiseasePreset preset,
    Map<String, PdfColor> colors,
    Map<String, String> labels,
  ) {
    final isHealthy = preset == DiseasePreset.healthy;
    final presetLabel = _getPresetLabel(preset, labels);

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: colors['background'],
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: colors['primary']!, width: 2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Preset badge
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: pw.BoxDecoration(
              color: colors['primary'],
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Text(
              presetLabel,
              style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white),
            ),
          ),
          pw.SizedBox(height: 10),

          // Disease name or healthy message
          pw.Text(
            isHealthy
                ? labels['noDisease']!
                : (result.diseaseName ?? labels['detectedDisease']!),
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: colors['primary'],
            ),
          ),

          // Scientific name and common names
          if (!isHealthy && result.diseaseScientificName != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              '${labels['scientificName']!} ${result.diseaseScientificName}',
              style: pw.TextStyle(
                  fontSize: 10,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.grey700),
            ),
          ],
          if (!isHealthy && result.diseaseCommonNames != null) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              '${labels['alsoKnownAs']!} ${result.diseaseCommonNames}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],

          // Classification and severity
          if (!isHealthy) ...[
            pw.SizedBox(height: 8),
            pw.Row(
              children: [
                if (result.classification != null) ...[
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                        '${labels['classification']!} ${result.classification}',
                        style: const pw.TextStyle(fontSize: 8)),
                  ),
                  pw.SizedBox(width: 8),
                ],
                if (result.probability != null)
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: colors['accent'],
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                        '${result.probabilityText} ${labels['match']!}',
                        style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                  ),
              ],
            ),
          ],

          if (isHealthy) ...[
            pw.SizedBox(height: 4),
            pw.Text(labels['cropHealthy']!,
                style:
                    const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildHealthStatusCard(
    CropAnalysisModel result,
    Map<String, PdfColor> colors,
    Map<String, String> labels,
  ) {
    final healthPercent = result.healthyProbability ??
        (result.healthStatus == 'Healthy'
            ? 0.9
            : result.healthStatus == 'Moderate'
                ? 0.5
                : 0.2);

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(labels['healthAssessment']!,
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text('${labels['cropType']!} ${result.cropType}',
                    style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
          pw.Container(
            width: 80,
            child: pw.Column(
              children: [
                pw.Text('${(healthPercent * 100).toInt()}%',
                    style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: colors['primary'])),
                pw.Text(labels['healthScore']!,
                    style: const pw.TextStyle(
                        fontSize: 8, color: PdfColors.grey600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDetailSection(String title, String content, PdfColor color,
      {String? linkUrl}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border(left: pw.BorderSide(color: color, width: 3)),
        color: PdfColors.grey50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(
                  fontSize: 11, fontWeight: pw.FontWeight.bold, color: color)),
          pw.SizedBox(height: 4),
          pw.Text(content, style: const pw.TextStyle(fontSize: 10)),
          if (linkUrl != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(linkUrl,
                style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColor.fromHex('#1976D2'),
                    decoration: pw.TextDecoration.underline)),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildTaxonomySection(
      CropAnalysisModel result, Map<String, String> labels) {
    final taxonomyItems = <Map<String, String>>[];

    if (result.taxonomyKingdom != null) {
      taxonomyItems.add({
        'label': labels['kingdom'] ?? 'Kingdom',
        'value': result.taxonomyKingdom!
      });
    }
    if (result.taxonomyPhylum != null) {
      taxonomyItems.add({
        'label': labels['phylum'] ?? 'Phylum',
        'value': result.taxonomyPhylum!
      });
    }
    if (result.taxonomyClass != null) {
      taxonomyItems.add({
        'label': labels['class'] ?? 'Class',
        'value': result.taxonomyClass!
      });
    }
    if (result.taxonomyOrder != null) {
      taxonomyItems.add({
        'label': labels['order'] ?? 'Order',
        'value': result.taxonomyOrder!
      });
    }
    if (result.taxonomyFamily != null) {
      taxonomyItems.add({
        'label': labels['family'] ?? 'Family',
        'value': result.taxonomyFamily!
      });
    }
    if (result.taxonomyGenus != null) {
      taxonomyItems.add({
        'label': labels['genus'] ?? 'Genus',
        'value': result.taxonomyGenus!
      });
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#4CAF50')),
        borderRadius: pw.BorderRadius.circular(6),
        color: PdfColor.fromHex('#E8F5E9'),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(labels['taxonomy'] ?? 'Scientific Taxonomy',
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#2E7D32'))),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 8,
            runSpacing: 4,
            children: taxonomyItems
                .map((item) => pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(4),
                        border:
                            pw.Border.all(color: PdfColor.fromHex('#81C784')),
                      ),
                      child: pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(
                              text: '${item['label']}: ',
                              style: pw.TextStyle(
                                  fontSize: 8,
                                  color: PdfColor.fromHex('#558B2F')),
                            ),
                            pw.TextSpan(
                              text: item['value'],
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                fontStyle: pw.FontStyle.italic,
                                color: PdfColor.fromHex('#33691E'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDatabaseCodesSection(
      CropAnalysisModel result, Map<String, String> labels) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        children: [
          pw.Text(labels['databaseCodes'] ?? 'Database IDs:',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.SizedBox(width: 8),
          if (result.eppoCode != null) ...[
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#E3F2FD'),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text('EPPO: ${result.eppoCode}',
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(width: 6),
          ],
          if (result.gbifId != null) ...[
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FFF3E0'),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text('GBIF: ${result.gbifId}',
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildTreatmentCard(
    String title,
    List<String> items,
    PdfColor color, {
    String? warning,
    String? badge,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 1),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(title,
                  style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: color)),
              if (badge != null) ...[
                pw.SizedBox(width: 8),
                pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(badge,
                      style: const pw.TextStyle(
                          fontSize: 8, color: PdfColors.green800)),
                ),
              ],
            ],
          ),
          if (warning != null) ...[
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FFF3E0'),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(warning,
                  style: const pw.TextStyle(
                      fontSize: 8, color: PdfColors.orange900)),
            ),
          ],
          pw.SizedBox(height: 8),
          ...items.map((item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 5,
                      height: 5,
                      margin: const pw.EdgeInsets.only(top: 3, right: 6),
                      decoration: pw.BoxDecoration(
                          color: color, shape: pw.BoxShape.circle),
                    ),
                    pw.Expanded(
                        child: pw.Text(item,
                            style: const pw.TextStyle(fontSize: 9))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  pw.Widget _buildListSection(
      String title, List<String> items, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(
                  fontSize: 11, fontWeight: pw.FontWeight.bold, color: color)),
          pw.SizedBox(height: 6),
          ...items.map((item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 3),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 4,
                      height: 4,
                      margin: const pw.EdgeInsets.only(top: 4, right: 6),
                      decoration: pw.BoxDecoration(
                          color: color, shape: pw.BoxShape.circle),
                    ),
                    pw.Expanded(
                        child: pw.Text(item,
                            style: const pw.TextStyle(fontSize: 9))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  pw.Widget _buildTechnicalDetailsCard(
      CropAnalysisModel result, Map<String, String> labels) {
    final details = <String>[];

    if (result.probability != null) {
      details.add('${labels['confidenceScore']!} ${result.probabilityText}');
    }
    if (result.healthyProbability != null) {
      details.add(
          '${labels['healthyProbability']!} ${(result.healthyProbability! * 100).toStringAsFixed(1)}%');
    }
    if (result.latitude != null && result.longitude != null) {
      details.add(
          '${labels['analysisLocation']!} ${result.latitude!.toStringAsFixed(4)}, ${result.longitude!.toStringAsFixed(4)}');
    }
    details.add(
        '${labels['analyzedOn']!} ${DateFormat('dd/MM/yyyy HH:mm').format(result.analyzedAt)}');

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey50,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(labels['technicalDetails']!,
              style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey700)),
          pw.SizedBox(height: 6),
          pw.Wrap(
            spacing: 16,
            runSpacing: 4,
            children: details
                .map((d) => pw.Text(d,
                    style: const pw.TextStyle(
                        fontSize: 8, color: PdfColors.blueGrey600)))
                .toList(),
          ),
        ],
      ),
    );
  }
}
