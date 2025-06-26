import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MarketPricesScreen extends StatelessWidget {
  const MarketPricesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
    );

    // Mock data for government crop prices
    final crops = [
      {'name': 'Wheat', 'price': 22.50, 'trend': 'up', 'change': 2.5},
      {'name': 'Rice', 'price': 35.00, 'trend': 'stable', 'change': 0.0},
      {'name': 'Cotton', 'price': 65.00, 'trend': 'down', 'change': 1.2},
      {'name': 'Sugarcane', 'price': 3.50, 'trend': 'up', 'change': 0.5},
      {'name': 'Maize', 'price': 18.75, 'trend': 'up', 'change': 1.8},
      {'name': 'Soybean', 'price': 42.30, 'trend': 'down', 'change': 0.7},
      {'name': 'Potato', 'price': 15.20, 'trend': 'stable', 'change': 0.1},
      {'name': 'Tomato', 'price': 25.80, 'trend': 'up', 'change': 3.2},
      {'name': 'Onion', 'price': 28.50, 'trend': 'down', 'change': 2.1},
      {'name': 'Pulses', 'price': 55.25, 'trend': 'stable', 'change': 0.3},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Market Prices'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Official Crop Prices',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Source: Agricultural Price Commission',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last updated: ${DateFormat('MMM d, yyyy').format(DateTime.now())}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: crops.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final crop = crops[index];
                return ListTile(
                  title: Text(
                    crop['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('Per kilogram'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currencyFormat.format(crop['price']),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildTrendIcon(crop['trend'] as String, crop['change'] as double),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIcon(String trend, double change) {
    IconData icon;
    Color color;

    switch (trend) {
      case 'up':
        icon = Icons.trending_up;
        color = Colors.green;
        break;
      case 'down':
        icon = Icons.trending_down;
        color = Colors.red;
        break;
      default:
        icon = Icons.trending_flat;
        color = Colors.blue;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 2),
        Text(
          '${change.toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
