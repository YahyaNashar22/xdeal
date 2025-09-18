import 'package:flutter/material.dart';

class SettingsBtnNavigate extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const SettingsBtnNavigate({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 18)),
        IconButton(onPressed: onTap, icon: Icon(Icons.arrow_forward_ios)),
      ],
    );
  }
}
