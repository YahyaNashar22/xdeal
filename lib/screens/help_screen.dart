import 'package:flutter/material.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/utility_functions.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HelpTopBar(title: 'Help & Support'),
              const SizedBox(height: 16),
              _supportCard(
                icon: Icons.contact_support_outlined,
                title: 'Need Assistance?',
                body:
                    'Our support team is here to help with account issues, listing management, and general app usage.',
              ),
              const SizedBox(height: 12),
              _actionTile(
                icon: Icons.email_outlined,
                title: 'Email Support',
                subtitle: 'xdeal.application@gmail.com',
                onTap: () => UtilityFunctions.launchEmail('support@xdeal.app'),
              ),
              const SizedBox(height: 8),
              _actionTile(
                icon: Icons.phone_forwarded_outlined,
                title: 'Call Support',
                subtitle: '+961 71 566 122',
                onTap: () => UtilityFunctions.launchCall('+96171566122'),
              ),
              const SizedBox(height: 8),
              _actionTile(
                icon: Icons.chat_outlined,
                title: 'WhatsApp Support',
                subtitle: '+961 71 566 122',
                onTap: () => UtilityFunctions.launchWhatsApp('+96171566122'),
              ),
              const SizedBox(height: 18),
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const _FaqItem(
                q: 'How do I create a listing?',
                a: 'Go to the create listing flow, choose property or vehicle, fill all required details, upload images, set location, then publish.',
              ),
              const SizedBox(height: 8),
              const _FaqItem(
                q: 'How do I edit or remove my listing?',
                a: 'Open My Listings, tap the listing options, then choose edit, mark listed/not listed, or delete.',
              ),
              const SizedBox(height: 8),
              const _FaqItem(
                q: 'How does favorite work?',
                a: 'Tap the heart icon on a listing to add or remove it from favorites. Your saved favorites are available in the favorites section.',
              ),
              const SizedBox(height: 8),
              const _FaqItem(
                q: 'Why can not I see exact location?',
                a: 'Some listings may show generalized map areas for privacy and safety. Contact the seller for exact details when appropriate.',
              ),
              const SizedBox(height: 8),
              const _FaqItem(
                q: 'How can I report suspicious listings?',
                a: 'Please contact support and include listing details/screenshots. We review reports and take moderation action where required.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _supportCard({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.greyBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyBgDarker),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.4,
                    color: AppColors.black.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.greyBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.greyBgDarker),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.black.withValues(alpha: 0.7),
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _HelpTopBar extends StatelessWidget {
  final String title;
  const _HelpTopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        Text(
          title,
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

class _FaqItem extends StatelessWidget {
  final String q;
  final String a;
  const _FaqItem({required this.q, required this.a});

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
            q,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            a,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.42,
              color: AppColors.black.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
