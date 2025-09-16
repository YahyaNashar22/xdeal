import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xdeal/theme/app_theme.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/utility_functions.dart';

class PropertyListing extends StatefulWidget {
  final Map<String, dynamic> property;
  const PropertyListing({super.key, required this.property});

  @override
  State<PropertyListing> createState() => _PropertyListingState();
}

class _PropertyListingState extends State<PropertyListing> {
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
  void initState() {
    super.initState();
    // auto slide every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (_currentPage < widget.property['images'].length - 1) {
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
      widget.property['coords'][0],
      widget.property['coords'][1],
    ).then((loc) => setState(() => _location = loc));

    debugPrint(
      '${widget.property['coords'][0]}, ${widget.property['coords'][1]} ',
    );
    debugPrint('$_location ');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isOnSale = widget.property['on_sale'];
    final bool isFeatured = widget.property['is_featured'];
    final bool isSponsored = widget.property['is_sponsored'] || isFeatured;

    return Column(
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
                  itemCount: widget.property['images'].length,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Image.network(
                      widget.property['images'][index],
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
                    children: List.generate(widget.property['images'].length, (
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
        const SizedBox(height: 12),
        Text(UtilityFunctions.formatPrice(widget.property['price'])),
        Text(widget.property['name']),
        Text(widget.property['category']),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_location.isEmpty ? "Loading location..." : _location),
            Text(UtilityFunctions.formatDate(widget.property['createdAt'])),
          ],
        ),
      ],
    );
  }
}
