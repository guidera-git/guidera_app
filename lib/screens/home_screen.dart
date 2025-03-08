// home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Required for SVG images.
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
    const HomeTab(), // Updated home tab with welcome card.
    const Center(child: Text("Analytics Screen")),
    const Center(child: Text("Entry Test Screen")),
    const Center(child: Text("Chatbot Screen")),
  ];

  @override
  Widget build(BuildContext context) {
    // Check if the app is in dark mode.
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Choose background color based on dark or light mode.
    final Color backgroundColor =
    isDarkMode ? AppColors.myBlack : AppColors.myWhite;

    // Example items (icon + label) for the bottom navigation bar.
    final List<FancyNavItem> items = [
      FancyNavItem(label: "Home",       svgPath: "assets/images/home.svg"),
      FancyNavItem(label: "Analytics",  svgPath: "assets/images/analytics.svg"),
      FancyNavItem(label: "Entry Test", svgPath: "assets/images/entry_test.svg"),
      FancyNavItem(label: "Chatbot",    svgPath: "assets/images/chatbot.svg"),
    ];

    return Scaffold(
      // Entire screen background.
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // 1) Your header at the top.
          const GuideraHeader(),
          // 2) The main content below the header.
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
      // 3) The bottom nav bar.
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

/// HomeTab widget that represents the home screen's content.
class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrapping content in SingleChildScrollView in case more widgets are added.
    return SingleChildScrollView(
      child: Column(
        children:  [
          WelcomeCard(
            userName: 'Saad Mahmood', // Replace with dynamic user data if available.
            lastLogin: DateTime.now(), // Replace with the actual last login time.
          ),
          // Additional home screen widgets can be added here.
        ],
      ),
    );
  }
}

/// WelcomeCard widget that shows a welcoming message, user's name, last login details,
/// and an SVG avatar on the right.
class WelcomeCard extends StatelessWidget {
  final String userName;
  final DateTime lastLogin;

  const WelcomeCard({
    Key? key,
    required this.userName,
    required this.lastLogin,
  }) : super(key: key);

  String getFormattedLastLogin() {
    // Format the DateTime as desired, for example: "dd/MM/yyyy HH:mm".
    return '${lastLogin.day}/${lastLogin.month}/${lastLogin.year} ${lastLogin.hour}:${lastLogin.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      // Apply a linear gradient from left (myWhite) to right (darkGray).
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.myWhite,
            AppColors.myGray,
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          // Left side: text column.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Hello" text.
                Text(
                  'Hello,',
                  style: TextStyle(
                    fontSize: 22.0, // Smaller font size.
                    color: AppColors.darkBlue,
                  ),
                ),

                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 24.0, // Bigger font size.
                    fontWeight: FontWeight.bold,
                    color: AppColors.myBlack,
                  ),
                ),
                const SizedBox(height: 8.0),
                // Last login details.
                Text(
                  'Last login: ${getFormattedLastLogin()}',
                  style: TextStyle(
                    fontSize: 12.0, // Small-sized detail text.
                    color: AppColors.myBlack.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Right side: SVG avatar.
          SvgPicture.asset(
            'assets/images/student_laptop.svg', // Ensure this asset path is correct.
            height: 150.0, // Adjust size as needed.
            width: 80.0,
          ),
        ],
      ),
    );
  }
}
