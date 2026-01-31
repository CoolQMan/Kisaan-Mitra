import 'package:flutter/material.dart';
import 'package:kisaan_mitra/models/govt_services_models.dart';
import 'package:kisaan_mitra/services/govt_services_service.dart';
import 'package:kisaan_mitra/services/localization_service.dart';
import 'package:kisaan_mitra/widgets/common/language_toggle.dart';
import 'package:url_launcher/url_launcher.dart';

/// Scheme Finder - Browse all government schemes
class SchemeFinderScreen extends StatefulWidget {
  const SchemeFinderScreen({super.key});

  @override
  State<SchemeFinderScreen> createState() => _SchemeFinderScreenState();
}

class _SchemeFinderScreenState extends State<SchemeFinderScreen> {
  final GovtServicesService _service = GovtServicesService();
  String _selectedCategory = 'all';

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

  Map<String, String> get _categories => {
        'all': loc.allSchemes,
        'subsidy': loc.subsidies,
        'insurance': loc.insurance,
        'credit': loc.creditLoans,
        'market': loc.market,
        'advisory': loc.advisory,
      };

  @override
  Widget build(BuildContext context) {
    final allSchemes = _service.getSchemes();
    final schemes = _selectedCategory == 'all'
        ? allSchemes
        : allSchemes.where((s) => s.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.govtSchemes),
        actions: const [LanguageToggle()],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _categories.entries.map((entry) {
                final isSelected = _selectedCategory == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = entry.key),
                    selectedColor: Colors.green.shade100,
                  ),
                );
              }).toList(),
            ),
          ),

          // Schemes List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: schemes.length,
              itemBuilder: (context, index) {
                return _buildSchemeCard(schemes[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(GovtScheme scheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showSchemeDetails(scheme),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(scheme.category)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getSchemeIcon(scheme.iconName),
                      color: _getCategoryColor(scheme.category),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.isHindi && scheme.nameHindi.isNotEmpty
                              ? scheme.nameHindi
                              : scheme.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (!loc.isHindi && scheme.nameHindi.isNotEmpty)
                          Text(
                            scheme.nameHindi,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                  ),
                  if (scheme.deadline != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${loc.deadline}: ${_formatDate(scheme.deadline!)}',
                        style:
                            TextStyle(fontSize: 10, color: Colors.red.shade700),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                scheme.description,
                style: TextStyle(color: Colors.grey.shade700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(_getCategoryLabel(scheme.category),
                      _getCategoryColor(scheme.category)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showSchemeDetails(scheme),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: Text(loc.details),
                  ),
                  TextButton.icon(
                    onPressed: () => _launchUrl(scheme.websiteUrl),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: Text(loc.apply),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  void _showSchemeDetails(GovtScheme scheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(scheme.category)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getSchemeIcon(scheme.iconName),
                      color: _getCategoryColor(scheme.category),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            loc.isHindi && scheme.nameHindi.isNotEmpty
                                ? scheme.nameHindi
                                : scheme.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        if (!loc.isHindi && scheme.nameHindi.isNotEmpty)
                          Text(scheme.nameHindi,
                              style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailSection('📋 ${loc.description}', scheme.description),
              _buildDetailSection('✅ ${loc.eligibility}', scheme.eligibility),
              _buildDetailSection('💰 ${loc.benefits}', scheme.benefits),
              _buildDetailSection(
                  '📝 ${loc.howToApply}', scheme.applicationProcess),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl(scheme.websiteUrl),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(loc.visitOfficialWebsite),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(content,
              style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'subsidy':
        return Colors.green;
      case 'insurance':
        return Colors.blue;
      case 'credit':
        return Colors.orange;
      case 'market':
        return Colors.purple;
      case 'advisory':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'subsidy':
        return loc.subsidies;
      case 'insurance':
        return loc.insurance;
      case 'credit':
        return loc.creditLoans;
      case 'market':
        return loc.market;
      case 'advisory':
        return loc.advisory;
      default:
        return category;
    }
  }

  IconData _getSchemeIcon(String? iconName) {
    switch (iconName) {
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'security':
        return Icons.security;
      case 'solar_power':
        return Icons.solar_power;
      case 'credit_card':
        return Icons.credit_card;
      case 'eco':
        return Icons.eco;
      case 'storefront':
        return Icons.storefront;
      default:
        return Icons.assignment;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
