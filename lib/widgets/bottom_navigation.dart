import 'package:flutter/material.dart';
import 'package:xdeal/localization/app_localizations.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: context.tr('Home')),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: context.tr('Favorites'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box_outlined),
          label: context.tr('Add Listings'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: context.tr('My Listings'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: context.tr('Settings'),
        ),
      ],
    );
  }
}
