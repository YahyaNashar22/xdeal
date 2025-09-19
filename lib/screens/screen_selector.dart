import 'package:flutter/material.dart';
import 'package:xdeal/screens/favorite_screen.dart';
import 'package:xdeal/screens/home_screen.dart';
import 'package:xdeal/screens/my_listings_screen.dart';
import 'package:xdeal/screens/settings_screen.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/widgets/add_listing_modal.dart';
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
    MyListingsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // the Add Listing item index
      // show bottom sheet instead of switching screen
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return const AddListingModal(); // reuse your screen widget here
        },
      );
    } else {
      setState(() {
        _selectedIndex = index >= 2 ? index - 1 : index;
        // because we removed one item from _screens
      });
    }
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
