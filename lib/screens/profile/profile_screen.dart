import 'package:flutter/material.dart';
import 'package:kisaan_mitra/config/routes.dart';
import 'package:kisaan_mitra/services/auth_service.dart';
import 'package:kisaan_mitra/services/localization_service.dart';
import 'package:kisaan_mitra/widgets/common/bottom_nav_bar.dart';
import 'package:kisaan_mitra/widgets/common/language_toggle.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.home, (route) => false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(loc.profile),
          actions: const [LanguageToggle()],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile header
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/logo.png'),
              ),
              const SizedBox(height: 16),
              Text(
                _authService.currentUser?.name ?? 'User',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                _authService.currentUser?.email ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),

              // Profile options
              _buildProfileOption(
                context,
                icon: Icons.person,
                title: loc.editProfile,
                onTap: () {
                  // Navigate to edit profile screen
                },
              ),
              _buildProfileOption(
                context,
                icon: Icons.history,
                title: loc.isHindi
                    ? 'फसल विश्लेषण इतिहास'
                    : 'Crop Analysis History',
                onTap: () {
                  // Navigate to crop analysis history
                },
              ),
              _buildProfileOption(
                context,
                icon: Icons.shopping_bag,
                title: loc.myListings,
                onTap: () {
                  // Navigate to my listings
                },
              ),
              _buildProfileOption(
                context,
                icon: Icons.help,
                title: loc.isHindi ? 'सहायता और समर्थन' : 'Help & Support',
                onTap: () {
                  // Navigate to help & support
                },
              ),
              _buildProfileOption(
                context,
                icon: Icons.logout,
                title: loc.logout,
                onTap: () async {
                  await _authService.logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
