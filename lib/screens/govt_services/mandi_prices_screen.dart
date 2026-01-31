import 'package:flutter/material.dart';
import 'package:kisaan_mitra/models/govt_services_models.dart';
import 'package:kisaan_mitra/services/govt_services_service.dart';
import 'package:kisaan_mitra/services/localization_service.dart';
import 'package:kisaan_mitra/widgets/common/language_toggle.dart';

/// Mandi Prices Screen - Real-time market rates from data.gov.in
class MandiPricesScreen extends StatefulWidget {
  const MandiPricesScreen({super.key});

  @override
  State<MandiPricesScreen> createState() => _MandiPricesScreenState();
}

class _MandiPricesScreenState extends State<MandiPricesScreen> {
  final GovtServicesService _service = GovtServicesService();
  String _selectedState = 'Maharashtra';
  String _selectedCommodity = 'Wheat';
  List<MandiPrice> _prices = [];
  bool _isLoading = false;
  String? _error;

  final List<String> _states = [
    'Maharashtra',
    'Madhya Pradesh',
    'Uttar Pradesh',
    'Rajasthan',
    'Punjab',
    'Haryana',
    'Gujarat',
    'Karnataka',
    'Tamil Nadu',
    'Andhra Pradesh',
    'Bihar',
    'West Bengal',
    'Telangana',
  ];

  final List<String> _commodities = [
    'Wheat',
    'Rice',
    'Maize',
    'Bajra',
    'Jowar',
    'Groundnut',
    'Soyabean',
    'Cotton',
    'Sugarcane',
    'Mustard',
    'Potato',
    'Onion',
    'Tomato',
    'Chana',
    'Tur',
    'Urad',
    'Moong',
    'Masoor',
  ];

  @override
  void initState() {
    super.initState();
    loc.addListener(_onLanguageChange);
  }

  @override
  void dispose() {
    loc.removeListener(_onLanguageChange);
    super.dispose();
  }

  void _onLanguageChange() {
    setState(() {});
  }

  Future<void> _fetchPrices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prices = await _service.getMandiPrices(
        state: _selectedState,
        commodity: _selectedCommodity,
      );
      setState(() {
        _prices = prices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.mandiPrices),
        actions: const [LanguageToggle()],
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade600, Colors.orange.shade800],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.realTimeMandiPrices,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  loc.dataFromGovt,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedState,
                  decoration: InputDecoration(
                    labelText: loc.selectState,
                    prefixIcon: const Icon(Icons.location_on),
                    border: const OutlineInputBorder(),
                  ),
                  items: _states
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedState = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCommodity,
                  decoration: InputDecoration(
                    labelText: loc.selectCommodity,
                    prefixIcon: const Icon(Icons.grass),
                    border: const OutlineInputBorder(),
                  ),
                  items: _commodities
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCommodity = v!),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _fetchPrices,
                    icon: const Icon(Icons.search),
                    label: Text(loc.searchPrices),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(loc.loading),
        ],
      ));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(loc.error,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: _fetchPrices,
              child: Text(loc.retry),
            ),
          ],
        ),
      );
    }

    if (_prices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              loc.isHindi
                  ? 'राज्य और वस्तु चुनें और खोजें दबाएं'
                  : 'Select state and commodity, then tap Search',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // Find best price
    final bestPrice = _prices.reduce((a, b) => a.maxPrice > b.maxPrice ? a : b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Best price highlight
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.bestPrice,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '₹${bestPrice.maxPrice.toStringAsFixed(0)}/${loc.isHindi ? 'क्विंटल' : 'quintal'}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${bestPrice.market}, ${bestPrice.district}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // All prices list
        ..._prices.map((price) => _buildPriceCard(price)),
      ],
    );
  }

  Widget _buildPriceCard(MandiPrice price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        price.market,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${price.district}, ${price.state}',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${price.arrivalDate.day}/${price.arrivalDate.month}/${price.arrivalDate.year}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPriceChip(loc.minPrice, price.minPrice, Colors.orange),
                const SizedBox(width: 8),
                _buildPriceChip(loc.modalPrice, price.modalPrice, Colors.blue),
                const SizedBox(width: 8),
                _buildPriceChip(loc.maxPrice, price.maxPrice, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceChip(String label, double price, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: color)),
            Text(
              '₹${price.toStringAsFixed(0)}',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
