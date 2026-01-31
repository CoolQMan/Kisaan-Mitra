import 'package:flutter/material.dart';
import 'package:kisaan_mitra/config/routes.dart';
import 'package:kisaan_mitra/services/localization_service.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: loc,
      builder: (context, child) {
        return BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            if (index == currentIndex) return;

            switch (index) {
              case 0:
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.home, (route) => false);
                break;
              case 1:
                Navigator.pushNamed(context, AppRoutes.notifications);
                break;
              case 2:
                Navigator.pushNamed(context, AppRoutes.profile);
                break;
              case 3:
                Navigator.pushNamed(context, AppRoutes.setting);
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: loc.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.notifications),
              label: loc.notifications,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: loc.profile,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: loc.settings,
            ),
          ],
        );
      },
    );
  }
}
