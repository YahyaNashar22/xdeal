import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdeal/providers/user_provider.dart';
import 'package:xdeal/theme/app_theme.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/utility_functions.dart';
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
    final user = context.read<UserProvider>().user;

    final profileImage = (user?.profilePicture.isNotEmpty ?? false)
        ? Image.network(
            UtilityFunctions.resolveImageUrl(user!.profilePicture),
            width: 46,
            height: 46,
            errorBuilder: (_, __, ___) =>
                const SizedBox(width: 100, child: Icon(Icons.person)),
          )
        : Image.asset('assets/images/avatar.png');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        profileImage,
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
