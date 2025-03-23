import 'package:flutter/material.dart';
import 'package:guidera_app/screens/analytics_screen.dart';
import 'package:guidera_app/screens/entrytest-screen.dart';
import 'package:guidera_app/screens/splash_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:guidera_app/screens/saved_programs_screen.dart';
import 'package:guidera_app/theme/theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: GuideraApp(),
    ),
  );
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
      home: const SplashScreen(),
    );
  }
}
