import 'package:flutter/material.dart';
import 'package:xdeal/utils/app_colors.dart';

class VehicleOption extends StatelessWidget {
  final String optionName;
  final dynamic optionValue;
  const VehicleOption({
    super.key,
    required this.optionName,
    required this.optionValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: BoxBorder.all(color: AppColors.greyBg),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(optionName, style: TextStyle(fontSize: 16)),
          Text(optionValue.toString(), style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
