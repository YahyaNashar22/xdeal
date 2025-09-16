import 'package:flutter/material.dart';
import 'package:xdeal/utils/app_colors.dart';

class Filters extends StatelessWidget {
  final List<String> filters;
  const Filters({super.key, required this.filters});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40, // set height for horizontal list
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length + 1, // 👈 +1 for "All",
        itemBuilder: (context, index) {
          final label = index == 0
              ? "All"
              : filters[index - 1]; // 👈 shift by 1

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
