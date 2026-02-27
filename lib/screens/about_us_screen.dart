import 'package:flutter/material.dart';
import 'package:xdeal/screens/screen_selector.dart';
import 'package:xdeal/utils/app_colors.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const String _heroImageUrl =
      'https://images.unsplash.com/photo-1460317442991-0ec209397118?auto=format&fit=crop&w=1200&q=80';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              _buildHero(context),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionBlock(
                      title: 'Our Story',
                      body:
                          'Born from a vision to simplify and secure the process of buying and selling cars and properties, XDeal was created to empower individuals with smart tools, real-time analytics, and direct communication - all in one powerful app. We saw a need for a more transparent and user-friendly platform, and XDeal is our answer.',
                    ),
                    SizedBox(height: 28),
                    _SectionBlock(
                      title: 'Our Mission',
                      body:
                          'To transform the way people find, list, and trade high-value assets by providing a trusted, transparent, and easy-to-use digital marketplace. We are committed to making every transaction smoother and more secure.',
                    ),
                    SizedBox(height: 28),
                    _FeatureSection(
                      title: 'What We Offer',
                      items: [
                        _FeatureItem(Icons.home_outlined, 'Verified Listings'),
                        _FeatureItem(
                          Icons.location_on_outlined,
                          'Real-Time Map',
                        ),
                        _FeatureItem(
                          Icons.chat_bubble_outline,
                          'Secure Messaging',
                        ),
                        _FeatureItem(
                          Icons.verified_user_outlined,
                          'Admin-Verified Posts',
                        ),
                        _FeatureItem(Icons.apple, 'Login via Apple/Google'),
                        _FeatureItem(
                          Icons.star_border,
                          'Buyer & Seller Ratings',
                        ),
                        _FeatureItem(Icons.show_chart, 'Analytics Dashboard'),
                      ],
                    ),
                    SizedBox(height: 28),
                    _FeatureSection(
                      title: 'Why Choose XDeal?',
                      items: [
                        _FeatureItem(
                          Icons.ads_click_outlined,
                          'Intuitive User Experience',
                        ),
                        _FeatureItem(Icons.shield_outlined, 'Verified Sellers'),
                        _FeatureItem(
                          Icons.place_outlined,
                          'Location-Based Search',
                        ),
                        _FeatureItem(Icons.attach_money, 'Transparent Pricing'),
                        _FeatureItem(
                          Icons.format_list_bulleted,
                          'Powerful Listing Tools',
                        ),
                      ],
                    ),
                    SizedBox(height: 28),
                    _SectionBlock(
                      title: 'Our Vision',
                      body:
                          'We aim to become the most trusted and efficient peer-to-peer marketplace in the region for vehicles and real estate - powered by innovation and community trust. Our goal is to be the go-to platform for anyone looking to buy or sell with confidence.',
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

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: const Color(0xFFF1EFF6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          const Text(
            'About Us',
            style: TextStyle(fontSize: 32 / 1.5, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Image.asset('assets/icons/logo_purple_large.png', width: 52),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return SizedBox(
      height: 480,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _heroImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF1A2F58)),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.45)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Your Gateway to\nSmarter Property &\nCar Deals',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48 / 1.5,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Simplifying the buying/selling journey with security,\nspeed, and transparency.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => ScreenSelector()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Explore Listings',
                    style: TextStyle(
                      fontSize: 22 / 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final String title;
  final String body;
  const _SectionBlock({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w800,
            fontSize: 38 / 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: TextStyle(
            color: AppColors.black.withValues(alpha: 0.85),
            fontSize: 17,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _FeatureSection extends StatelessWidget {
  final String title;
  final List<_FeatureItem> items;
  const _FeatureSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w800,
            fontSize: 38 / 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map((e) => _FeatureCard(item: e)).toList(),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem item;
  const _FeatureCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 42) / 2,
      child: Container(
        constraints: const BoxConstraints(minHeight: 82),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.greyBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.greyBgDarker),
        ),
        child: Row(
          children: [
            Icon(item.icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.text,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 31 / 2,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String text;
  const _FeatureItem(this.icon, this.text);
}
