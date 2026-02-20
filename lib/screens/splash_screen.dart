import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xdeal/providers/user_provider.dart';
import 'package:xdeal/screens/home_screen.dart';
import 'package:xdeal/screens/on_boarding_screen.dart';
import 'package:xdeal/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    debugPrint("BOOTSTRAP START");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    debugPrint("TOKEN FROM PREFS: $token");

    if (token == null || token.isEmpty) {
      debugPrint("NO TOKEN -> ONBOARDING");
      _goToOnboarding();
      return;
    }

    try {
      debugPrint("CALLING /me ...");
      final user = await AuthService.getCurrentUser(token);
      debugPrint("ME OK: ${user.toJson()}");

      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).setUser(user);

      debugPrint("NAV HOME");
      _goToHome();
    } catch (e) {
      debugPrint("ME FAILED: $e");
      await prefs.remove('token');
      _goToOnboarding();
    }
  }

  void _goToHome() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  void _goToOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnBoardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
