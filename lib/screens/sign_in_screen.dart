import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xdeal/models/user.dart';
import 'package:xdeal/providers/user_provider.dart';
import 'package:xdeal/screens/forgot_password_screen.dart';
import 'package:xdeal/screens/on_boarding_screen.dart';
import 'package:xdeal/screens/screen_selector.dart';
import 'package:xdeal/screens/sign_up_screen.dart';
import 'package:xdeal/services/auth_service.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/navigation_helper.dart';
import 'package:xdeal/utils/social_btn_builder.dart';
import 'package:xdeal/utils/text_field_builder.dart';
import 'package:xdeal/widgets/submit_btn.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _signin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await AuthService.signin(
        email: email,
        password: password,
      );

      final token = response['token'];
      final userRaw = response['user'];

      if (token is! String || token.isEmpty) {
        throw Exception("Invalid token received from server");
      }
      if (userRaw is! Map) {
        throw Exception("Invalid user object received from server");
      }

      // Save token FIRST (and verify)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      final saved = prefs.getString('token');
      debugPrint("TOKEN SAVED: $saved");
      if (saved != token) {
        throw Exception("Token was not saved to SharedPreferences");
      }

      // Put user in provider
      final userMap = Map<String, dynamic>.from(userRaw as Map);
      userMap['token'] = token;
      final user = User.fromJson(userMap);

      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).setUser(user);

      navigateToReplacement(context, ScreenSelector());
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _appBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Email
              buildTextField("Email", emailController),
              const SizedBox(height: 16),

              // Password
              buildTextField("Password", passwordController, obscureText: true),
              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text("Forgot Password ?"),
                ),
              ),
              const SizedBox(height: 16),

              // Sign In Button
              isLoading
                  ? SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: CircularProgressIndicator(),
                    )
                  : submitBtn(_signin, "Sign in"),

              const SizedBox(height: 20),

              // TODO: IMPLEMENT THESE LATER ON
              // Center(
              //   child: Text(
              //     "Or sign in with",
              //     style: TextStyle(color: AppColors.black),
              //   ),
              // ),
              // const SizedBox(height: 20),

              // // Social Buttons
              // Wrap(
              //   spacing: 12,
              //   runSpacing: 12,
              //   alignment: WrapAlignment.center,
              //   children: [
              //     buildSocialButton("Facebook"),
              //     buildSocialButton("Google"),
              //     buildSocialButton("Apple IOS"),
              //     buildSocialButton("Phone Number"),
              //   ],
              // ),
              // const SizedBox(height: 30),

              // Already have account
              Center(
                child: GestureDetector(
                  onTap: () {
                    navigateToReplacement(context, const SignUpScreen());
                  },
                  child: Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(
                      color: AppColors.secondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
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
        onPressed: () => navigateToReplacement(context, OnBoardingScreen()),
      ),
      title: Text(
        "Sign in",
        style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w500),
      ),
    );
  }
}
