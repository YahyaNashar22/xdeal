import 'package:flutter/material.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/widgets/custom_appbar.dart';

class CreateCarListingScreen extends StatefulWidget {
  const CreateCarListingScreen({super.key});

  @override
  State<CreateCarListingScreen> createState() => _CreateCarListingScreenState();
}

class _CreateCarListingScreenState extends State<CreateCarListingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [CustomAppbar(title: "Create a Car Listing")],
          ),
        ),
      ),
    );
  }
}
