import 'package:flutter/material.dart';

void showNotificationModal(BuildContext context) {
  showBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16),
        height: double.infinity,
        child: Center(
          child: TextButton(
            child: Text("Notification Modal"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    },
  );
}
