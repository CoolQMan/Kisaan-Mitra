import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kisaan_mitra/config/routes.dart';
import 'package:kisaan_mitra/services/auth_service.dart';
import 'package:kisaan_mitra/services/localization_service.dart';
import 'package:kisaan_mitra/widgets/common/bottom_nav_bar.dart';
import 'package:kisaan_mitra/widgets/common/language_toggle.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Listen to language changes
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

  Future<bool> _onWillPop() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(loc.isHindi ? 'ऐप बंद करें' : 'Exit App'),
            content: Text(loc.isHindi
                ? 'क्या आप ऐप बंद करना चाहते हैं?'
                : 'Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(loc.isHindi ? 'नहीं' : 'No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  SystemNavigator.pop();
                },
                child: Text(loc.isHindi ? 'हाँ' : 'Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(loc.appName),
          actions: [
            const LanguageToggle(),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.profile);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome message
                Text(
                  loc.isHindi
                      ? 'नमस्ते, ${_authService.currentUser?.name ?? 'राकेश यादव'}'
                      : 'Hello, ${_authService.currentUser?.name ?? 'Rakesh Yadav'}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.isHindi
                      ? 'आज आपकी फसलों में कैसे मदद कर सकते हैं?'
                      : 'How can we help your crops today?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),

                // Feature grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildFeatureCard(
                        context,
                        title: loc.isHindi
                            ? 'फसल स्वास्थ्य विश्लेषण'
                            : 'Crop Health Analysis',
                        icon: Icons.eco,
                        color: Colors.green,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.cropAnalysis);
                        },
                      ),
                      _buildFeatureCard(
                        context,
                        title: loc.smartIrrigation,
                        icon: Icons.water_drop,
                        color: Colors.blue,
                        onTap: () {
                          Navigator.pushNamed(
                              context, AppRoutes.smartIrrigation);
                        },
                      ),
                      _buildFeatureCard(
                        context,
                        title: loc.sarkariSeva,
                        icon: Icons.account_balance,
                        color: Colors.orange,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.govtServices);
                        },
                      ),
                      _buildFeatureCard(
                        context,
                        title: loc.marketplace,
                        icon: Icons.shopping_cart,
                        color: Colors.purple,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.marketplace);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
