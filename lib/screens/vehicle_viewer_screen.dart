import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xdeal/dummy_data.dart';
import 'package:xdeal/theme/app_theme.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/utility_functions.dart';
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

  @override
  Widget build(BuildContext context) {
    final bool isOnSale = _vehicle!['on_sale'];
    final bool isFeatured = _vehicle!['is_featured'];
    final bool isSponsored = _vehicle!['is_sponsored'];

    print(_vehicle!['owner_id']['profile_picture']);
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
      body: SingleChildScrollView(
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
                        return Image.network(
                          _vehicle!['images'][index],
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "\$${UtilityFunctions.formatPrice(_vehicle!['price'])}",
                    style: TextStyle(color: AppColors.primary, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  // name
                  Text(
                    _vehicle!['name'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(_vehicle!['description']),
                  const SizedBox(height: 24),
                  Divider(),
                  const SizedBox(height: 12),
                  Container(
                    child: Row(
                      children: [
                        Image.network(
                          _vehicle!['owner_id']['profile_picture'],
                          width: 100,
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
                              onPressed: () {},
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
                  const SizedBox(height: 12),
                  Divider(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
