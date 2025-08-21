import 'package:flutter/material.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/navigation_helper.dart';

SizedBox onBoardingButton(
  BuildContext context,
  Widget screen,
  String text, {
  double width = 220,
}) {
  return SizedBox(
    width: width,
    child: ElevatedButton(
      onPressed: () {
        navigateToReplacement(context, screen);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(text),
    ),
  );
}
