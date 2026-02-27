import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdeal/localization/app_localizations.dart';
import 'package:xdeal/providers/user_provider.dart';
import 'package:xdeal/screens/vehicle_viewer_screen.dart';
import 'package:xdeal/services/api_client.dart';
import 'package:xdeal/services/favorite_vehicle_service.dart';
import 'package:xdeal/theme/app_theme.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/utility_functions.dart';
import 'package:xdeal/widgets/user_view_listing_modal.dart';
import 'package:xdeal/models/vehicle_listing.dart' as model;

class VehicleListing extends StatefulWidget {
  final model.VehicleListing vehicle;
  final bool isDealerProfile;
  final bool isUploaderViewing;
  final VoidCallback? onListingChanged;
  const VehicleListing({
    super.key,
    required this.vehicle,
    required this.isDealerProfile,
    required this.isUploaderViewing,
    this.onListingChanged,
  });

  @override
  State<VehicleListing> createState() => _VehicleListingState();
}

class _VehicleListingState extends State<VehicleListing> {
  final PageController _pageController = PageController();

  late final FavoriteVehicleService favService = FavoriteVehicleService(
    ApiClient(baseUrl: 'http://10.0.2.2:5000'),
  );

  int _currentPage = 0;

  bool _isFavorite = false;
  bool _favLoading = false;
  String _location = '';

  Future<void> _loadFavoriteState() async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    try {
      final isFav = await favService.isFavorited(user, widget.vehicle.id);
      if (!mounted) return;
      setState(() => _isFavorite = isFav);
    } catch (_) {
      // ignore (or show snackbar)
    }
  }

  Future<void> _toggleFavoriteBackend() async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    if (_favLoading) return;
    setState(() => _favLoading = true);

    try {
      final newState = await favService.toggle(user, widget.vehicle.id);
      if (!mounted) return;
      setState(() => _isFavorite = newState);
    } catch (_) {
      // optional: show snackbar
    } finally {
      if (mounted) setState(() => _favLoading = false);
    }
  }

  void _handleListingTap() {
    if (!widget.isUploaderViewing) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              VehicleViewerScreen(vehicleId: widget.vehicle.id),
        ),
      );
    } else {
      showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return UserViewListingModal(
            listingType: 1,
            listingId: widget.vehicle.id,
          ); // reuse your screen widget here
        },
      ).then((changed) {
        if (changed == true) {
          widget.onListingChanged?.call();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // reverse geolocation
    UtilityFunctions.getLocationFromCoordinatesGoogle(
      widget.vehicle.coords[0],
      widget.vehicle.coords[1],
    ).then((loc) {
      if (mounted) setState(() => _location = loc);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavoriteState();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isOnSale = widget.vehicle.onSale;
    final bool isFeatured = widget.vehicle.isFeatured;
    final bool isSponsored = widget.vehicle.isSponsored;

    return InkWell(
      onTap: _handleListingTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // slide show
                  PageView.builder(
                    controller: _pageController,
                    itemCount: math.min(widget.vehicle.images.length, 3),
                    onPageChanged: (int index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final imageUrl = UtilityFunctions.resolveImageUrl(
                        widget.vehicle.images[index],
                      );
                      return Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.inputBg,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey,
                            size: 36,
                          ),
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
                      children: List.generate(
                        math.min(widget.vehicle.images.length, 3),
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
                    child: IconButton(
                      onPressed: _favLoading ? null : _toggleFavoriteBackend,
                      icon: _favLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                      color: AppColors.white,
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
                          isSponsored
                              ? context.tr("Sponsored")
                              : context.tr("Featured"),
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
                          context.tr("Sale"),
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
          const SizedBox(height: 12),
          // price
          Text(
            "${context.tr("USD")} ${UtilityFunctions.formatPrice(widget.vehicle.price)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppTheme.heading1,
            ),
          ),
          // name + model
          Text(
            widget.vehicle.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppTheme.heading2,
              color: AppColors.primary,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // category
          Text(
            widget.vehicle.categoryTitle ?? '',
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
                  UtilityFunctions.openMapsAtCoords(widget.vehicle.coords);
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
                    Text(
                      _location.isEmpty
                          ? context.tr("Loading location...")
                          : _location,
                    ),
                  ],
                ),
              ),
              Text(
                UtilityFunctions.formatDate(widget.vehicle.createdAt),
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
                width: 120,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  // color: AppColors.greyBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      widget.vehicle.year.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // kilometers
              Container(
                width: 120,
                height: 40,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  // color: AppColors.greyBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_road_outlined, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      (widget.vehicle.kilometers as num).toStringAsFixed(
                        (widget.vehicle.kilometers % 1 == 0) ? 0 : 1,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // condition
              Container(
                width: 120,
                height: 40,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  // color: AppColors.greyBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.vehicle.fuelType,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
                    widget.vehicle.userEmail ?? "no email",
                  ),
                  child: Container(
                    height: 40,
                    width: 120,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      // color: AppColors.greyBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email_outlined, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('Email'),
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
                  onTap: () => _showPhonePopup(context),
                  child: Container(
                    height: 40,
                    width: 120,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      // color: AppColors.greyBg,
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
                          context.tr('Call'),
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
                    widget.vehicle.userPhone ?? "no phone",
                  ),
                  child: Container(
                    width: 120,
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      // color: AppColors.greyBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Image.asset('assets/icons/whatsapp.png'),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _showPhonePopup(BuildContext context) {
    // Extracting the phone number for readability
    final String phoneNumber = widget.vehicle.userPhone ?? context.tr('No phone');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(context.tr("Contact Owner")),
          content: Text(
            '${context.tr("Would you like to call")} $phoneNumber?',
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.tr("Cancel"),
                style: const TextStyle(color: Colors.grey),
              ),
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
              child: Text(context.tr("Call Now")),
            ),
          ],
        );
      },
    );
  }
}
