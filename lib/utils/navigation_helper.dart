import 'package:flutter/material.dart';

void navigateToReplacement(BuildContext context, Widget screen) {
  Navigator.of(
    context,
  ).pushReplacement(MaterialPageRoute(builder: (context) => screen));
}
