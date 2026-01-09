import 'package:flutter/material.dart';

void navigateToReplacement(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
}
