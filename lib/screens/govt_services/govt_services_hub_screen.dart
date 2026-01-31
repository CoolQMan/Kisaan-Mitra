import 'package:flutter/material.dart';
import 'package:kisaan_mitra/services/localization_service.dart';
import 'package:kisaan_mitra/screens/govt_services/scheme_finder_screen.dart';
import 'package:kisaan_mitra/screens/govt_services/mandi_prices_screen.dart';
import 'package:kisaan_mitra/screens/govt_services/insurance_calculator_screen.dart';
import 'package:kisaan_mitra/screens/govt_services/advisory_screen.dart';
import 'package:kisaan_mitra/screens/govt_services/helpline_screen.dart';
import 'package:kisaan_mitra/widgets/common/language_toggle.dart';
import 'package:url_launcher/url_launcher.dart';

/// Government Services Hub - Main screen replacing QnA
class GovtServicesHubScreen extends StatefulWidget {
  const GovtServicesHubScreen({super.key});

  @override
  State<GovtServicesHubScreen> createState() => _GovtServicesHubScreenState();
}

class _GovtServicesHubScreenState extends State<GovtServicesHubScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.sarkariSeva, style: const TextStyle(fontSize: 20)),
            Text(loc.govtServices,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          const LanguageToggle(),
          IconButton(
            icon: const Icon(Icons.phone_in_talk),
            tooltip: loc.kisanHelpline,
            onPressed: () => _callHelpline('1800-180-1551'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Featured Banner
              _buildFeaturedBanner(),
              const SizedBox(height: 24),

              // Service Categories Grid
              Text(
                loc.services,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildServiceGrid(),
              const SizedBox(height: 24),

              // Quick Links
              _buildQuickLinks(),
              const SizedBox(height: 24),

              // Recent Announcements
              _buildAnnouncements(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_wallet,
                    color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.pmKisanStatus,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    Text(
                      loc.checkPaymentStatus,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchUrl('https://pmkisan.gov.in'),
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: Text(loc.checkStatus,
                      style: const TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl('https://pmkisan.gov.in'),
                  icon: const Icon(Icons.person_add),
                  label: Text(loc.newRegister),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceGrid() {
    final services = [
      _ServiceItem(loc.schemes, loc.schemesDesc, Icons.assignment, Colors.green,
          'schemes'),
      _ServiceItem(loc.insurance, loc.insuranceDesc, Icons.security,
          Colors.blue, 'insurance'),
      _ServiceItem(loc.mandiPrices, loc.mandiPricesDesc, Icons.trending_up,
          Colors.orange, 'mandi'),
      _ServiceItem(loc.advisory, loc.advisoryDesc, Icons.tips_and_updates,
          Colors.purple, 'advisory'),
      _ServiceItem(
          loc.dealers, loc.dealersDesc, Icons.store, Colors.teal, 'dealers'),
      _ServiceItem(loc.helpline, loc.helplineDesc, Icons.support_agent,
          Colors.red, 'helpline'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _buildServiceCard(services[index]);
      },
    );
  }

  Widget _buildServiceCard(_ServiceItem item) {
    return GestureDetector(
      onTap: () => _navigateToService(item.id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: item.color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: item.color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: item.color,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              item.subtitle,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.quickActions,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildQuickLink('📞 ${loc.callKisanHelpline}',
                    () => _callHelpline('1800-180-1551'))),
            const SizedBox(width: 12),
            Expanded(
                child: _buildQuickLink('📊 ${loc.soilHealthCard}',
                    () => _launchUrl('https://soilhealth.dac.gov.in/'))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildQuickLink('🛒 ${loc.eNamMarket}',
                    () => _launchUrl('https://enam.gov.in/'))),
            const SizedBox(width: 12),
            Expanded(
                child: _buildQuickLink('🌐 ${loc.pmKisanPortal}',
                    () => _launchUrl('https://pmkisan.gov.in/'))),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickLink(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildAnnouncements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.campaign, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                loc.announcements,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.orange.shade700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAnnouncementItem(loc.isHindi
              ? '📋 पीएमएफबीवाई रबी पंजीकरण अंतिम तिथि: 15 फरवरी 2026'
              : '📋 PMFBY Rabi registration deadline: Feb 15, 2026'),
          _buildAnnouncementItem(loc.isHindi
              ? '💰 पीएम-किसान 19वीं किस्त जारी'
              : '💰 PM-KISAN 19th installment released'),
          _buildAnnouncementItem(loc.isHindi
              ? '🌾 रबी 2026-27 के लिए नई MSP दरें घोषित'
              : '🌾 New MSP rates announced for Rabi 2026-27'),
        ],
      ),
    );
  }

  Widget _buildAnnouncementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 6, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
              child:
                  Text(text, style: TextStyle(color: Colors.orange.shade800))),
        ],
      ),
    );
  }

  void _navigateToService(String serviceId) {
    Widget screen;
    switch (serviceId) {
      case 'schemes':
        screen = const SchemeFinderScreen();
        break;
      case 'insurance':
        screen = const InsuranceCalculatorScreen();
        break;
      case 'mandi':
        screen = const MandiPricesScreen();
        break;
      case 'advisory':
        screen = const AdvisoryScreen();
        break;
      case 'dealers':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.comingSoon)),
        );
        return;
      case 'helpline':
        screen = const HelplineScreen();
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } catch (e) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callHelpline(String number) async {
    final uri = Uri.parse('tel:$number');
    try {
      await launchUrl(uri);
    } catch (e) {
      // Phone call failed
    }
  }
}

class _ServiceItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String id;

  _ServiceItem(this.title, this.subtitle, this.icon, this.color, this.id);
}
