import 'package:flutter/material.dart';
import 'package:kisaan_mitra/config/routes.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                context,
                AppRoutes.home,
                    (route) => false
            );
            break;
          case 1:
          // TODO: Implement notifications
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
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
