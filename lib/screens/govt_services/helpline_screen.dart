import 'package:flutter/material.dart';
import 'package:kisaan_mitra/services/govt_services_service.dart';
import 'package:kisaan_mitra/services/localization_service.dart';
import 'package:kisaan_mitra/widgets/common/language_toggle.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helpline Screen - Kisan Call Center and FAQs
class HelplineScreen extends StatefulWidget {
  const HelplineScreen({super.key});

  @override
  State<HelplineScreen> createState() => _HelplineScreenState();
}

class _HelplineScreenState extends State<HelplineScreen> {
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
    final service = GovtServicesService();
    final helplines = service.getHelplines();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.kisanHelpline),
        actions: const [LanguageToggle()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Helpline Card
            _buildMainHelplineCard(context),
            const SizedBox(height: 24),

            // All Helplines
            Text(loc.allHelplines,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...helplines.entries
                .map((e) => _buildHelplineRow(context, e.key, e.value)),
            const SizedBox(height: 24),

            // FAQs
            Text(loc.faq,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildFAQTile(
                loc.isHindi
                    ? 'पीएम-किसान स्थिति कैसे जांचें?'
                    : 'How to check PM-KISAN status?',
                loc.isHindi
                    ? 'pmkisan.gov.in पर जाएं → लाभार्थी स्थिति → आधार/मोबाइल/खाता नंबर दर्ज करें'
                    : 'Visit pmkisan.gov.in → Beneficiary Status → Enter Aadhaar/Mobile/Account number'),
            _buildFAQTile(
                loc.isHindi
                    ? 'पीएमएफबीवाई फसल बीमा के लिए कैसे आवेदन करें?'
                    : 'How to apply for PMFBY crop insurance?',
                loc.isHindi
                    ? 'pmfby.gov.in पर जाएं → पॉलिसी के लिए आवेदन करें → पंजीकरण करें और फसल चुनें → ऑनलाइन या बैंक के माध्यम से प्रीमियम का भुगतान करें'
                    : 'Visit pmfby.gov.in → Apply for a Policy → Register and select crop → Pay premium online or through bank'),
            _buildFAQTile(
                loc.isHindi
                    ? 'किसान कॉल सेंटर नंबर क्या है?'
                    : 'What is the Kisan Call Center number?',
                loc.isHindi
                    ? '1800-180-1551 (टोल-फ्री)। सुबह 6 बजे से रात 10 बजे तक 22 स्थानीय भाषाओं में उपलब्ध।'
                    : '1800-180-1551 (Toll-free). Available 6 AM to 10 PM in 22 local languages.'),
            _buildFAQTile(
                loc.isHindi
                    ? 'मृदा स्वास्थ्य कार्ड कैसे प्राप्त करें?'
                    : 'How to get Soil Health Card?',
                loc.isHindi
                    ? 'मिट्टी के नमूने के साथ निकटतम मृदा परीक्षण प्रयोगशाला जाएं या soilhealth.dac.gov.in पर ऑनलाइन आवेदन करें'
                    : 'Visit nearest Soil Testing Lab with soil sample or apply online at soilhealth.dac.gov.in'),
            _buildFAQTile(
                loc.isHindi
                    ? 'मंडी भाव कहाँ देखें?'
                    : 'Where to check mandi prices?',
                loc.isHindi
                    ? 'agmarknet.gov.in पर जाएं या इस ऐप में मंडी भाव फीचर का उपयोग करें'
                    : 'Visit agmarknet.gov.in or use the Mandi Prices feature in this app'),
            const SizedBox(height: 24),

            // Quick Links
            Text(loc.usefulLinks,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildLinkTile(
                context,
                loc.isHindi ? 'किसान सुविधा पोर्टल' : 'Kisan Suvidha Portal',
                'https://kisansuvidha.gov.in/'),
            _buildLinkTile(
                context, loc.pmKisanPortal, 'https://pmkisan.gov.in/'),
            _buildLinkTile(
                context,
                loc.isHindi ? 'पीएमएफबीवाई पोर्टल' : 'PMFBY Portal',
                'https://pmfby.gov.in/'),
            _buildLinkTile(context, loc.eNamMarket, 'https://enam.gov.in/'),
            _buildLinkTile(
                context,
                loc.isHindi ? 'मृदा स्वास्थ्य पोर्टल' : 'Soil Health Portal',
                'https://soilhealth.dac.gov.in/'),
          ],
        ),
      ),
    );
  }

  Widget _buildMainHelplineCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade800],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.support_agent, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            loc.kisanCallCenter,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            loc.tollFreeHelpline,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          const Text(
            '1800-180-1551',
            style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _callNumber('1800-180-1551'),
            icon: const Icon(Icons.call),
            label: Text(loc.callNow),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            loc.availableIn22Languages,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHelplineRow(BuildContext context, String name, String number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.phone, color: Colors.green.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(number,
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.call, color: Colors.green.shade700),
            onPressed: () => _callNumber(number),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return ExpansionTile(
      title:
          Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Text(answer,
            style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
      ],
    );
  }

  Widget _buildLinkTile(BuildContext context, String name, String url) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.link, color: Colors.blue.shade600),
      title: Text(name),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () => _launchUrl(url),
    );
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    try {
      await launchUrl(uri);
    } catch (e) {
      // Phone call failed
    }
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
