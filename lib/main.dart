import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:xdeal/screens/on_boarding_screen.dart';
import 'package:xdeal/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

// HACK: FOR IOS BUILD RUN THIS TO BUILD WITH MAP API
// ! flutter run --dart-define=GOOGLE_API_KEY=YOUR_IOS_KEY

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XDeal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const OnBoardingScreen(),
    );
  }
}
