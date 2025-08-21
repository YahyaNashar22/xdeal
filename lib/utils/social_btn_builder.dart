// Reusable Social Button
import 'package:flutter/material.dart';
import 'package:xdeal/utils/app_colors.dart';

Widget buildSocialButton(String text, {VoidCallback? onPressed}) {
  return ElevatedButton(
    onPressed: onPressed ?? () => debugPrint(text),
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.inputBg,
      foregroundColor: AppColors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      elevation: 0,
    ),
    child: Text(text, style: const TextStyle(fontSize: 14)),
  );
}
