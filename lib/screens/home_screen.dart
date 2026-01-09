import 'package:flutter/material.dart';
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
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                // These three properties control the "floating" behavior
                floating: true,
                snap:
                    true, // App bar snaps back into view when you pull down slightly
                pinned: false,
                backgroundColor: AppColors.white,
                elevation: 0,
                automaticallyImplyLeading: false,
                // We use flexibleSpace or bottom to house your custom widgets
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      children: [
                        PropertyVehicleToggleAppbar(
                          selectedView: selectedView,
                          selectView: selectView,
                        ),
                        const SizedBox(height: 12),
                        SearchBarAndFilter(selectedView: selectedView),
                      ],
                    ),
                  ),
                ),
                expandedHeight: 200,
              ),
            ];
          },
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              AdsCarousel(),
              const SizedBox(height: 24),
              ListingsViewer(selectedView: selectedView),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
