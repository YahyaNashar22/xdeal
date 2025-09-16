import 'package:flutter/material.dart';
import 'package:xdeal/dummy_data.dart';
import 'package:xdeal/utils/app_colors.dart';

class Filters extends StatelessWidget {
  const Filters({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40, // set height for horizontal list
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: DummyData.propertyCategories.length + 1, // 👈 +1 for "All",
        itemBuilder: (context, index) {
          final label = index == 0
              ? "All"
              : DummyData.propertyCategories[index - 1]; // 👈 shift by 1

          return InkWell(
            onTap: () {
              debugPrint(label);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
