import 'package:flutter/material.dart';
import 'package:xdeal/dummy_data.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/widgets/custom_appbar.dart';
import 'package:xdeal/widgets/settings_btn_navigate.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationAllowed = false;
  void _toggleNotifications(bool value) {
    setState(() {
      _isNotificationAllowed = value;
    });
  }

  // TODO: fetch real user from backend
  final user = DummyData.user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // app bar
              CustomAppbar(title: 'Settings'),
              const SizedBox(height: 24),
              // user info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(color: AppColors.greyBg),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(user['profile_picture'], width: 100),
                    ),
                    const SizedBox(width: 8),
                    Text(user['full_name'], style: TextStyle(fontSize: 22)),
                    Spacer(),
                    IconButton(
                      // TODO: Implement edit
                      onPressed: () {},
                      icon: Icon(Icons.mode_edit_outline_outlined, size: 32),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // subscription card
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        color: AppColors.greyBg,
                        elevation: 8,
                        shadowColor: AppColors.black,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 32,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['plan'] == 'free'
                                    ? "Free Plan"
                                    : "Paid Plan",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(64),
                                child: Card(
                                  color: AppColors.greyBgDarker,
                                  elevation: 4,
                                  shadowColor: AppColors.black,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    width: 200,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.watch_later_outlined,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Valid until Life time',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 5.5,
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(12),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.greyBgDarker,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(
                                100,
                              ), // only curve top-right
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // basic settings
              Container(
                padding: const EdgeInsets.all(8.0),
                width: double.infinity,
                decoration: BoxDecoration(color: AppColors.inputBg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Notifications", style: TextStyle(fontSize: 18)),
                        Switch(
                          value: _isNotificationAllowed,
                          onChanged: _toggleNotifications,
                        ),
                      ],
                    ),
                    SettingsBtnNavigate(
                      title: 'My Account',
                      onTap: () {
                        debugPrint("Tapped");
                      },
                    ),
                    SettingsBtnNavigate(
                      title: 'English',
                      onTap: () {
                        debugPrint("Tapped");
                      },
                    ),
                    SettingsBtnNavigate(
                      title: 'Saved Searches',
                      onTap: () {
                        debugPrint("Tapped");
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'Other',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
              const SizedBox(height: 12),
              // terms and policies
              Container(
                padding: const EdgeInsets.all(8.0),
                width: double.infinity,
                decoration: BoxDecoration(color: AppColors.inputBg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsBtnNavigate(title: 'About us', onTap: () {}),
                    SettingsBtnNavigate(title: 'Privacy Policy', onTap: () {}),
                    SettingsBtnNavigate(
                      title: 'Terms & Conditions',
                      onTap: () {},
                    ),
                    SettingsBtnNavigate(title: 'Help & Support', onTap: () {}),
                    SettingsBtnNavigate(title: 'Rate us', onTap: () {}),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
