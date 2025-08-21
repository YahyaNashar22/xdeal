import 'package:flutter/material.dart';
import 'package:xdeal/utils/app_colors.dart';

SizedBox submitBtn(Function onSubmit, String text) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        onSubmit();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(text, style: TextStyle(color: AppColors.white, fontSize: 16)),
    ),
  );
}
