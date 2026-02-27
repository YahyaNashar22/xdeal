import 'package:flutter/material.dart';
import 'package:xdeal/localization/app_localizations.dart';
import 'package:xdeal/utils/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _PolicyTopBar(title: 'Privacy Policy'),
              SizedBox(height: 18),
              _PolicySection(
                title: 'Introduction',
                body:
                    'XDeal is committed to protecting your privacy. This Privacy Policy explains what information we collect, how we use it, and your choices when using our platform for real estate and vehicle listings.',
              ),
              SizedBox(height: 14),
              _PolicySection(
                title: 'Information We Collect',
                body:
                    'We may collect account details (such as name, email, and phone number), listing information, images you upload, location data used for map and nearby search features, and basic app usage data required for service reliability.',
              ),
              SizedBox(height: 14),
              _PolicySection(
                title: 'How We Use Information',
                body:
                    'Your data is used to operate your account, publish and manage listings, connect buyers and sellers, improve search relevance, prevent fraud, and provide support. We only process data needed to run and improve the service.',
              ),
              SizedBox(height: 14),
              _PolicySection(
                title: 'Sharing of Data',
                body:
                    'We do not sell personal information. Listing-related public information (such as contact and listing details) is visible to users when you publish a listing. Service providers may process data on our behalf for hosting, analytics, and notifications.',
              ),
              SizedBox(height: 14),
              _PolicySection(
                title: 'Security',
                body:
                    'We implement reasonable technical and organizational safeguards to protect user data. However, no online platform can guarantee absolute security, so users should also take precautions such as protecting login credentials.',
              ),
              SizedBox(height: 14),
              _PolicySection(
                title: 'Data Retention',
                body:
                    'We retain account and listing data while your account is active and as required for legal, operational, and fraud-prevention purposes. You may request account deletion subject to applicable legal obligations.',
              ),
              SizedBox(height: 14),
              _PolicySection(
                title: 'Your Rights',
                body:
                    'You may update your account details, edit or remove listings, and contact support to request access or deletion where applicable. If local law grants additional rights, we will honor those rights as required.',
              ),
              SizedBox(height: 14),
              _PolicySection(
                title: 'Policy Updates',
                body:
                    'We may update this policy periodically. Material changes will be reflected in the app. Continued use of XDeal after updates means you acknowledge the revised policy.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicyTopBar extends StatelessWidget {
  final String title;
  const _PolicyTopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        Text(
          context.tr(title),
          style: TextStyle(
            color: AppColors.black,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;
  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.greyBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyBgDarker),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(title),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              color: AppColors.black.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
