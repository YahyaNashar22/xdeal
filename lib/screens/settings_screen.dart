import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xdeal/providers/user_provider.dart';
import 'package:xdeal/screens/on_boarding_screen.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/utility_functions.dart';
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

  Future<void> _logout() async {
    final preferences = await SharedPreferences.getInstance();

    // 1️⃣ Remove token from storage
    await preferences.remove('token');

    // 2️⃣ Clear user from provider
    if (!mounted) return;
    Provider.of<UserProvider>(context, listen: false).clearUser();

    // 3️⃣ Remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => OnBoardingScreen()),
      (route) => false,
    );
  }

  // TODO: Implement proper delete account
  void _deleteAccount() {
    debugPrint("delete account");
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }
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
                      child: Image.network(
                        UtilityFunctions.resolveImageUrl(user.profilePicture),
                        width: 100,
                        errorBuilder: (_, __, ___) => const SizedBox(
                          width: 100,
                          height: 100,
                          child: Icon(Icons.person),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user.fullName,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.mode_edit_outline_outlined,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // subscription card
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: AppColors.greyBg,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 32,
                      ),
                      child: Text(
                        user.plan == 'free' ? "Free Plan" : "Paid Plan",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
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
              Center(
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(256, 32),
                    backgroundColor: AppColors.greyBg,
                    foregroundColor: AppColors.primary,
                  ),
                  child: Text("Logout"),
                ),
              ),

              Center(
                child: ElevatedButton(
                  // TODO: implement proper logout
                  onPressed: _deleteAccount,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(256, 32),
                    backgroundColor: AppColors.red,
                  ),
                  child: Text("Delete Account"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
