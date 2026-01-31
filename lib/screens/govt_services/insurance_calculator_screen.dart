import 'package:flutter/material.dart';
import 'package:kisaan_mitra/services/govt_services_service.dart';
import 'package:kisaan_mitra/services/localization_service.dart';
import 'package:kisaan_mitra/widgets/common/language_toggle.dart';
import 'package:url_launcher/url_launcher.dart';

/// PMFBY Insurance Calculator Screen
class InsuranceCalculatorScreen extends StatefulWidget {
  const InsuranceCalculatorScreen({super.key});

  @override
  State<InsuranceCalculatorScreen> createState() =>
      _InsuranceCalculatorScreenState();
}

class _InsuranceCalculatorScreenState extends State<InsuranceCalculatorScreen> {
  final GovtServicesService _service = GovtServicesService();
  final TextEditingController _sumInsuredController =
      TextEditingController(text: '100000');

  String _selectedSeason = 'Kharif';
  String _selectedCrop = 'Rice';
  bool _showResult = false;

  final List<String> _seasons = ['Kharif', 'Rabi', 'Commercial'];
  final List<String> _crops = [
    'Rice',
    'Wheat',
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
  ];

  @override
  void initState() {
    super.initState();
    loc.addListener(_onLanguageChange);
  }

  @override
  void dispose() {
    _sumInsuredController.dispose();
    loc.removeListener(_onLanguageChange);
    super.dispose();
  }

  void _onLanguageChange() {
    setState(() {});
  }

  void _calculate() {
    setState(() => _showResult = true);
  }

  String _getSeasonLabel(String season) {
    if (!loc.isHindi) return season;
    switch (season) {
      case 'Kharif':
        return 'खरीफ';
      case 'Rabi':
        return 'रबी';
      case 'Commercial':
        return 'व्यावसायिक';
      default:
        return season;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.cropInsuranceCalc),
        actions: [
          const LanguageToggle(),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showPMFBYInfo,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PMFBY Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Calculator Form
            Text(loc.calculatePremium,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Season Selection
            Text(loc.season,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _seasons.map((season) {
                final isSelected = _selectedSeason == season;
                return ChoiceChip(
                  label: Text(_getSeasonLabel(season)),
                  selected: isSelected,
                  onSelected: (_) => setState(() {
                    _selectedSeason = season;
                    _showResult = false;
                  }),
                  selectedColor: Colors.blue.shade100,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Crop Selection
            DropdownButtonFormField<String>(
              value: _selectedCrop,
              decoration: InputDecoration(
                labelText: loc.crop,
                prefixIcon: const Icon(Icons.grass),
                border: const OutlineInputBorder(),
              ),
              items: _crops
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() {
                _selectedCrop = v!;
                _showResult = false;
              }),
            ),
            const SizedBox(height: 16),

            // Sum Insured
            TextFormField(
              controller: _sumInsuredController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${loc.sumInsured} (₹)',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: const OutlineInputBorder(),
                hintText: loc.isHindi
                    ? 'बीमित राशि दर्ज करें'
                    : 'Enter sum insured amount',
              ),
              onChanged: (_) => setState(() => _showResult = false),
            ),
            const SizedBox(height: 24),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: Text(loc.calculate),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Result
            if (_showResult) _buildResult(),

            const SizedBox(height: 24),

            // Premium Rates Info
            _buildPremiumRatesInfo(),
            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _launchUrl('https://pmfby.gov.in/'),
                icon: const Icon(Icons.open_in_new),
                label: Text(loc.applyOnPmfby),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.security, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.pmfby,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  loc.pmfbyFull,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final sumInsured = double.tryParse(_sumInsuredController.text) ?? 100000;
    final calculation = _service.calculateInsurancePremium(
      cropName: _selectedCrop,
      season: _selectedSeason,
      sumInsured: sumInsured,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 48),
          const SizedBox(height: 12),
          Text(loc.yourPremium, style: const TextStyle(fontSize: 16)),
          Text(
            '₹${calculation.farmerPremium.toStringAsFixed(0)}',
            style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700),
          ),
          const SizedBox(height: 16),
          _buildResultRow(loc.crop, calculation.cropName),
          _buildResultRow(loc.season, _getSeasonLabel(calculation.season)),
          _buildResultRow(
              loc.sumInsured, '₹${calculation.sumInsured.toStringAsFixed(0)}'),
          _buildResultRow(loc.premiumRate, '${calculation.premiumRate}%'),
          const Divider(),
          _buildResultRow(loc.farmerPremium,
              '₹${calculation.farmerPremium.toStringAsFixed(0)}',
              highlight: true),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(
            value,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
              color: highlight ? Colors.green.shade700 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumRatesInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 18),
              const SizedBox(width: 8),
              Text(loc.premiumRatesInfo,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          _buildRateRow(
              loc.kharif,
              '2%',
              loc.isHindi
                  ? 'धान, मक्का, कपास, सोयाबीन'
                  : 'Rice, Maize, Cotton, Soyabean'),
          _buildRateRow(
              loc.rabi,
              '1.5%',
              loc.isHindi
                  ? 'गेहूं, सरसों, चना, जौ'
                  : 'Wheat, Mustard, Gram, Barley'),
          _buildRateRow(
              loc.commercial,
              '5%',
              loc.isHindi
                  ? 'सब्जियां, फल, मसाले'
                  : 'Vegetables, Fruits, Spices'),
        ],
      ),
    );
  }

  Widget _buildRateRow(String season, String rate, String crops) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(season,
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.blue.shade700)),
          ),
          SizedBox(
            width: 40,
            child:
                Text(rate, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(crops,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }

  void _showPMFBYInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.isHindi ? 'पीएमएफबीवाई के बारे में' : 'About PMFBY'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loc.isHindi
                  ? 'प्रधानमंत्री फसल बीमा योजना फसल नुकसान के खिलाफ व्यापक बीमा कवरेज प्रदान करती है:'
                  : 'Pradhan Mantri Fasal Bima Yojana provides comprehensive insurance coverage against crop loss due to:'),
              const SizedBox(height: 8),
              Text(loc.isHindi
                  ? '• प्राकृतिक आपदाएं (बाढ़, सूखा, चक्रवात)'
                  : '• Natural calamities (flood, drought, cyclone)'),
              Text(loc.isHindi ? '• कीट और रोग' : '• Pests and diseases'),
              Text(loc.isHindi ? '• रोकी गई बुवाई' : '• Prevented sowing'),
              Text(loc.isHindi
                  ? '• कटाई के बाद का नुकसान'
                  : '• Post-harvest losses'),
              const SizedBox(height: 12),
              Text(loc.isHindi ? 'मुख्य लाभ:' : 'Key Benefits:',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(loc.isHindi
                  ? '• किसानों के लिए कम प्रीमियम'
                  : '• Low premium for farmers'),
              Text(loc.isHindi
                  ? '• फसल नुकसान के लिए पूर्ण बीमित राशि'
                  : '• Full sum insured for crop loss'),
              Text(loc.isHindi
                  ? '• प्रीमियम पर सरकारी सब्सिडी'
                  : '• Government subsidy on premium'),
              Text(loc.isHindi
                  ? '• त्वरित दावा निपटान'
                  : '• Quick claim settlement'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.close),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } catch (e) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
