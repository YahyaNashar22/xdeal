import 'package:flutter/material.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/widgets/custom_appbar.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [CustomAppbar(title: "Favorites")]),
        ),
      ),
    );
  }
}
