import 'package:flutter/material.dart';
import 'package:kisaan_mitra/services/localization_service.dart';

/// Language toggle button for app bar - shows current language and toggles on tap
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: loc,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            loc.toggleLanguage();
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.translate, size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  loc.isHindi ? 'हिं' : 'EN',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Language toggle for settings/profile screen (fuller version)
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: loc,
      builder: (context, child) {
        return ListTile(
          leading: const Icon(Icons.language),
          title: Text(loc.language),
          subtitle: Text(loc.isHindi ? 'हिंदी' : 'English'),
          trailing: Switch(
            value: loc.isHindi,
            onChanged: (_) => loc.toggleLanguage(),
            activeColor: Colors.green,
          ),
          onTap: () => loc.toggleLanguage(),
        );
      },
    );
  }
}
