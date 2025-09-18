import 'package:flutter/material.dart';
import 'package:xdeal/screens/forgot_password_screen.dart';
import 'package:xdeal/screens/on_boarding_screen.dart';
import 'package:xdeal/screens/sign_up_screen.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/navigation_helper.dart';
import 'package:xdeal/utils/social_btn_builder.dart';
import 'package:xdeal/utils/text_field_builder.dart';
import 'package:xdeal/widgets/submit_btn.dart';

// TODO: input validation
// TODO: connect backend

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() {
    String email = emailController.text;
    String password = passwordController.text;

    debugPrint("Email: $email");
    debugPrint("Password: $password");
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Email
              buildTextField("Email", emailController),
              const SizedBox(height: 16),

              // Password
              buildTextField("Password", passwordController, obscureText: true),
              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text("Forgot Password ?"),
                ),
              ),
              const SizedBox(height: 16),

              // Sign In Button
              submitBtn(_onSignIn, "Sign in"),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  "Or sign in with",
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
              const SizedBox(height: 30),

              // Already have account
              Center(
                child: GestureDetector(
                  onTap: () {
                    navigateToReplacement(context, const SignUpScreen());
                  },
                  child: Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(
                      color: AppColors.secondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
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
        onPressed: () => navigateToReplacement(context, OnBoardingScreen()),
      ),
      title: Text(
        "Sign in",
        style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w500),
      ),
    );
  }
}
