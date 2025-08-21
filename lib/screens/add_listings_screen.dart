import 'package:flutter/material.dart';
import 'package:xdeal/utils/app_colors.dart';

class AddListingsScreen extends StatelessWidget {
  const AddListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Center(child: Text("Add Listings Screen")),
        ),
      ),
    );
  }
}
