import 'package:flutter/material.dart';
import 'package:xdeal/dummy_data.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/utility_functions.dart';

class DealerProfileScreen extends StatefulWidget {
  final String dealerId;
  const DealerProfileScreen({super.key, required this.dealerId});

  @override
  State<DealerProfileScreen> createState() => _DealerProfileScreenState();
}

class _DealerProfileScreenState extends State<DealerProfileScreen> {
  Map<String, dynamic>? _dealer;

  @override
  void initState() {
    super.initState();
    // TODO: fetch dealer based on id and set it
    setState(() {
      _dealer = DummyData.owner;
    });
  }

  @override
  Widget build(BuildContext context) {
    void handleBottomNavTap(int index) {
      switch (index) {
        case 0:
          UtilityFunctions.launchEmail(_dealer!['email']);
          break;
        case 1:
          UtilityFunctions.launchCall(_dealer!['phone']);
          break;
        case 2:
          UtilityFunctions.launchWhatsApp(_dealer!['phone']);
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: AppColors.black),
        ),
        title: Text('Dealer Profile', style: TextStyle(color: AppColors.black)),
        actions: [Image.asset('assets/icons/logo_purple_large.png', width: 50)],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: handleBottomNavTap,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.email_outlined),
            label: 'Email',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_forwarded_outlined),
            label: 'Phone',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/whatsapp.png'),
            label: 'Whatsapp',
          ),
        ],
      ),
      body: SafeArea(child: SingleChildScrollView()),
    );
  }
}
