import 'package:flutter/material.dart';
import 'package:kisaan_mitra/models/govt_services_models.dart';
import 'package:kisaan_mitra/services/govt_services_service.dart';
import 'package:kisaan_mitra/services/localization_service.dart';
import 'package:kisaan_mitra/widgets/common/language_toggle.dart';

/// Advisory Screen - Agro advisories for farmers
class AdvisoryScreen extends StatefulWidget {
  const AdvisoryScreen({super.key});

  @override
  State<AdvisoryScreen> createState() => _AdvisoryScreenState();
}

class _AdvisoryScreenState extends State<AdvisoryScreen> {
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
        'all': loc.all,
        'crop': loc.cropAdvisory,
        'pest': loc.pestAdvisory,
        'weather': loc.weatherAdvisory,
      };

  @override
  Widget build(BuildContext context) {
    final allAdvisories = _service.getAdvisories();
    final advisories = _selectedCategory == 'all'
        ? allAdvisories
        : allAdvisories.where((a) => a.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.agroAdvisory),
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
                    selectedColor: Colors.purple.shade100,
                  ),
                );
              }).toList(),
            ),
          ),

          // Advisories List
          Expanded(
            child: advisories.isEmpty
                ? Center(
                    child: Text(
                      loc.noDataFound,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: advisories.length,
                    itemBuilder: (context, index) {
                      return _buildAdvisoryCard(advisories[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisoryCard(AgroAdvisory advisory) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                    color: _getCategoryColor(advisory.category)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(advisory.category),
                    color: _getCategoryColor(advisory.category),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        advisory.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Row(
                        children: [
                          Text(
                            advisory.source,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTimeAgo(advisory.publishedDate),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              advisory.content,
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
            if (advisory.district != null || advisory.state != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    [advisory.district, advisory.state]
                        .where((s) => s != null)
                        .join(', '),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'crop':
        return Colors.green;
      case 'pest':
        return Colors.red;
      case 'weather':
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'crop':
        return Icons.grass;
      case 'pest':
        return Icons.bug_report;
      case 'weather':
        return Icons.cloud;
      default:
        return Icons.info_outline;
    }
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return loc.isHindi ? '${diff.inDays} दिन पहले' : '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return loc.isHindi ? '${diff.inHours} घंटे पहले' : '${diff.inHours}h ago';
    } else {
      return loc.isHindi
          ? '${diff.inMinutes} मिनट पहले'
          : '${diff.inMinutes}m ago';
    }
  }
}
