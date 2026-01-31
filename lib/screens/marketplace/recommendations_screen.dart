import 'package:flutter/material.dart';
import 'package:kisaan_mitra/models/marketplace_models.dart';
import 'package:kisaan_mitra/services/recommendation_service.dart';

/// Screen for AI-powered crop recommendations and alerts
class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen>
    with SingleTickerProviderStateMixin {
  final RecommendationService _recommendationService = RecommendationService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alerts = _recommendationService.getCriticalAlerts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recommendations'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.agriculture), text: 'Sow'),
            Tab(icon: Icon(Icons.sell), text: 'Sell'),
            Tab(icon: Icon(Icons.warning_amber), text: 'Alerts'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Critical Alert Banner
          if (alerts.isNotEmpty) _buildAlertBanner(alerts.first),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSowTab(),
                _buildSellTab(),
                _buildAlertsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(LocalStockAlertModel alert) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ ${alert.cropName} Overstock Alert',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                Text(
                  alert.message,
                  style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SOW TAB ====================
  Widget _buildSowTab() {
    final sowRecommendations = _recommendationService.getSowRecommendations();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '🌱 What to Sow This Season',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text(
          'AI-powered recommendations based on market trends',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Recommended crops
        ...sowRecommendations.where((r) => r.action == CropAction.sow).map(
              (rec) => _buildRecommendationCard(rec, isSow: true),
            ),

        const SizedBox(height: 24),
        const Text(
          '⚠️ Crops to Avoid',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Crops to avoid
        ...sowRecommendations.where((r) => r.action == CropAction.avoid).map(
              (rec) => _buildRecommendationCard(rec, isSow: true),
            ),
      ],
    );
  }

  // ==================== SELL TAB ====================
  Widget _buildSellTab() {
    final sellNow = _recommendationService.getSellNowRecommendations();
    final hold = _recommendationService.getHoldRecommendations();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '💰 Sell Now',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Crops with optimal selling conditions',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ...sellNow.map((rec) => _buildRecommendationCard(rec, isSow: false)),
        const SizedBox(height: 24),
        const Text(
          '⏳ Hold for Better Price',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...hold.map((rec) => _buildRecommendationCard(rec, isSow: false)),
      ],
    );
  }

  // ==================== ALERTS TAB ====================
  Widget _buildAlertsTab() {
    final alerts = _recommendationService.getOverstockAlerts();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '📊 Local Overstock Alerts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Crops with high supply in your region',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ...alerts.map((alert) => _buildAlertCard(alert)),
      ],
    );
  }

  Widget _buildRecommendationCard(CropRecommendationModel rec,
      {required bool isSow}) {
    final actionColor = _getActionColor(rec.action);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: actionColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: actionColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getActionIcon(rec.action),
                          color: actionColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rec.action.displayName,
                        style: TextStyle(
                          color: actionColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Confidence badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(rec.confidence * 100).toInt()}% confidence',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Crop Name
            Text(
              rec.cropName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              rec.hindiName,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),

            // Reason
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: Colors.blue.shade600, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec.reason,
                      style:
                          TextStyle(color: Colors.blue.shade700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Stats Row
            Row(
              children: [
                _buildStatChip(
                  Icons.trending_up,
                  '${rec.predictedPriceChange >= 0 ? '+' : ''}${rec.predictedPriceChange.toStringAsFixed(0)}%',
                  'Price Forecast',
                  rec.predictedPriceChange >= 0 ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                if (isSow)
                  _buildStatChip(
                    Icons.currency_rupee,
                    '₹${(rec.expectedReturn / 1000).toStringAsFixed(0)}K',
                    'Expected/acre',
                    Colors.purple,
                  )
                else
                  _buildStatChip(
                    Icons.schedule,
                    rec.optimalTimingDays == 0
                        ? 'Now'
                        : '${rec.optimalTimingDays} days',
                    'Optimal Time',
                    Colors.orange,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 10, color: color.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(LocalStockAlertModel alert) {
    final severityColor = _getSeverityColor(alert.severity);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(_getSeverityIcon(alert.severity),
                          color: severityColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        alert.severity.name.toUpperCase(),
                        style: TextStyle(
                          color: severityColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  alert.region,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Crop and Stock Level
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.cropName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(alert.hindiName,
                          style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '+${alert.stockLevel.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: severityColor,
                        ),
                      ),
                      const Text('Overstock', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Message
            Text(alert.message),
            const SizedBox(height: 12),

            // Recommendation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.tips_and_updates,
                      color: Colors.green.shade600, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert.recommendation,
                      style:
                          TextStyle(color: Colors.green.shade700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // Alternative Crops
            if (alert.alternativeCrops.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  const Text('Alternatives:',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ...alert.alternativeCrops.map((crop) => Chip(
                        label: Text(crop, style: const TextStyle(fontSize: 11)),
                        backgroundColor: Colors.blue.shade50,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getActionColor(CropAction action) {
    switch (action) {
      case CropAction.sow:
        return Colors.green;
      case CropAction.sell:
        return Colors.blue;
      case CropAction.hold:
        return Colors.orange;
      case CropAction.avoid:
        return Colors.red;
    }
  }

  IconData _getActionIcon(CropAction action) {
    switch (action) {
      case CropAction.sow:
        return Icons.agriculture;
      case CropAction.sell:
        return Icons.sell;
      case CropAction.hold:
        return Icons.pause_circle_outline;
      case CropAction.avoid:
        return Icons.do_not_disturb;
    }
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Colors.red;
      case AlertSeverity.warning:
        return Colors.orange;
      case AlertSeverity.info:
        return Colors.blue;
    }
  }

  IconData _getSeverityIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Icons.error;
      case AlertSeverity.warning:
        return Icons.warning;
      case AlertSeverity.info:
        return Icons.info;
    }
  }
}
