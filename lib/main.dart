import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme/theme.dart';

void main() {
  runApp(const GuideraApp());
}

class GuideraApp extends StatelessWidget {
  const GuideraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guidera',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system, // Auto-switch between light/dark mode
      //home: const SplashScreen(),
    );
  }
}
