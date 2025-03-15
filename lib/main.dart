import 'package:flutter/material.dart';
import 'package:guidera_app/screens/chatbot-screen.dart';
import 'package:guidera_app/screens/entry-test-screen.dart';
import 'package:guidera_app/screens/home_screen.dart';
import 'package:guidera_app/screens/recommendation_results_screen.dart';
import 'package:guidera_app/screens/university_information.dart';
import 'package:guidera_app/screens/university_search_screen.dart';
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
      home: const EntryTestScreen(),
    );
  }
}
