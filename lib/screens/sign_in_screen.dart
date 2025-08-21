import 'package:flutter/material.dart';
import 'package:xdeal/screens/on_boarding_screen.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/navigation_helper.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
          "Sign in",
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(child: SingleChildScrollView(child: Column())),
    );
  }
}
