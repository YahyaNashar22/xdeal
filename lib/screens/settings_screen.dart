import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:xdeal/providers/user_provider.dart';
import 'package:xdeal/screens/about_us_screen.dart';
import 'package:xdeal/screens/help_screen.dart';
import 'package:xdeal/screens/on_boarding_screen.dart';
import 'package:xdeal/screens/privacy_policy_screen.dart';
import 'package:xdeal/screens/terms_conditions_screen.dart';
import 'package:xdeal/services/auth_service.dart';
import 'package:xdeal/services/upload_service.dart';
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
  final ImagePicker _imagePicker = ImagePicker();
  late final UploadService _uploadService =
      UploadService(baseUrl: 'http://10.0.2.2:5000');

  // bool _isNotificationAllowed = false;
  // void _toggleNotifications(bool value) {
  //   setState(() {
  //     _isNotificationAllowed = value;
  //   });
  // }

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

  Future<void> _openEditAccountModal() async {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;
    if (user == null) return;

    final formKey = GlobalKey<FormState>();
    final fullNameCtrl = TextEditingController(text: user.fullName);
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    String selectedAvatarPath = user.profilePicture;
    XFile? selectedAvatarFile;
    bool saving = false;

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Edit My Account",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: AppColors.greyBg,
                              backgroundImage: selectedAvatarFile != null
                                  ? FileImage(
                                      File(selectedAvatarFile!.path),
                                    )
                                  : selectedAvatarPath.isNotEmpty
                                  ? Image.network(
                                      UtilityFunctions.resolveImageUrl(
                                        selectedAvatarPath,
                                      ),
                                    ).image
                                  : null,
                              child:
                                  selectedAvatarPath.isEmpty &&
                                  selectedAvatarFile == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            TextButton.icon(
                              onPressed: saving
                                  ? null
                                  : () async {
                                      final picked = await _imagePicker
                                          .pickImage(
                                            source: ImageSource.gallery,
                                            imageQuality: 80,
                                          );
                                      if (picked == null) return;
                                      setModalState(() {
                                        selectedAvatarFile = picked;
                                      });
                                    },
                              icon: const Icon(Icons.image_outlined),
                              label: const Text("Change Picture"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: fullNameCtrl,
                          decoration: const InputDecoration(
                            labelText: "Full Name",
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? "Name is required"
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: currentPassCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Current Password",
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: newPassCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "New Password",
                          ),
                          validator: (v) {
                            if (v != null && v.isNotEmpty && v.length < 6) {
                              return "Password must be at least 6 chars";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: confirmPassCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Confirm New Password",
                          ),
                          validator: (v) {
                            if (newPassCtrl.text.trim().isEmpty) return null;
                            if ((v ?? '').trim() != newPassCtrl.text.trim()) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: saving
                                    ? null
                                    : () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: saving
                                    ? null
                                    : () async {
                                        if (formKey.currentState?.validate() !=
                                            true) {
                                          return;
                                        }

                                        if (newPassCtrl.text.trim().isNotEmpty &&
                                            currentPassCtrl.text.trim().isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Current password is required to change password.",
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        setModalState(() => saving = true);
                                        try {
                                          String profilePicturePath =
                                              selectedAvatarPath;
                                          if (selectedAvatarFile != null) {
                                            profilePicturePath =
                                                await _uploadService
                                                    .uploadUserAvatar(
                                                      selectedAvatarFile!,
                                                    );
                                          }

                                          final updatedUser =
                                              await AuthService.updateCurrentUser(
                                                token: user.token,
                                                fullName: fullNameCtrl.text
                                                    .trim(),
                                                profilePicture: profilePicturePath,
                                                currentPassword: currentPassCtrl
                                                    .text
                                                    .trim(),
                                                newPassword: newPassCtrl.text
                                                    .trim(),
                                              );

                                          if (!mounted) return;
                                          userProvider.setUser(updatedUser);
                                          Navigator.of(this.context).pop(true);
                                        } catch (e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(
                                            this.context,
                                          ).showSnackBar(
                                            SnackBar(content: Text('$e')),
                                          );
                                          setModalState(() => saving = false);
                                        }
                                      },
                                child: saving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text("Save"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    Future<void> disposeControllersSafely() async {
      await Future<void>.delayed(const Duration(milliseconds: 220));
      fullNameCtrl.dispose();
      currentPassCtrl.dispose();
      newPassCtrl.dispose();
      confirmPassCtrl.dispose();
    }

    await disposeControllersSafely();

    if (submitted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account updated successfully.")),
      );
    }
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
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text("Notifications", style: TextStyle(fontSize: 18)),
                    //     Switch(
                    //       value: _isNotificationAllowed,
                    //       onChanged: _toggleNotifications,
                    //     ),
                    //   ],
                    // ),
                    SettingsBtnNavigate(
                      title: 'My Account',
                      onTap: () {
                        _openEditAccountModal();
                      },
                    ),
                    SettingsBtnNavigate(
                      title: 'English',
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
                    SettingsBtnNavigate(
                      title: 'About us',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AboutUsScreen(),
                          ),
                        );
                      },
                    ),
                    SettingsBtnNavigate(
                      title: 'Privacy Policy',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),
                    SettingsBtnNavigate(
                      title: 'Terms & Conditions',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TermsConditionsScreen(),
                          ),
                        );
                      },
                    ),
                    SettingsBtnNavigate(
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const HelpScreen(),
                          ),
                        );
                      },
                    ),
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
