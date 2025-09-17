import 'dart:async';

import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import 'package:xdeal/dummy_data.dart';
import 'package:xdeal/screens/dealer_profile_screen.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/utility_functions.dart';
import 'package:xdeal/widgets/listing_map_preview.dart';

class PropertyViewerScreen extends StatefulWidget {
  final String propertyId;
  const PropertyViewerScreen({super.key, required this.propertyId});

  @override
  State<PropertyViewerScreen> createState() => _PropertyViewerScreenState();
}

class _PropertyViewerScreenState extends State<PropertyViewerScreen> {
  Map<String, dynamic>? _property;

  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  bool _isFavorite = false;
  String _location = '';

  void toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  initState() {
    super.initState();
    setState(() {
      _property = DummyData.propertiesListings
          .where((p) => p['_id'] == widget.propertyId)
          .first;
    });

    // auto slide every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (_currentPage < _property!['images'].length - 1) {
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
      _property!['coords'][0],
      _property!['coords'][1],
    ).then((loc) => setState(() => _location = loc));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isOnSale = _property!['on_sale'];
    final bool isFeatured = _property!['is_featured'];
    final bool isSponsored = _property!['is_sponsored'];

    void handleBottomNavTap(int index) {
      switch (index) {
        case 0:
          UtilityFunctions.launchEmail(_property!['owner_id']['email']);
          break;
        case 1:
          UtilityFunctions.launchCall(_property!['owner_id']['phone']);
          break;
        case 2:
          UtilityFunctions.launchWhatsApp(_property!['owner_id']['phone']);
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
        title: Text(
          'Property Viewer',
          style: TextStyle(color: AppColors.black),
        ),
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
                        itemCount: _property!['images'].length,
                        onPageChanged: (int index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Image.network(
                            _property!['images'][index],
                            fit: BoxFit.cover,
                            width: double.infinity,
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
                          children: List.generate(_property!['images'].length, (
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
                      "\$${UtilityFunctions.formatPrice(_property!['price'])}",
                      style: TextStyle(color: AppColors.primary, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    // name
                    Text(
                      _property!['name'],
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
                              _property!['coords'],
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
                          UtilityFunctions.formatDate(_property!['createdAt']),
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

                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // additional info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // bedrooms
                            Container(
                              height: 40,
                              width: 110,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.greyBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _property!['bedrooms'].toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.bed_outlined,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                            // bathrooms
                            Container(
                              width: 110,
                              height: 40,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.greyBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _property!['bathrooms'].toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.bathtub_outlined,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                            // space m²
                            Container(
                              width: 110,
                              height: 40,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.greyBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${_property!['space'].toString()} m²',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.square_foot_outlined,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "360° View",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 250,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: PanoramaViewer(
                              zoom: 1, // adjust zoom so it fills horizontally
                              interactive: true, // allows drag to rotate
                              child: Image.network(
                                _property!['three_sixty'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
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
                        _property!['owner_id']['profile_picture'],
                        width: 100,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _property!['owner_id']['full_name'],
                          style: TextStyle(fontSize: 24),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DealerProfileScreen(
                                  dealerId: _property!['owner_id']['_id'],
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
              Padding(
                padding: const EdgeInsets.all(8.0),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(_property!['description']),
                    const SizedBox(height: 24),
                    ListingMapPreview(listing: _property!),
                    const SizedBox(height: 24),
                    const Text(
                      "Features",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 14, // horizontal spacing between squares
                      runSpacing: 14, // vertical spacing between rows
                      children: _property!['extra_features'].map<Widget>((
                        feature,
                      ) {
                        return Container(
                          width: 130,
                          height: 50,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: AppColors.inputBg,
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // rounded corners
                          ),
                          child: Text(
                            feature,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
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
            ],
          ),
        ),
      ),
    );
  }
}
