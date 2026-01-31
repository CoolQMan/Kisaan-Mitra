import 'package:flutter/material.dart';
import 'package:kisaan_mitra/models/crop_analysis_model.dart';
import 'package:kisaan_mitra/services/pdf_report_service.dart'
    hide DiseasePreset;
import 'package:kisaan_mitra/utils/disease_theme_helper.dart';
import 'package:open_file/open_file.dart';

class AnalysisResultScreen extends StatefulWidget {
  final CropAnalysisModel result;

  const AnalysisResultScreen({Key? key, required this.result})
      : super(key: key);

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  final PdfReportService _pdfService = PdfReportService();
  bool _isSaving = false;

  CropAnalysisModel get result => widget.result;

  // Disease theming based on classification
  late final DiseasePreset _diseasePreset =
      DiseaseThemeHelper.getPreset(result);
  late final DiseaseThemeData _theme =
      DiseaseThemeHelper.getThemeData(_diseasePreset);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _shareReport(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Disease Detection Header
            if (result.hasDisease) _buildDiseaseHeader(context),
            if (!result.hasDisease) _buildHealthyHeader(context),
            const SizedBox(height: 16),

            // Health Status Card
            _buildHealthStatusCard(context),
            const SizedBox(height: 16),

            // Wiki Description (if available)
            if (result.wikiDescription != null &&
                result.wikiDescription!.isNotEmpty) ...[
              _buildDetailCard(
                context,
                title: 'Description',
                content: result.wikiDescription!,
                icon: Icons.info_outline,
                iconColor: Colors.blue,
                linkUrl: result.wikiUrl,
                linkText: 'Read more on Wikipedia',
              ),
              const SizedBox(height: 16),
            ],

            // Symptoms (if available)
            if (result.symptoms != null && result.symptoms!.isNotEmpty) ...[
              _buildDetailCard(
                context,
                title: 'Symptoms',
                content: result.symptoms!,
                icon: Icons.medical_information,
                iconColor: Colors.orange,
              ),
              const SizedBox(height: 16),
            ],

            // Taxonomy (if available)
            if (result.hasTaxonomy) ...[
              _buildTaxonomyCard(context),
              const SizedBox(height: 16),
            ],

            // Common names (if available and not shown in header)
            if (result.diseaseCommonNames != null &&
                result.diseaseCommonNames!.isNotEmpty) ...[
              _buildDetailCard(
                context,
                title: 'Also Known As',
                content: result.diseaseCommonNames!,
                icon: Icons.label_outline,
                iconColor: Colors.grey,
              ),
              const SizedBox(height: 16),
            ],

            // How it spreads (if available)
            if (result.spreadInfo != null && result.spreadInfo!.isNotEmpty) ...[
              _buildDetailCard(
                context,
                title: 'How It Spreads',
                content: result.spreadInfo!,
                icon: Icons.share,
                iconColor: Colors.red,
              ),
              const SizedBox(height: 16),
            ],

            // Cause Section (if disease detected)
            if (result.cause != null && result.cause!.isNotEmpty) ...[
              _buildCauseSection(context),
              const SizedBox(height: 16),
            ],

            // Issues Section
            if (result.issues.isNotEmpty) ...[
              _buildSectionCard(
                context,
                title: 'Identified Issues',
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.orange,
                items: result.issues,
              ),
              const SizedBox(height: 16),
            ],

            // Chemical Treatments (with warning)
            if (result.chemicalTreatments.isNotEmpty) ...[
              _buildTreatmentSection(
                context,
                title: 'Chemical Treatment',
                icon: Icons.science,
                iconColor: Colors.purple,
                items: result.chemicalTreatments,
                warning: 'Use protective gear and follow safety guidelines',
                warningColor: Colors.red.shade50,
              ),
              const SizedBox(height: 16),
            ],

            // Biological Treatments (eco-friendly)
            if (result.biologicalTreatments.isNotEmpty) ...[
              _buildTreatmentSection(
                context,
                title: 'Biological Treatment',
                icon: Icons.eco,
                iconColor: Colors.green,
                items: result.biologicalTreatments,
                badge: '🌿 Eco-friendly',
                badgeColor: Colors.green.shade50,
              ),
              const SizedBox(height: 16),
            ],

            // General Recommendations (if no specific treatments)
            if (result.chemicalTreatments.isEmpty &&
                result.biologicalTreatments.isEmpty &&
                result.recommendations.isNotEmpty) ...[
              _buildSectionCard(
                context,
                title: 'Recommendations',
                icon: Icons.recommend,
                iconColor: Colors.blue,
                items: result.recommendations,
              ),
              const SizedBox(height: 16),
            ],

            // Preventive Measures
            if (result.preventiveMeasures.isNotEmpty) ...[
              _buildSectionCard(
                context,
                title: 'Preventive Measures',
                icon: Icons.shield_outlined,
                iconColor: Colors.teal,
                items: result.preventiveMeasures,
              ),
              const SizedBox(height: 16),
            ],

            // Similar Images Section
            if (result.similarImages.isNotEmpty) ...[
              _buildSimilarImagesSection(context),
              const SizedBox(height: 16),
            ],

            // Analysis Info Footer
            _buildAnalysisInfoFooter(context),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Analyze Another'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : () => _saveReport(context),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? 'Saving...' : 'Save Report'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _theme.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Disease type badge and match percentage
          Row(
            children: [
              // Disease type badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_theme.icon, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _theme.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (result.probability != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${result.probabilityText} match',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Disease name
          Text(
            result.diseaseName ?? 'Unknown Disease',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Scientific name (if available)
          if (result.diseaseScientificName != null) ...[
            const SizedBox(height: 4),
            Text(
              result.diseaseScientificName!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // Classification and EPPO code
          if (result.classification != null || result.eppoCode != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (result.classification != null)
                  _buildInfoChip(result.classification!, Icons.category),
                if (result.eppoCode != null)
                  _buildInfoChip('EPPO: ${result.eppoCode}', Icons.code),
                if (result.severity != null)
                  _buildInfoChip('Severity: ${result.severity}', Icons.warning),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthyHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.teal.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.check_circle, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Healthy Crop!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'No diseases or pests detected',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatusCard(BuildContext context) {
    // Calculate health percentage for visual indicator
    double healthPercent = 0.5;
    Color statusColor = Colors.yellow;

    switch (result.healthStatus) {
      case 'Healthy':
        healthPercent = 0.9;
        statusColor = Colors.green;
        break;
      case 'Moderate':
        healthPercent = 0.5;
        statusColor = Colors.orange;
        break;
      case 'Poor':
        healthPercent = 0.2;
        statusColor = Colors.red;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Health Assessment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Crop Type: '),
                Text(
                  result.cropType,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Status: '),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    result.healthStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: healthPercent,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Health Score: ${(healthPercent * 100).toInt()}%',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCauseSection(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cause',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.cause!,
                    style: TextStyle(color: Colors.blue.shade900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
    String? linkUrl,
    String? linkText,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            if (linkUrl != null && linkText != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _launchUrl(linkUrl),
                child: Text(
                  linkText,
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    decoration: TextDecoration.underline,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaxonomyCard(BuildContext context) {
    final taxonomyItems = <Map<String, String>>[];

    if (result.taxonomyKingdom != null) {
      taxonomyItems.add({'label': 'Kingdom', 'value': result.taxonomyKingdom!});
    }
    if (result.taxonomyPhylum != null) {
      taxonomyItems.add({'label': 'Phylum', 'value': result.taxonomyPhylum!});
    }
    if (result.taxonomyClass != null) {
      taxonomyItems.add({'label': 'Class', 'value': result.taxonomyClass!});
    }
    if (result.taxonomyOrder != null) {
      taxonomyItems.add({'label': 'Order', 'value': result.taxonomyOrder!});
    }
    if (result.taxonomyFamily != null) {
      taxonomyItems.add({'label': 'Family', 'value': result.taxonomyFamily!});
    }
    if (result.taxonomyGenus != null) {
      taxonomyItems.add({'label': 'Genus', 'value': result.taxonomyGenus!});
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_tree,
                    color: Colors.green.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Scientific Taxonomy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: taxonomyItems
                  .map((item) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${item['label']}: ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: item['value'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
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
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      // Use Flutter's url_launcher or just show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening: $url'),
          action: SnackBarAction(
            label: 'Copy',
            onPressed: () {
              // Could add clipboard functionality here
            },
          ),
        ),
      );
    } catch (e) {
      // Handle error
    }
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(item)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
    String? warning,
    Color? warningColor,
    String? badge,
    Color? badgeColor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor ?? Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
              ],
            ),
            if (warning != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: warningColor ?? Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber,
                        size: 18, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: iconColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarImagesSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.photo_library, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Similar Cases',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Reference images of similar disease cases',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: result.similarImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () =>
                        _openImage(context, result.similarImages[index]),
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          result.similarImages[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(Icons.broken_image,
                                color: Colors.grey.shade400),
                          ),
                          loadingBuilder: (_, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisInfoFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            'Analyzed on ${_formatDate(result.analyzedAt)}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _openImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Similar Case'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Padding(
                padding: EdgeInsets.all(32),
                child: Icon(Icons.broken_image, size: 64),
              ),
              loadingBuilder: (_, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveReport(BuildContext context) async {
    if (_isSaving) return;

    // Show language selection dialog
    final language = await showDialog<ReportLanguage>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Report Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              subtitle: const Text('Generate report in English'),
              onTap: () => Navigator.pop(ctx, ReportLanguage.english),
            ),
            const Divider(),
            ListTile(
              leading: const Text('🇮🇳', style: TextStyle(fontSize: 24)),
              title: const Text('हिंदी (Hindi)'),
              subtitle: const Text('हिंदी में रिपोर्ट बनाएं'),
              onTap: () => Navigator.pop(ctx, ReportLanguage.hindi),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (language == null) return; // User cancelled

    setState(() {
      _isSaving = true;
    });

    try {
      final filePath = await _pdfService.generateCropAnalysisReport(
        result,
        language: language,
      );

      setState(() {
        _isSaving = false;
      });

      if (!mounted) return;

      // Show success dialog with file path
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(language == ReportLanguage.hindi
                  ? 'रिपोर्ट सहेजी गई!'
                  : 'Report Saved!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(language == ReportLanguage.hindi
                  ? 'आपकी फसल स्वास्थ्य रिपोर्ट PDF के रूप में सहेजी गई है।'
                  : 'Your crop health report has been saved as a PDF.'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        filePath.split('/').last,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  Text(language == ReportLanguage.hindi ? 'बंद करें' : 'Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                OpenFile.open(filePath);
              },
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text(
                  language == ReportLanguage.hindi ? 'PDF खोलें' : 'Open PDF'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save report: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _shareReport(BuildContext context) {
    // Build share text
    final shareText = StringBuffer()
      ..writeln('🌾 Crop Health Analysis Report')
      ..writeln('━━━━━━━━━━━━━━━━━━━━━━')
      ..writeln('Crop: ${result.cropType}')
      ..writeln('Status: ${result.healthStatus}');

    if (result.diseaseName != null) {
      shareText.writeln('Disease: ${result.diseaseName}');
      if (result.probability != null) {
        shareText.writeln('Confidence: ${result.probabilityText}');
      }
    }

    if (result.cause != null) {
      shareText.writeln('\n📋 Cause:');
      shareText.writeln(result.cause);
    }

    if (result.chemicalTreatments.isNotEmpty) {
      shareText.writeln('\n💊 Chemical Treatment:');
      for (var t in result.chemicalTreatments) {
        shareText.writeln('• $t');
      }
    }

    if (result.biologicalTreatments.isNotEmpty) {
      shareText.writeln('\n🌿 Biological Treatment:');
      for (var t in result.biologicalTreatments) {
        shareText.writeln('• $t');
      }
    }

    if (result.preventiveMeasures.isNotEmpty) {
      shareText.writeln('\n🛡️ Prevention:');
      for (var m in result.preventiveMeasures) {
        shareText.writeln('• $m');
      }
    }

    shareText.writeln('\n━━━━━━━━━━━━━━━━━━━━━━');
    shareText.writeln('Generated by Kisaan Mitra');

    // Show share dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Share Report'),
        content: SingleChildScrollView(
          child: Text(shareText.toString()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Implement actual sharing using share_plus package
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report copied to clipboard')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
        ],
      ),
    );
  }
}
