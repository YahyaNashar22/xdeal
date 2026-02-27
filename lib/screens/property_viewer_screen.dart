import 'dart:async';

import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import 'package:provider/provider.dart';
import 'package:xdeal/models/property_listing.dart';
import 'package:xdeal/providers/user_provider.dart';
import 'package:xdeal/screens/dealer_profile_screen.dart';
import 'package:xdeal/screens/full_screen_image_viewer.dart';
import 'package:xdeal/screens/full_screen_panorama.dart';
import 'package:xdeal/services/api_client.dart';
import 'package:xdeal/services/favorite_property_service.dart';
import 'package:xdeal/services/property_listing_service.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/utility_functions.dart';
import 'package:xdeal/widgets/notification_modal.dart';

class PropertyViewerScreen extends StatefulWidget {
  final String propertyId;
  const PropertyViewerScreen({super.key, required this.propertyId});

  @override
  State<PropertyViewerScreen> createState() => _PropertyViewerScreenState();
}

class _PropertyViewerScreenState extends State<PropertyViewerScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  PropertyListing? _property;
  bool _loading = true;
  String? _error;

  bool _isFavorite = false;
  bool _favLoading = false;
  String _location = '';
  bool _isExpanded = false;

  late final PropertyListingService _service = PropertyListingService(
    ApiClient(baseUrl: 'http://10.0.2.2:5000'),
  );

  late final FavoritePropertyService _favService = FavoritePropertyService(
    ApiClient(baseUrl: 'http://10.0.2.2:5000'),
  );

  @override
  void initState() {
    super.initState();
    _loadProperty();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFavoriteState());
  }

  Future<void> _loadProperty() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final p = await _service.getById(widget.propertyId);
      if (!mounted) return;

      setState(() {
        _property = p;
        _loading = false;
      });

      unawaited(_service.incrementViews(widget.propertyId));
      _startAutoSlide();

      if (p.coords.length >= 2) {
        final loc = await UtilityFunctions.getLocationFromCoordinatesGoogle(
          p.coords[0],
          p.coords[1],
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
      final isFav = await _favService.isFavorited(
        userId: user.id,
        propertyId: widget.propertyId,
      );
      if (!mounted) return;
      setState(() => _isFavorite = isFav);
    } catch (_) {}
  }

  Future<void> _toggleFavoriteBackend() async {
    final user = context.read<UserProvider>().user;
    if (user == null || _favLoading) return;

    setState(() => _favLoading = true);
    try {
      final next = await _favService.toggle(
        userId: user.id,
        propertyId: widget.propertyId,
      );
      if (!mounted) return;
      setState(() => _isFavorite = next);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _favLoading = false);
    }
  }

  void _startAutoSlide() {
    _timer?.cancel();
    final images = _property?.images ?? const <String>[];
    if (images.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      _currentPage = (_currentPage + 1) % images.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  void _showPhonePopup(BuildContext context, String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _loadingScaffold();
    }

    if (_error != null || _property == null) {
      return _errorScaffold();
    }

    final p = _property!;
    final isOnSale = p.onSale;
    final isFeatured = p.isFeatured;
    final isSponsored = p.isSponsored;
    final hasPanorama = (p.threeSixty ?? '').trim().isNotEmpty;

    void handleBottomNavTap(int index) {
      switch (index) {
        case 0:
          UtilityFunctions.launchEmail(p.userEmail ?? "no email");
          break;
        case 1:
          _showPhonePopup(context, p.userPhone ?? 'no phone');
          break;
        case 2:
          UtilityFunctions.launchWhatsApp(p.userPhone ?? "no phone");
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
                height: 220,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: p.images.length,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      itemBuilder: (context, index) {
                        final imageUrl = UtilityFunctions.resolveImageUrl(
                          p.images[index],
                        );
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullScreenImageViewer(
                                  images: p.images
                                      .map(UtilityFunctions.resolveImageUrl)
                                      .toList(),
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                          child: Image.network(
                            imageUrl,
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
                        children: List.generate(p.images.length, (index) {
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
                        onPressed: _favLoading ? null : _toggleFavoriteBackend,
                        icon: _favLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                        color: _isFavorite ? AppColors.primary : Colors.white,
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
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Price",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "\$${UtilityFunctions.formatPrice(p.price)}",
                      style: TextStyle(color: AppColors.primary, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () =>
                              UtilityFunctions.openMapsAtCoords(p.coords),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
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
                          UtilityFunctions.formatDate(p.createdAt),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _infoBox(
                          Icons.bed_outlined,
                          p.bedrooms.toStringAsFixed(
                            (p.bedrooms % 1 == 0) ? 0 : 1,
                          ),
                        ),
                        _infoBox(
                          Icons.bathtub_outlined,
                          p.bathrooms.toStringAsFixed(
                            (p.bathrooms % 1 == 0) ? 0 : 1,
                          ),
                        ),
                        _infoBox(
                          Icons.square_foot_outlined,
                          '${p.space % 1 == 0 ? p.space.toInt().toString() : p.space.toString()} m²',
                        ),
                      ],
                    ),
                    if (hasPanorama) ...[
                      const SizedBox(height: 24),
                      const Text(
                        "360° View",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 250,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: PanoramaViewer(
                                zoom: 1,
                                interactive: true,
                                child: Image.network(
                                  UtilityFunctions.resolveImageUrl(
                                    p.threeSixty!,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.fullscreen,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FullScreenPanorama(
                                        imageUrl:
                                            UtilityFunctions.resolveImageUrl(
                                              p.threeSixty!,
                                            ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableText(p.description),
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
                      spacing: 12,
                      runSpacing: 12,
                      children: p.extraFeatures.map((feature) {
                        return Container(
                          width: 140,
                          height: 50,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: AppColors.inputBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            feature,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 15),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.greyBg),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _ownerImage(p),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.userName ?? "Unknown",
                          style: const TextStyle(fontSize: 22),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    DealerProfileScreen(dealerId: p.userId),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                "See profile",
                                style: TextStyle(color: AppColors.primary),
                              ),
                              const Icon(Icons.arrow_forward_ios_outlined),
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

  Widget _ownerImage(PropertyListing p) {
    final raw = p.userProfilePicture;
    final hasImage = raw != null && raw.trim().isNotEmpty;
    if (!hasImage) {
      return Container(
        width: 100,
        height: 100,
        color: Colors.white,
        alignment: Alignment.center,
        child: const Icon(Icons.person, size: 42),
      );
    }
    return Image.network(
      UtilityFunctions.resolveImageUrl(raw),
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 100,
        height: 100,
        color: Colors.white,
        alignment: Alignment.center,
        child: const Icon(Icons.person, size: 42),
      ),
    );
  }

  Widget _infoBox(IconData icon, String value) {
    return Container(
      height: 42,
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.greyBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableText(String text) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(
          text: text,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        );
        final tp = TextPainter(
          text: span,
          maxLines: 2,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final overflowing = tp.didExceedMaxLines;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              maxLines: _isExpanded ? null : 2,
              overflow: _isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            if (overflowing || _isExpanded)
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    _isExpanded ? "Show Less" : "Read More",
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
    );
  }

  Widget _loadingScaffold() {
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
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _errorScaffold() {
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
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error ?? 'Failed to load', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadProperty,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
