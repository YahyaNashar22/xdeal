import 'package:flutter/material.dart';

class AddListingsScreen extends StatelessWidget {
  const AddListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Center(child: Text("Add Listings Screen")),
        ),
      ),
    );
  }
}
