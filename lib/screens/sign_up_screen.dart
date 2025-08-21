import 'package:flutter/material.dart';
import 'package:xdeal/screens/on_boarding_screen.dart';
import 'package:xdeal/screens/sign_in_screen.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/navigation_helper.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool agree = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => navigateToReplacement(context, OnBoardingScreen()),
        ),
        title: Text(
          "Sign up",
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email
              _buildTextField("Email"),
              const SizedBox(height: 16),

              // Password
              _buildTextField("Password", obscureText: true),
              const SizedBox(height: 16),

              // Address
              _buildTextField("Address"),
              const SizedBox(height: 16),

              // Phone Row
              Row(
                children: [
                  SizedBox(width: 80, child: _buildTextField("+961")),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField("Phone Number")),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // your purple
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "Sign up",
                    style: TextStyle(color: AppColors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  "Or sign up with",
                  style: TextStyle(color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 20),

              // Social Buttons
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildSocialButton("Facebook"),
                  _buildSocialButton("Google"),
                  _buildSocialButton("Apple IOS"),
                  _buildSocialButton("Phone Number"),
                ],
              ),

              const SizedBox(height: 30),

              // Already have account
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
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
            ],
          ),
        ),
      ),
    );
  }

  // Reusable TextField Widget
  Widget _buildTextField(String hint, {bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Reusable Social Button
  Widget _buildSocialButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}
