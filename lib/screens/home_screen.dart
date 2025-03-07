// home_screen.dart
import 'package:flutter/material.dart';
import 'package:guidera_app/Widgets/header.dart';
import 'package:guidera_app/Widgets/fancy_bottom_nav_bar.dart';
import 'package:guidera_app/Widgets/fancy_nav_item.dart';
import 'package:guidera_app/theme/app_colors.dart'; // <-- Import your color constants

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Center(child: Text("Home Screen")),
    const Center(child: Text("Analytics Screen")),
    const Center(child: Text("Entry Test Screen")),
    const Center(child: Text("Chatbot Screen")),
  ];

  @override
  Widget build(BuildContext context) {
    // Check if the app is in dark mode
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Choose background color based on dark or light mode
    final Color backgroundColor =
    isDarkMode ? AppColors.myBlack : AppColors.myWhite;

    // Example items (icon + label)
    final List<FancyNavItem> items = [
      FancyNavItem(label: "Home",       svgPath: "assets/images/home.svg"),
      FancyNavItem(label: "Analytics",  svgPath: "assets/images/analytics.svg"),
      FancyNavItem(label: "Entry Test", svgPath: "assets/images/entry_test.svg"),
      FancyNavItem(label: "Chatbot",    svgPath: "assets/images/chatbot.svg"),
    ];

    return Scaffold(
      // Set the entire screen background
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // 1) Your header at the top
          const GuideraHeader(),
          // 2) The main content below the header
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
      // 3) The bottom nav bar
      bottomNavigationBar: GuideraBottomNavBar(
        items: items,
        initialIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
