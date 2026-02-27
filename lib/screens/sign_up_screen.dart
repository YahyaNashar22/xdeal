import 'package:flutter/material.dart';
import 'package:xdeal/localization/app_localizations.dart';
import 'package:xdeal/screens/on_boarding_screen.dart';
import 'package:xdeal/screens/otp_screen.dart';
import 'package:xdeal/screens/sign_in_screen.dart';
import 'package:xdeal/services/auth_service.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/navigation_helper.dart';
import 'package:xdeal/utils/social_btn_builder.dart';
import 'package:xdeal/utils/text_field_builder.dart';
import 'package:xdeal/widgets/submit_btn.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final addressController = TextEditingController();
  final countryCodeController = TextEditingController();
  final phoneController = TextEditingController();

  bool agree = false;
  bool isLoading = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    addressController.dispose();
    countryCodeController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _onSignUp() async {
    if (!agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr("You must agree to the terms"))),
      );
      return;
    }

    String fullName = fullNameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String address = addressController.text.trim();
    String phone =
        "${countryCodeController.text.trim()}${phoneController.text.trim()}";

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              "Please fill in the full name, email, password, and phone number",
            ),
          ),
        ),
      );
      return;
    }

    final userData = {
      "full_name": fullName,
      "email": email,
      "password": password,
      "address": address,
      "phone": phone,
    };

    setState(() => isLoading = true);

    try {
      await AuthService.sendOtp(userData["email"]!);

      if (!mounted) return;
      navigateToReplacement(context, OtpScreen(userData: userData));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _appBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Full Name
              buildTextField(context, "Full Name", fullNameController),
              const SizedBox(height: 16),

              // Email
              buildTextField(context, "Email", emailController),
              const SizedBox(height: 16),

              // Password
              buildTextField(context, "Password", passwordController, obscureText: true),
              const SizedBox(height: 16),

              // Address
              buildTextField(context, "Address", addressController),
              const SizedBox(height: 16),

              // Phone Row
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: buildTextField(context, "+961", countryCodeController),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildTextField(context, "Phone Number", phoneController),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Terms and Conditions
              Row(
                children: [
                  Checkbox(
                    value: agree,
                    onChanged: (val) {
                      setState(() {
                        agree = val ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      context.tr("I agree to the terms and conditions"),
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sign Up Button
              isLoading
                  ? SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: CircularProgressIndicator(),
                    )
                  : submitBtn(_onSignUp, "Sign up"),

              const SizedBox(height: 20),

              // TODO: IMPLEMENT THESE LATER ON
              // Center(
              //   child: Text(
              //     "Or sign up with",
              //     style: TextStyle(color: AppColors.black),
              //   ),
              // ),
              // const SizedBox(height: 20),

              // // Social Buttons
              // Wrap(
              //   spacing: 12,
              //   runSpacing: 12,
              //   alignment: WrapAlignment.center,
              //   children: [
              //     buildSocialButton("Facebook"),
              //     buildSocialButton("Google"),
              //     buildSocialButton("Apple IOS"),
              //     buildSocialButton("Phone Number"),
              //   ],
              // ),
              const SizedBox(height: 20),

              // Already have account
              Center(
                child: GestureDetector(
                  onTap: () {
                    navigateToReplacement(context, const SignInScreen());
                  },
                  child: Text(
                    context.tr("Already have an account? Sign in"),
                    style: TextStyle(
                      color: AppColors.secondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Image.asset('assets/icons/logo_purple_large.png'),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.black),
        onPressed: () =>
            navigateToReplacement(context, const OnBoardingScreen()),
      ),
      title: Text(
        context.tr("Sign up"),
        style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w500),
      ),
    );
  }
}
