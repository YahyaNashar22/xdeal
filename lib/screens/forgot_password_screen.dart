import 'package:flutter/material.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/text_field_builder.dart';
import 'package:xdeal/widgets/submit_btn.dart';

// TODO: input validation
// TODO: connect backend

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    String email = emailController.text;

    debugPrint("Email: $email");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),

        title: Text(
          "Forgot Password",
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Enter your email",
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                "We will send you a verification code",
                style: TextStyle(color: AppColors.black, fontSize: 18),
              ),
              const SizedBox(height: 20),
              // Email
              buildTextField("Email", emailController),

              const SizedBox(height: 20),

              submitBtn(_onSubmit, "Send Code"),

              const SizedBox(height: 20),

              Image.asset('assets/icons/logo_purple_large.png'),
            ],
          ),
        ),
      ),
    );
  }
}
