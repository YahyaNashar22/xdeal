import 'package:flutter/material.dart';
import 'package:xdeal/screens/sign_in_screen.dart';
import 'package:xdeal/screens/sign_up_screen.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/widgets/on_boarding_button.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Image.asset('assets/icons/logo_on_boarding.png'),
              ),

              Text(
                "Welcome",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),

              const SizedBox(height: 30),

              // Sign In button
              onBoardingButton(context, SignInScreen(), "Sign In"),

              const SizedBox(height: 16),

              // Sign Up button
              onBoardingButton(context, SignUpScreen(), "Sign Up"),

              const SizedBox(height: 24),

              // Continue as Guest button (smaller)
              onBoardingButton(
                context,
                SignUpScreen(),
                "Continue as Guest",
                width: 180,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
