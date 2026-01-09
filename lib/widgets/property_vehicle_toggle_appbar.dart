import 'package:flutter/material.dart';
import 'package:xdeal/theme/app_theme.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/widgets/notification_modal.dart';

class PropertyVehicleToggleAppbar extends StatelessWidget {
  final int selectedView;
  final Function selectView;
  const PropertyVehicleToggleAppbar({
    super.key,
    required this.selectedView,
    required this.selectView,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/images/avatar.png'),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: selectedView == 0
                ? AppTheme.primaryColor
                : AppTheme.textColor,
          ),
          onPressed: () => selectView(0),
          child: Text("Properties"),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: selectedView == 1
                ? AppTheme.primaryColor
                : AppTheme.textColor,
          ),
          onPressed: () => selectView(1),
          child: Text("Vehicles"),
        ),
        IconButton(
          icon: Icon(Icons.notifications, color: AppColors.primary),
          onPressed: () => showNotificationModal(context),
        ),
      ],
    );
  }
}
