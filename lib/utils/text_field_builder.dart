// Reusable TextField Widget
import 'package:flutter/material.dart';
import 'package:xdeal/utils/app_colors.dart';

Widget buildTextField(
  String hint,
  TextEditingController controller, {
  bool obscureText = false,
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.inputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
