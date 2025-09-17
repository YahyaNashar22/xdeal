import 'package:flutter/material.dart';
import 'package:xdeal/dummy_data.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/widgets/ads_carousel.dart';
import 'package:xdeal/widgets/listings_viewer.dart';
import 'package:xdeal/widgets/property_vehicle_toggle_appbar.dart';
import 'package:xdeal/widgets/search_bar_and_filter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // view index for properties and vehicles
  int selectedView = 0;

  // change view between properties and vehicles
  void selectView(int index) {
    setState(() {
      selectedView = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            PropertyVehicleToggleAppbar(
              selectedView: selectedView,
              selectView: selectView,
            ),
            const SizedBox(height: 12),
            SearchBarAndFilter(selectedView: selectedView),
            const SizedBox(height: 12),
            AdsCarousel(),
            const SizedBox(height: 24),
            ListingsViewer(selectedView: selectedView),
          ],
        ),
      ),
    );
  }
}
