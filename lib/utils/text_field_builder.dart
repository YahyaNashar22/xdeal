// Reusable TextField Widget
import 'package:flutter/material.dart';
import 'package:xdeal/localization/app_localizations.dart';
import 'package:xdeal/utils/app_colors.dart';

Widget buildTextField(
  BuildContext context,
  String hint,
  TextEditingController controller, {
  bool obscureText = false,
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    decoration: InputDecoration(
      hintText: hint.startsWith("+")
          ? hint
          : AppLocalizations.of(context).translate(hint),
      filled: true,
      fillColor: AppColors.inputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
