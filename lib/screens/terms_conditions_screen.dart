import 'package:flutter/material.dart';
import 'package:xdeal/utils/app_colors.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
              _TermsTopBar(title: 'Terms & Conditions'),
              SizedBox(height: 18),
              _TermsSection(
                title: 'Acceptance of Terms',
                body:
                    'By creating an account or using XDeal, you agree to these Terms & Conditions. If you do not agree, you should stop using the platform.',
              ),
              SizedBox(height: 14),
              _TermsSection(
                title: 'Use of Platform',
                body:
                    'XDeal provides a marketplace for listing and discovering vehicles and properties. Users are responsible for the accuracy of submitted information, legal compliance, and all interactions made through the app.',
              ),
              SizedBox(height: 14),
              _TermsSection(
                title: 'Account Responsibilities',
                body:
                    'You are responsible for keeping your account credentials secure and for all actions performed through your account. Impersonation, unauthorized access, or misuse is prohibited.',
              ),
              SizedBox(height: 14),
              _TermsSection(
                title: 'Listing Rules',
                body:
                    'Listings must be truthful, lawful, and not misleading. Prohibited content includes fraudulent posts, duplicate spam listings, unlawful items, or abusive content. XDeal may edit, suspend, or remove violating listings.',
              ),
              SizedBox(height: 14),
              _TermsSection(
                title: 'Transactions and Liability',
                body:
                    'XDeal is a facilitation platform and is not a party to transactions between buyers and sellers. Users are responsible for due diligence, negotiation, and final transaction terms.',
              ),
              SizedBox(height: 14),
              _TermsSection(
                title: 'Intellectual Property',
                body:
                    'All app branding, UI, and platform assets are protected. By uploading content, you grant XDeal a limited license to display and distribute your listing content for platform operation.',
              ),
              SizedBox(height: 14),
              _TermsSection(
                title: 'Termination',
                body:
                    'We may suspend or terminate accounts that violate these terms, harm other users, or compromise platform security.',
              ),
              SizedBox(height: 14),
              _TermsSection(
                title: 'Changes to Terms',
                body:
                    'These terms may be updated from time to time. Continued use of XDeal after updates means you accept the revised terms.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsTopBar extends StatelessWidget {
  final String title;
  const _TermsTopBar({required this.title});

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

class _TermsSection extends StatelessWidget {
  final String title;
  final String body;
  const _TermsSection({required this.title, required this.body});

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
            title,
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
