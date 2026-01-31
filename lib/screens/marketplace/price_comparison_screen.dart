import 'package:flutter/material.dart';
import 'package:kisaan_mitra/models/marketplace_models.dart';
import 'package:kisaan_mitra/services/price_intelligence_service.dart';

/// Screen for comparing MSP vs Market prices
class PriceComparisonScreen extends StatefulWidget {
  const PriceComparisonScreen({super.key});

  @override
  State<PriceComparisonScreen> createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  final PriceIntelligenceService _priceService = PriceIntelligenceService();
  String _selectedSeason = 'All';

  @override
  Widget build(BuildContext context) {
    final marketTrends = _priceService.getAllMarketTrends();
    final mspPrices = _priceService.getAllMspPrices();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Comparison'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildSeasonChip('All'),
                const SizedBox(width: 8),
                _buildSeasonChip('Kharif'),
                const SizedBox(width: 8),
                _buildSeasonChip('Rabi'),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummaryCards(marketTrends),
            const SizedBox(height: 20),

            // MSP vs Market Comparison Table
            const Text(
              'MSP vs Market Prices',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Government MSP vs Current Market Rate',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ...marketTrends.map((trend) => _buildComparisonCard(trend)),

            const SizedBox(height: 24),

            // MSP Reference Table
            const Text(
              'Official MSP 2024-25',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Source: Government of India',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            _buildMspTable(mspPrices),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonChip(String season) {
    final isSelected = _selectedSeason == season;
    return FilterChip(
      label: Text(season),
      selected: isSelected,
      onSelected: (selected) => setState(() => _selectedSeason = season),
      selectedColor: Colors.green.shade100,
      checkmarkColor: Colors.green.shade700,
    );
  }

  Widget _buildSummaryCards(List<MarketTrendModel> trends) {
    final aboveMsp =
        trends.where((t) => t.isAboveMsp && t.mspPricePerKg > 0).length;
    final belowMsp =
        trends.where((t) => !t.isAboveMsp && t.mspPricePerKg > 0).length;
    final trendingUp = trends.where((t) => t.trend == PriceTrend.up).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Above MSP',
            '$aboveMsp crops',
            Colors.green,
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Below MSP',
            '$belowMsp crops',
            Colors.red,
            Icons.trending_down,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Trending Up',
            '$trendingUp crops',
            Colors.blue,
            Icons.show_chart,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(MarketTrendModel trend) {
    final hasMsp = trend.mspPricePerKg > 0;
    final diffPercent = trend.mspDifferencePercent;
    final isAbove = trend.isAboveMsp;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop Name and Trend Badge
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trend.cropName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        trend.hindiName,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _buildTrendBadge(trend.trend, trend.priceChange7d),
              ],
            ),
            const SizedBox(height: 16),

            // Price Comparison Bar
            Row(
              children: [
                // MSP Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MSP',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasMsp
                            ? '₹${trend.mspPricePerKg.toStringAsFixed(1)}/kg'
                            : 'N/A',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: hasMsp ? Colors.blue.shade700 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow and difference
                if (hasMsp) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          isAbove ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isAbove ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isAbove ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        Text(
                          '${diffPercent.abs().toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isAbove ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(width: 16),
                // Market Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Market',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${trend.currentPrice.toStringAsFixed(1)}/kg',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Supply/Demand Indicators
            Row(
              children: [
                _buildIndicatorChip('Demand', trend.demandLevel),
                const SizedBox(width: 8),
                _buildIndicatorChip('Supply', trend.supplyLevel),
                const Spacer(),
                Text(
                  trend.market,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendBadge(PriceTrend trend, double change) {
    final color = trend == PriceTrend.up
        ? Colors.green
        : trend == PriceTrend.down
            ? Colors.red
            : Colors.grey;
    final icon = trend == PriceTrend.up
        ? Icons.trending_up
        : trend == PriceTrend.down
            ? Icons.trending_down
            : Icons.trending_flat;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorChip(String label, String level) {
    final color = level == 'High'
        ? Colors.green
        : level == 'Low'
            ? Colors.red
            : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $level',
        style:
            TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildMspTable(List<MspPriceModel> mspPrices) {
    final filteredPrices = _selectedSeason == 'All'
        ? mspPrices
        : mspPrices.where((m) => m.season == _selectedSeason).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1.5),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade100),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Crop',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Season',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('MSP (₹/q)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ...filteredPrices.map((msp) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(msp.cropName,
                              style: const TextStyle(fontSize: 13)),
                          Text(msp.hindiName,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: msp.season == 'Kharif'
                              ? Colors.green.shade50
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          msp.season,
                          style: TextStyle(
                            fontSize: 11,
                            color: msp.season == 'Kharif'
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '₹${msp.mspPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
