import 'package:flutter/material.dart';

class IrrigationRecommendationCard extends StatelessWidget {
  final Map<String, dynamic> recommendations;
  final String cropType;

  const IrrigationRecommendationCard({
    Key? key,
    required this.recommendations,
    required this.cropType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendations for $cropType',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Water Requirements
            _buildRecommendationRow(
              context,
              Icons.water_drop,
              'Water Amount',
              recommendations['waterAmount'],
              Colors.blue,
            ),
            const SizedBox(height: 12),

            // Watering Frequency
            _buildRecommendationRow(
              context,
              Icons.calendar_today,
              'Frequency',
              recommendations['frequency'],
              Colors.green,
            ),
            const SizedBox(height: 12),

            // Best Time
            _buildRecommendationRow(
              context,
              Icons.access_time,
              'Best Time',
              recommendations['bestTime'],
              Colors.orange,
            ),
            const SizedBox(height: 12),

            // Fertilizer
            _buildRecommendationRow(
              context,
              Icons.grass,
              'Fertilizer',
              recommendations['fertilizer'],
              Colors.brown,
            ),

            const Divider(height: 24),

            // Tips
            const Text(
              'Tips:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (recommendations['tips'] as List<String>).map((tip) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(tip),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationRow(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      Color color,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
