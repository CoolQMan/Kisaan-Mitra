import 'package:flutter/material.dart';
import 'package:kisaan_mitra/models/crop_analysis_model.dart';
import 'package:kisaan_mitra/widgets/crop_analysis/analysis_card.dart';
import 'package:intl/intl.dart';

class AnalysisResultScreen extends StatelessWidget {
  final CropAnalysisModel analysis;

  const AnalysisResultScreen({
    Key? key,
    required this.analysis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              '${analysis.cropType} Health Analysis',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyzed on ${DateFormat('MMM d, yyyy').format(analysis.analyzedAt)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Health Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getHealthStatusColor(analysis.healthStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getHealthStatusColor(analysis.healthStatus),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getHealthStatusIcon(analysis.healthStatus),
                    color: _getHealthStatusColor(analysis.healthStatus),
                    size: 36,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Health Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          analysis.healthStatus,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _getHealthStatusColor(analysis.healthStatus),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Issues
            const Text(
              'Issues Identified',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            AnalysisCard(
              icon: Icons.bug_report,
              color: Colors.red,
              items: analysis.issues,
            ),
            const SizedBox(height: 24),

            // Recommendations
            const Text(
              'Treatment Recommendations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            AnalysisCard(
              icon: Icons.healing,
              color: Colors.blue,
              items: analysis.recommendations,
            ),
            const SizedBox(height: 24),

            // Preventive Measures
            const Text(
              'Preventive Measures',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            AnalysisCard(
              icon: Icons.shield,
              color: Colors.green,
              items: analysis.preventiveMeasures,
            ),
            const SizedBox(height: 24),

            // Save Report Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement save report functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report saved successfully')),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Save Report'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Share Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing report...')),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Share Report'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHealthStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getHealthStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return Icons.check_circle;
      case 'moderate':
        return Icons.warning;
      case 'poor':
        return Icons.error;
      default:
        return Icons.help;
    }
  }
}
