import 'package:flutter/material.dart';
import 'package:xdeal/screens/add_listings_screen.dart';
import 'package:xdeal/screens/favorite_screen.dart';
import 'package:xdeal/screens/home_screen.dart';
import 'package:xdeal/screens/my_listings_screen.dart';
import 'package:xdeal/screens/on_boarding_screen.dart';
import 'package:xdeal/screens/settings_screen.dart';
import 'package:xdeal/screens/sign_in_screen.dart';
import 'package:xdeal/screens/sign_up_screen.dart';
import 'package:xdeal/screens/forgot_password_screen.dart';
import 'package:xdeal/utils/app_colors.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Add Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'My Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
