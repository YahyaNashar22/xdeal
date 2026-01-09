import 'package:flutter/material.dart';
import 'package:xdeal/screens/on_boarding_screen.dart';
import 'package:xdeal/theme/app_theme.dart';

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
    void logout() {
      // TODO: implement proper logout
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => OnBoardingScreen()));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(onTap: logout, child: Image.asset('assets/images/avatar.png')),
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
        Image.asset('assets/icons/logo_purple_large.png', width: 46),
      ],
    );
  }
}
