import 'package:flutter/material.dart';
import 'package:xdeal/screens/on_boarding_screen.dart';
import 'package:xdeal/screens/sign_in_screen.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/navigation_helper.dart';
import 'package:xdeal/utils/social_btn_builder.dart';
import 'package:xdeal/utils/text_field_builder.dart';
import 'package:xdeal/widgets/submit_btn.dart';

// TODO: input validation
// TODO: connect backend

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final addressController = TextEditingController();
  final countryCodeController = TextEditingController();
  final phoneController = TextEditingController();

  bool agree = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    addressController.dispose();
    countryCodeController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _onSignUp() {
    String email = emailController.text;
    String password = passwordController.text;
    String address = addressController.text;
    String countryCode = countryCodeController.text;
    String phone = phoneController.text;

    debugPrint("Email: $email");
    debugPrint("Password: $password");
    debugPrint("Address: $address");
    debugPrint("Country Code: $countryCode");
    debugPrint("Phone: $phone");
    debugPrint("Agree: $agree");
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
              // Email
              buildTextField("Email", emailController),
              const SizedBox(height: 16),

              // Password
              buildTextField("Password", passwordController, obscureText: true),
              const SizedBox(height: 16),

              // Address
              buildTextField("Address", addressController),
              const SizedBox(height: 16),

              // Phone Row
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: buildTextField("+961", countryCodeController),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildTextField("Phone Number", phoneController),
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
                  const Expanded(
                    child: Text(
                      "I agree to the terms and conditions",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sign Up Button
              submitBtn(_onSignUp, "Sign up"),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  "Or sign up with",
                  style: TextStyle(color: AppColors.black),
                ),
              ),
              const SizedBox(height: 20),

              // Social Buttons
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  buildSocialButton("Facebook"),
                  buildSocialButton("Google"),
                  buildSocialButton("Apple IOS"),
                  buildSocialButton("Phone Number"),
                ],
              ),

              const SizedBox(height: 20),

              // Already have account
              Center(
                child: GestureDetector(
                  onTap: () {
                    navigateToReplacement(context, const SignInScreen());
                  },
                  child: Text(
                    "Already have an account? Sign in",
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
        "Sign up",
        style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w500),
      ),
    );
  }
}
