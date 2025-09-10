import 'package:flutter/material.dart';
import 'package:xdeal/theme/app_theme.dart';

class PropertyVehicleToggleAppbar extends StatefulWidget {
  int selectedView;
  PropertyVehicleToggleAppbar({super.key, required this.selectedView});

  @override
  State<PropertyVehicleToggleAppbar> createState() =>
      _PropertyVehicleToggleAppbarState();
}

class _PropertyVehicleToggleAppbarState
    extends State<PropertyVehicleToggleAppbar> {
  void _selectView(int index) {
    setState(() {
      widget.selectedView = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/images/avatar.png'),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: widget.selectedView == 0
                ? AppTheme.primaryColor
                : AppTheme.textColor,
          ),
          onPressed: () => _selectView(0),
          child: Text("Properties"),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: widget.selectedView == 1
                ? AppTheme.primaryColor
                : AppTheme.textColor,
          ),
          onPressed: () => _selectView(1),
          child: Text("Vehicles"),
        ),
        Image.asset('assets/icons/logo_purple_large.png', width: 46),
      ],
    );
  }
}
