import 'package:flutter/material.dart';
import 'package:xdeal/screens/add_listings_screen.dart';
import 'package:xdeal/screens/favorite_screen.dart';
import 'package:xdeal/screens/home_screen.dart';
import 'package:xdeal/screens/my_listings_screen.dart';
import 'package:xdeal/screens/settings_screen.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/widgets/bottom_navigation.dart';

class ScreenSelector extends StatefulWidget {
  const ScreenSelector({super.key});

  @override
  State<ScreenSelector> createState() => _ScreenSelectorState();
}

class _ScreenSelectorState extends State<ScreenSelector> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    FavoriteScreen(),
    AddListingsScreen(),
    MyListingsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
