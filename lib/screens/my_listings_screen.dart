import 'package:flutter/material.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/widgets/custom_appbar.dart';
import 'package:xdeal/widgets/listings_viewer.dart';
import 'package:xdeal/widgets/segmented_toggles.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  int _selectedView = 0;
  int _selectedFilter = 0;

  void _toggleView(index) {
    setState(() {
      _selectedView = index;
    });
  }

  void _toggleFilter(index) {
    setState(() {
      _selectedFilter = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppbar(title: "My Listings"),
                Divider(),
                const SizedBox(height: 12),
                const Text("Choose Between:", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                // toggle views
                buildSegmentedToggle(
                  selectedIndex: _selectedView,
                  labels: ['Properties', 'Vehicles'],
                  onPressed: _toggleView,
                ),
                const SizedBox(height: 12),
                const Text("Is it:", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                // listed / not listed toggle
                buildSegmentedToggle(
                  selectedIndex: _selectedFilter,
                  labels: ['Listed', 'Not Listed'],
                  onPressed: _toggleFilter,
                ),
                const SizedBox(height: 24),
                // filtered listings
                ListingsViewer(
                  selectedView: _selectedView,
                  filter: _selectedFilter == 1
                      ? ListingFilter.notListed
                      : ListingFilter.newest,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
