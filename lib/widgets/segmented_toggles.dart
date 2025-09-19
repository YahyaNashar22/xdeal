import 'package:flutter/material.dart';
import 'package:xdeal/utils/app_colors.dart';

Widget buildSegmentedToggle({
  required int selectedIndex,
  required List<String> labels,
  required Function(int) onPressed,
}) {
  return Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: AppColors.greyBg,
      borderRadius: BorderRadius.circular(32),
    ),
    child: Row(
      children: List.generate(labels.length, (index) {
        final bool selected = selectedIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => onPressed(index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? Colors.white : AppColors.greyBg,
                borderRadius: BorderRadius.circular(32),
              ),
              alignment: Alignment.center,
              child: Text(
                labels[index],
                style: TextStyle(
                  color: selected ? AppColors.black : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    ),
  );
}
