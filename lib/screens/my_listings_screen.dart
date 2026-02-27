import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdeal/localization/app_localizations.dart';
import 'package:xdeal/providers/user_provider.dart';
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

  // filters state
  String _q = '';
  String? _categoryId;

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
    final currentUser = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppbar(title: "My Listings"),
            Divider(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      context.tr("Choose Between:"),
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    // toggle views
                    buildSegmentedToggle(
                      selectedIndex: _selectedView,
                      labels: [context.tr('Properties'), context.tr('Vehicles')],
                      onPressed: _toggleView,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr("Is it:"),
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    // listed / not listed toggle
                    buildSegmentedToggle(
                      selectedIndex: _selectedFilter,
                      labels: [context.tr('Listed'), context.tr('Not Listed')],
                      onPressed: _toggleFilter,
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: currentUser == null
                          ? Center(
                              child: Text(
                                context.tr("Please sign in to view your listings."),
                              ),
                            )
                          : ListingsViewer(
                              selectedView: _selectedView,
                              isUploaderViewing: true,
                              filter: _selectedFilter == 1
                                  ? ListingFilter.notListed
                                  : ListingFilter.newest,
                              q: _q,
                              categoryId: _categoryId,
                              userId: currentUser.id,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
