import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:xdeal/screens/vehicle_viewer_screen.dart';
import 'package:xdeal/theme/app_theme.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/utility_functions.dart';
import 'package:xdeal/widgets/user_view_listing_modal.dart';

class VehicleListing extends StatefulWidget {
  final Map<String, dynamic> vehicle;
  final bool isDealerProfile;
  final bool isUploaderViewing;
  const VehicleListing({
    super.key,
    required this.vehicle,
    required this.isDealerProfile,
    required this.isUploaderViewing,
  });

  @override
  State<VehicleListing> createState() => _VehicleListingState();
}

class _VehicleListingState extends State<VehicleListing> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool _isFavorite = false;
  String _location = '';

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _handleListingTap() {
    if (!widget.isUploaderViewing) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              VehicleViewerScreen(vehicleId: widget.vehicle['_id']),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return UserViewListingModal(
            listingType: 1,
            listingId: widget.vehicle['_id'],
          ); // reuse your screen widget here
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // reverse geolocation
    UtilityFunctions.getLocationFromCoordinatesGoogle(
      widget.vehicle['coords'][0],
      widget.vehicle['coords'][1],
    ).then((loc) {
      if (mounted) setState(() => _location = loc);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isOnSale = widget.vehicle['on_sale'];
    final bool isFeatured = widget.vehicle['is_featured'];
    final bool isSponsored = widget.vehicle['is_sponsored'];
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _handleListingTap,
          child: SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // slide show
                  PageView.builder(
                    controller: _pageController,
                    itemCount: math.min(widget.vehicle['images'].length, 3),
                    onPageChanged: (int index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.vehicle['images'][index],
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
                      children: List.generate(
                        math.min(widget.vehicle['images'].length, 3),
                        (index) {
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
                        },
                      ),
                    ),
                  ),
                  // favorite icon
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: _isFavorite
                        ? IconButton(
                            onPressed: _toggleFavorite,
                            icon: Icon(Icons.favorite),
                            color: AppColors.primary,
                          )
                        : IconButton(
                            onPressed: _toggleFavorite,
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
        ),
        const SizedBox(height: 12),
        // price
        Text(
          "USD ${UtilityFunctions.formatPrice(widget.vehicle['price'])}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppTheme.heading1,
          ),
        ),
        // name + model
        Text(
          widget.vehicle['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppTheme.heading2,
            color: AppColors.primary,
          ),
        ),
        // category
        Text(
          widget.vehicle['category'],
          style: TextStyle(
            fontSize: AppTheme.heading2,
            color: AppColors.primary,
          ),
        ),
        // location and date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                UtilityFunctions.openMapsAtCoords(widget.vehicle['coords']);
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
                  Icon(Icons.location_on_outlined, color: AppColors.primary),
                  Text(_location.isEmpty ? "Loading location..." : _location),
                ],
              ),
            ),
            Text(
              UtilityFunctions.formatDate(widget.vehicle['createdAt']),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // additional info
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // doors
            Container(
              height: 40,
              width: 110,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.greyBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.vehicle['number_of_doors'].toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.door_sliding_outlined, color: AppColors.primary),
                ],
              ),
            ),
            // kilometers
            Container(
              width: 110,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.greyBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.vehicle['kilometers'].toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.edit_road_outlined, color: AppColors.primary),
                ],
              ),
            ),
            // condition
            Container(
              width: 110,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.greyBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.vehicle['condition'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.sentiment_very_satisfied_outlined,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        // contact info
        const SizedBox(height: 12),
        if (!widget.isDealerProfile && !widget.isUploaderViewing)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () => UtilityFunctions.launchEmail(
                  widget.vehicle['owner_id']['email'],
                ),
                child: Container(
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
                      Icon(Icons.email_outlined, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () => UtilityFunctions.launchCall(
                  widget.vehicle['owner_id']['phone'],
                ),
                child: Container(
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
                      Icon(
                        Icons.phone_forwarded_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Call',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () => UtilityFunctions.launchWhatsApp(
                  widget.vehicle['owner_id']['phone'],
                ),
                child: Container(
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
                  child: Image.asset('assets/icons/whatsapp.png'),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
