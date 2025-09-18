import 'package:flutter/material.dart';
import 'package:xdeal/dummy_data.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/utility_functions.dart';
import 'package:xdeal/widgets/listings_viewer.dart';

class DealerProfileScreen extends StatefulWidget {
  final String dealerId;
  const DealerProfileScreen({super.key, required this.dealerId});

  @override
  State<DealerProfileScreen> createState() => _DealerProfileScreenState();
}

class _DealerProfileScreenState extends State<DealerProfileScreen> {
  Map<String, dynamic>? _dealer;

  // 0 -> Properties
  // 1 -> vehicles
  int _selectedView = 0;

  ListingFilter _selectedFilter = ListingFilter.none;

  void _selectView(int view) {
    setState(() {
      setState(() {
        _selectedView = view;
      });
    });
  }

  void _selectFilter(ListingFilter filter) {
    setState(() {
      if (_selectedFilter == filter) {
        _selectedFilter = ListingFilter.none;
      } else {
        _selectedFilter = filter;
      }
    });
  }

  TextStyle _selectedBtnStyle(int view) {
    if (_selectedView == view) {
      return TextStyle(color: AppColors.primary);
    }
    return TextStyle(color: AppColors.black);
  }

  @override
  void initState() {
    super.initState();
    // TODO: fetch dealer based on id and set it
    setState(() {
      _dealer = DummyData.owner;
    });
  }

  @override
  Widget build(BuildContext context) {
    void handleBottomNavTap(int index) {
      switch (index) {
        case 0:
          UtilityFunctions.launchEmail(_dealer!['email']);
          break;
        case 1:
          UtilityFunctions.launchCall(_dealer!['phone']);
          break;
        case 2:
          UtilityFunctions.launchWhatsApp(_dealer!['phone']);
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: AppColors.black),
        ),
        title: Text('Dealer Profile', style: TextStyle(color: AppColors.black)),
        actions: [Image.asset('assets/icons/logo_purple_large.png', width: 50)],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: handleBottomNavTap,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.email_outlined),
            label: 'Email',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_forwarded_outlined),
            label: 'Phone',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/whatsapp.png'),
            label: 'Whatsapp',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // profile picture
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _dealer!['profile_picture'],
                      width: 120,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // name
                Center(
                  child: Text(
                    _dealer!['full_name'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                // number of listings
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.greyBg),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _dealer!['number_of_listings'].toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Number of Listings",
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                // properties / vehicles switch
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _selectView(0),
                      child: Text("Properties", style: _selectedBtnStyle(0)),
                    ),
                    TextButton(
                      onPressed: () => _selectView(1),
                      child: Text("Vehicles", style: _selectedBtnStyle(1)),
                    ),
                  ],
                ),
                Divider(),
                const SizedBox(height: 12),
                // Filters
                const Text(
                  "Filter",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // cheapest
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _selectedFilter == ListingFilter.cheapest
                            ? AppColors.primary
                            : AppColors.inputBg,
                      ),
                      onPressed: () => _selectFilter(ListingFilter.cheapest),
                      child: Text(
                        "Cheapest",
                        style: TextStyle(
                          color: _selectedFilter == ListingFilter.cheapest
                              ? AppColors.white
                              : AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // expensive
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _selectedFilter == ListingFilter.expensive
                            ? AppColors.primary
                            : AppColors.inputBg,
                      ),
                      onPressed: () => _selectFilter(ListingFilter.expensive),
                      child: Text(
                        "Expensive",
                        style: TextStyle(
                          color: _selectedFilter == ListingFilter.expensive
                              ? AppColors.white
                              : AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // newest
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedFilter == ListingFilter.newest
                            ? AppColors.primary
                            : AppColors.inputBg,
                      ),
                      onPressed: () => _selectFilter(ListingFilter.newest),
                      child: Text(
                        "Newest",
                        style: TextStyle(
                          color: _selectedFilter == ListingFilter.newest
                              ? AppColors.white
                              : AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Listings
                ListingsViewer(
                  selectedView: _selectedView,
                  isDealerProfile: true,
                  filter: _selectedFilter,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
