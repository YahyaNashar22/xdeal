import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xdeal/models/ad.dart';
import 'package:xdeal/services/ads_service.dart';
import 'package:xdeal/services/api_client.dart';
import 'package:xdeal/utils/utility_functions.dart';
import 'package:xdeal/utils/app_colors.dart';

class AdsCarousel extends StatefulWidget {
  const AdsCarousel({super.key});

  @override
  State<AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  final PageController _pageController = PageController();
  late final AdsService _adsService = AdsService(
    ApiClient(baseUrl: 'https://xdeal.beproagency.com'),
  );
  int _currentPage = 0;
  Timer? _timer;
  List<Ad> _ads = [];

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  Future<void> _loadAds() async {
    try {
      final items = await _adsService.getAds(limit: 20);
      if (!mounted) return;
      setState(() => _ads = items);
      _startAutoSlide();
    } catch (_) {
      if (!mounted) return;
      setState(() => _ads = []);
    }
  }

  void _startAutoSlide() {
    _timer?.cancel();
    if (_ads.length <= 1) return;

    // auto-slide every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _ads.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(microseconds: 350),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_ads.isEmpty) const SizedBox.shrink(),
        if (_ads.isNotEmpty)
        SizedBox(
          height: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _ads.length,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Image.network(
                      UtilityFunctions.resolveImageUrl(_ads[index].image),
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
                    children: List.generate(_ads.length, (index) {
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
