import 'package:flutter/material.dart';
import 'package:xdeal/screens/sign_up_screen.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/navigation_helper.dart';
import 'package:xdeal/utils/text_field_builder.dart';
import 'package:xdeal/widgets/submit_btn.dart';

// TODO: input validation
// TODO: connect backend

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    debugPrint("otp: $otpController");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _appBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Otp",
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Please enter the otp you received below",
                style: TextStyle(color: AppColors.black, fontSize: 18),
              ),

              buildTextField("Otp", otpController),
              const SizedBox(height: 20),
              submitBtn(_onSubmit, "Verify"),
              const SizedBox(height: 20),
              Image.asset('assets/icons/logo_purple_large.png'),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.black),
        onPressed: () => navigateToReplacement(context, const SignUpScreen()),
      ),
      title: Text(
        "Verify Email",
        style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w500),
      ),
    );
  }
}
