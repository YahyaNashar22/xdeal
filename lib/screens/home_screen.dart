import 'package:flutter/material.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/widgets/property_vehicle_toggle_appbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  final int selectedView = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [PropertyVehicleToggleAppbar(selectedView: selectedView)],
          ),
        ),
      ),
    );
  }
}
