import 'package:flutter/material.dart';
import 'package:xdeal/widgets/custom_appbar.dart';

class AddListingModal extends StatelessWidget {
  const AddListingModal({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          CustomAppbar(title: "Add Listing"),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 40),
              ),
              onPressed: () {},
              child: Text("Add Property"),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 40),
              ),
              onPressed: () {},
              child: Text("Add Vehicle"),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
