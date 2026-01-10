import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xdeal/dummy_data.dart';
import 'package:xdeal/screens/dealer_profile_screen.dart';
import 'package:xdeal/screens/full_screen_image_viewer.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/utility_functions.dart';
import 'package:xdeal/widgets/listing_map_preview.dart';
import 'package:xdeal/widgets/vehicle_option.dart';

class VehicleViewerScreen extends StatefulWidget {
  final String vehicleId;
  const VehicleViewerScreen({super.key, required this.vehicleId});

  @override
  State<VehicleViewerScreen> createState() => _VehicleViewerScreenState();
}

class _VehicleViewerScreenState extends State<VehicleViewerScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  Map<String, dynamic>? _vehicle;
  bool _isFavorite = false;
  String _location = '';
  bool isExpanded = false;

  void toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _vehicle = DummyData.vehiclesListings
          .where((v) => v['_id'] == widget.vehicleId)
          .first;
    });
    // auto slide every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (_currentPage < _vehicle!['images'].length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });

    // reverse geolocation
    UtilityFunctions.getLocationFromCoordinatesGoogle(
      _vehicle!['coords'][0],
      _vehicle!['coords'][1],
    ).then((loc) => setState(() => _location = loc));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _showPhonePopup(BuildContext context) {
    // Extracting the phone number for readability
    final String phoneNumber = _vehicle!['owner_id']['phone'] ?? 'Unknown';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text("Contact Owner"),
          content: Text("Would you like to call $phoneNumber?"),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            // Call Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, // Using your app color
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context); // Close the popup first
                UtilityFunctions.launchCall(phoneNumber);
              },
              child: const Text("Call Now"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOnSale = _vehicle!['on_sale'];
    final bool isFeatured = _vehicle!['is_featured'];
    final bool isSponsored = _vehicle!['is_sponsored'];

    void handleBottomNavTap(int index) {
      switch (index) {
        case 0:
          UtilityFunctions.launchEmail(_vehicle!['owner_id']['email']);
          break;
        case 1:
          _showPhonePopup(context);
          break;
        case 2:
          UtilityFunctions.launchWhatsApp(_vehicle!['owner_id']['phone']);
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
        title: Text('Vehicle Viewer', style: TextStyle(color: AppColors.black)),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // gallery
              SizedBox(
                height: 200,
                child: ClipRRect(
                  child: Stack(
                    children: [
                      // slide show
                      PageView.builder(
                        controller: _pageController,
                        itemCount: _vehicle!['images'].length,
                        onPageChanged: (int index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImageViewer(
                                    images: _vehicle!['images'],
                                    initialIndex: index,
                                  ),
                                ),
                              );
                            },
                            child: Image.network(
                              _vehicle!['images'][index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          );
                        },
                      ),
                      // dots indicator
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_vehicle!['images'].length, (
                            index,
                          ) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 10 : 8,
                              height: _currentPage == index ? 10 : 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: _currentPage == index
                                    ? AppColors.primary
                                    : AppColors.inputBg,
                              ),
                            );
                          }),
                        ),
                      ),
                      // favorite icon
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: _isFavorite
                            ? IconButton(
                                onPressed: toggleFavorite,
                                icon: Icon(Icons.favorite),
                                color: AppColors.primary,
                              )
                            : IconButton(
                                onPressed: toggleFavorite,
                                icon: Icon(Icons.favorite_border),
                              ),
                      ),
                      // featured / sponsored flag
                      if (isSponsored || isFeatured)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isSponsored ? "Sponsored" : "Featured",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      // sale flag
                      if (isOnSale)
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Sale",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // price
                    const Text(
                      "Price",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "\$${UtilityFunctions.formatPrice(_vehicle!['price'])}",
                      style: TextStyle(color: AppColors.primary, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    // name
                    Text(
                      _vehicle!['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    // location and date
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            UtilityFunctions.openMapsAtCoords(
                              _vehicle!['coords'],
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: AppColors.primary,
                              ),
                              Text(
                                _location.isEmpty
                                    ? "Loading location..."
                                    : _location,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          UtilityFunctions.formatDate(_vehicle!['createdAt']),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Divider(),
                    const SizedBox(height: 24),
                    // additional info
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // year
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_month_outlined,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _vehicle!['year'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            // fuel type
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.ev_station_outlined,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _vehicle!['fuel_type'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            // mileage
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_road_outlined,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _vehicle!['kilometers'].toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // condition
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.car_repair_outlined,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _vehicle!['condition'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            // transmission
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.garage_outlined,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _vehicle!['transmission_type'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Divider(),
                    const SizedBox(height: 24),
                    // addition details
                    const Text(
                      "Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    VehicleOption(
                      optionName: "Brand",
                      optionValue: _vehicle!['brand'],
                    ),
                    const SizedBox(height: 12),
                    VehicleOption(
                      optionName: "Color",
                      optionValue: _vehicle!['color'],
                    ),
                    const SizedBox(height: 12),
                    VehicleOption(
                      optionName: "Brand",
                      optionValue: _vehicle!['brand'],
                    ),
                    const SizedBox(height: 12),
                    VehicleOption(
                      optionName: "Number of doors",
                      optionValue: _vehicle!['number_of_doors'],
                    ),
                    const SizedBox(height: 12),
                    VehicleOption(
                      optionName: "Model",
                      optionValue: _vehicle!['model'],
                    ),
                    const SizedBox(height: 12),
                    VehicleOption(
                      optionName: "Number of Seats",
                      optionValue: _vehicle!['number_of_seats'],
                    ),
                    const SizedBox(height: 12),
                    VehicleOption(
                      optionName: "Air Conditioning",
                      optionValue: _vehicle!['air_conditioning'],
                    ),
                    const SizedBox(height: 12),
                    VehicleOption(
                      optionName: "Interior",
                      optionValue: _vehicle!['interior'],
                    ),
                    const SizedBox(height: 12),
                    VehicleOption(
                      optionName: "Body Type",
                      optionValue: _vehicle!['body_type'],
                    ),
                    const SizedBox(height: 12),
                    VehicleOption(
                      optionName: "Payment Option",
                      optionValue: _vehicle!['payment_option'],
                    ),
                    const SizedBox(height: 24),
                    // Description
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Create a TextPainter to calculate the size of the text
                        final span = TextSpan(
                          text: _vehicle!['description'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        );

                        final tp = TextPainter(
                          text: span,
                          maxLines: 2,
                          textAlign: TextAlign.left,
                          textDirection: TextDirection.ltr,
                        );

                        // Apply the constraints of the parent width
                        tp.layout(maxWidth: constraints.maxWidth);

                        // Check if the text actually overflows 2 lines
                        final bool isOverflowing = tp.didExceedMaxLines;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _vehicle!['description'],
                              // When not expanded, show only 2 lines. When expanded, show everything.
                              maxLines: isExpanded ? null : 2,
                              overflow: isExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            if (isOverflowing || isExpanded)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isExpanded = !isExpanded;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    isExpanded ? "Show Less" : "Read More",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(
                  bottom: 32,
                  top: 8,
                  left: 8,
                  right: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    ListingMapPreview(listing: _vehicle!),
                    const SizedBox(height: 24),
                    // Extra Feature
                    const Text(
                      "Extra Feature",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // disable its own scrolling
                      itemCount: _vehicle!['extra_features'].length,
                      itemBuilder: (context, index) {
                        final String feature =
                            _vehicle!['extra_features'][index];

                        return Column(
                          children: [
                            VehicleOption(
                              optionName: feature,
                              optionValue: true,
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
                    ),

                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(120, 30),
                        ),
                        onPressed: toggleFavorite,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _isFavorite
                                ? Icon(Icons.favorite)
                                : Icon(Icons.favorite_border),
                            const SizedBox(width: 12),
                            Text("Add to Favorites"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // owner info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.greyBg),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(12),
                      child: Image.network(
                        _vehicle!['owner_id']['profile_picture'],
                        width: 100,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _vehicle!['owner_id']['full_name'],
                          style: TextStyle(fontSize: 24),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DealerProfileScreen(
                                  dealerId: _vehicle!['owner_id']['_id'],
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                "See profile",
                                style: TextStyle(color: AppColors.primary),
                              ),
                              Icon(Icons.arrow_forward_ios_outlined),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
