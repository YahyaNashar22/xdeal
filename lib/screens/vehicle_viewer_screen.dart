import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:xdeal/models/vehicle_listing.dart';
import 'package:xdeal/providers/user_provider.dart';
import 'package:xdeal/services/api_client.dart';
import 'package:xdeal/services/favorite_vehicle_service.dart';
import 'package:xdeal/services/vehicle_listing_service.dart';

import 'package:xdeal/screens/dealer_profile_screen.dart';
import 'package:xdeal/screens/full_screen_image_viewer.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/utility_functions.dart';
import 'package:xdeal/widgets/listing_map_preview.dart';
import 'package:xdeal/widgets/notification_modal.dart';
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

  // backend state
  VehicleListing? _vehicle;
  bool _loading = true;
  String? _error;

  bool _isFavorite = false;
  String _location = '';
  bool isExpanded = false;

  // inject your ApiClient however you do it in the app (Provider/GetIt/etc).
  // For now: create it here (replace with your real instance).
  late final VehicleListingService _service = VehicleListingService(
    ApiClient(baseUrl: 'http://10.0.2.2:5000'),
  );

  late final FavoriteVehicleService favService = FavoriteVehicleService(
    ApiClient(baseUrl: 'http://10.0.2.2:5000'),
  );

  bool _favLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVehicle();
    // after vehicle load, you can check favorite:
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFavoriteState());
  }

  Future<void> _loadVehicle() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final v = await _service.getById(widget.vehicleId);

      if (!mounted) return;

      setState(() {
        _vehicle = v;
        _loading = false;
      });

      unawaited(_service.incrementViews(widget.vehicleId));

      _startAutoSlide();

      // reverse geolocation
      if (v.coords.length >= 2) {
        final loc = await UtilityFunctions.getLocationFromCoordinatesGoogle(
          v.coords[0],
          v.coords[1],
        );
        if (mounted) setState(() => _location = loc);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadFavoriteState() async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    try {
      final isFav = await favService.isFavorited(user, widget.vehicleId);
      if (!mounted) return;
      setState(() => _isFavorite = isFav);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating, // Makes it look modern
        ),
      );
    }
  }

  Future<void> toggleFavoriteBackend() async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    if (_favLoading) return;
    setState(() => _favLoading = true);

    try {
      final newState = await favService.toggle(user, widget.vehicleId);
      if (!mounted) return;
      setState(() => _isFavorite = newState);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating, // Makes it look modern
        ),
      );
    } finally {
      if (mounted) setState(() => _favLoading = false);
    }
  }

  void _startAutoSlide() {
    _timer?.cancel();

    final images = _vehicle?.images ?? const <String>[];
    if (images.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (!mounted) return;
      final len = images.length;
      _currentPage = (_currentPage + 1) % len;

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _showPhonePopup(BuildContext context, String phoneNumber) {
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
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
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: AppColors.black),
          ),
          title: Text(
            'Vehicle Viewer',
            style: TextStyle(color: AppColors.black),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: AppColors.black),
          ),
          title: Text(
            'Vehicle Viewer',
            style: TextStyle(color: AppColors.black),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadVehicle,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final v = _vehicle!;
    final bool isOnSale = v.onSale == true;
    final bool isFeatured = v.isFeatured == true;
    final bool isSponsored = v.isSponsored == true;

    void handleBottomNavTap(int index) {
      switch (index) {
        case 0:
          UtilityFunctions.launchEmail(v.userEmail ?? "no email");
          break;
        case 1:
          _showPhonePopup(context, v.userPhone ?? 'no phone');
          break;
        case 2:
          UtilityFunctions.launchWhatsApp(v.userPhone ?? "no phone");
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
        actions: [
          IconButton(
            onPressed: () => showNotificationModal(context),
            icon: Icon(Icons.notifications, color: AppColors.primary),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: handleBottomNavTap,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.email_outlined),
            label: 'Email',
          ),
          const BottomNavigationBarItem(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200,
                child: ClipRRect(
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: v.images.length,
                        onPageChanged: (int index) {
                          setState(() => _currentPage = index);
                        },
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImageViewer(
                                    images: v.images,
                                    initialIndex: index,
                                  ),
                                ),
                              );
                            },
                            child: Image.network(
                              v.images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(v.images.length, (index) {
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
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: IconButton(
                          onPressed: toggleFavoriteBackend,
                          icon: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          color: _isFavorite ? AppColors.primary : null,
                        ),
                      ),
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

              // ...keep the rest of your UI exactly the same,
              // but replace `_vehicle!['field']` with `v.field`
              // and `owner_id` with `v.ownerId` etc.
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
                      "\$${UtilityFunctions.formatPrice(_vehicle!.price)}",
                      style: TextStyle(color: AppColors.primary, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    // name
                    Text(
                      _vehicle!.name,
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
                            UtilityFunctions.openMapsAtCoords(_vehicle!.coords);
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
                          UtilityFunctions.formatDate(_vehicle!.createdAt),
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
                                  _vehicle!.year,
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
                                  _vehicle!.fuelType,
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
                                  _vehicle!.kilometers.toString(),
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
                                  _vehicle!.condition,
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
                                  _vehicle!.transmissionType,
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
                      optionValue: _vehicle!.brand,
                    ),
                    const SizedBox(height: 12),
                    VehicleOption(
                      optionName: "Color",
                      optionValue: _vehicle!.color,
                    ),
                    const SizedBox(height: 12),
                    VehicleOption(
                      optionName: "Brand",
                      optionValue: _vehicle!.brand,
                    ),
                    const SizedBox(height: 12),
                    VehicleOption(
                      optionName: "Number of doors",
                      optionValue: _vehicle!.numberOfDoors,
                    ),
                    const SizedBox(height: 12),
                    VehicleOption(
                      optionName: "Model",
                      optionValue: _vehicle!.model,
                    ),
                    const SizedBox(height: 12),
                    VehicleOption(
                      optionName: "Number of Seats",
                      optionValue: _vehicle!.numberOfSeats,
                    ),
                    const SizedBox(height: 12),
                    VehicleOption(
                      optionName: "Air Conditioning",
                      optionValue: _vehicle!.airConditioning,
                    ),
                    const SizedBox(height: 12),
                    VehicleOption(
                      optionName: "Interior",
                      optionValue: _vehicle!.interior,
                    ),
                    const SizedBox(height: 12),
                    VehicleOption(
                      optionName: "Body Type",
                      optionValue: _vehicle!.bodyType,
                    ),
                    const SizedBox(height: 12),
                    VehicleOption(
                      optionName: "Payment Option",
                      optionValue: _vehicle!.paymentOption,
                    ),
                    const SizedBox(height: 24),
                    // Description
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Create a TextPainter to calculate the size of the text
                        final span = TextSpan(
                          text: _vehicle!.description,
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
                              _vehicle!.description,
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
                      itemCount: _vehicle!.extraFeatures.length,
                      itemBuilder: (context, index) {
                        final String feature = _vehicle!.extraFeatures[index];

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
                        onPressed: toggleFavoriteBackend,
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
                        "http://10.0.2.2:5000${_vehicle!.userProfilePicture!}",
                        width: 100,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _vehicle!.userName ?? "Unknown",
                          style: TextStyle(fontSize: 24),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DealerProfileScreen(
                                  dealerId: _vehicle!.userId,
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
