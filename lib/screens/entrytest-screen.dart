import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/Widgets/header.dart';
import 'package:guidera_app/Widgets/fancy_bottom_nav_bar.dart';
import 'package:guidera_app/Widgets/fancy_nav_item.dart';
import 'package:guidera_app/screens/university_search_screen.dart';
import 'package:guidera_app/screens/question-screen.dart';
import 'package:guidera_app/theme/app_colors.dart'; // <-- Import your color constants
import 'dart:math' as math;

import 'home_screen.dart';

class EntryTestScreen extends StatefulWidget {
  final String subjectName;

  const EntryTestScreen({Key? key, required this.subjectName}) : super(key: key);

  @override
  State<EntryTestScreen> createState() => _EntryTestScreenState();
}

class _EntryTestScreenState extends State<EntryTestScreen> {
  int _currentIndex = 0;

  final List<LinearGradient> _cardGradients = [
    LinearGradient(colors: [AppColors.myWhite, AppColors.myWhite]),
    LinearGradient(colors: [AppColors.darkBlue, AppColors.darkBlue]),
    LinearGradient(colors: [AppColors.darkBlack, AppColors.darkBlack]),
    LinearGradient(colors: [AppColors.myWhite, AppColors.myWhite]),
    LinearGradient(colors: [AppColors.myWhite, AppColors.myWhite]),
  ];

  final List<Color> _titleCardColors = [
    AppColors.darkBlue,
    AppColors.myWhite,
    AppColors.myWhite,
    AppColors.darkBlue,
    AppColors.myWhite,
  ];

  final List<Map<String, Color>> _circleColors = [
    {'circle': AppColors.darkBlue, 'icon': AppColors.myWhite},
    {'circle': AppColors.myWhite, 'icon': AppColors.darkBlue},
    {'circle': AppColors.myWhite, 'icon': AppColors.myBlack},
    {'circle': AppColors.darkBlue, 'icon': AppColors.myWhite},
    {'circle': AppColors.myWhite, 'icon': AppColors.darkBlue},
  ];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const Center(child: Text("Home Screen")), // Placeholder for Home Screen
      const UniversitySearchScreen(),
      const Center(child: Text("Analytics Screen")),
      const Center(child: Text("Entry Test Screen")),
      const Center(child: Text("Chatbot Screen"))
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? AppColors.myBlack : AppColors.myWhite;

    final List<FancyNavItem> items = [
      FancyNavItem(label: "Home", svgPath: "assets/images/home.svg"),
      FancyNavItem(label: "Find", svgPath: "assets/images/search.svg"),
      FancyNavItem(label: "Analytics", svgPath: "assets/images/analytics.svg"),
      FancyNavItem(label: "Entry Test", svgPath: "assets/images/entry_test.svg"),
      FancyNavItem(label: "Chatbot", svgPath: "assets/images/chatbot.svg"),
    ];

    return Scaffold(
      backgroundColor: AppColors.myBlack,
      // Custom AppBar with header and back button
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Stack(
          children: [
            const GuideraHeader(),
            Positioned(
              top: 70,
              left: 10,
              child: IconButton(
                icon: SvgPicture.asset(
                  "assets/images/back.svg",
                  color: AppColors.myWhite,
                  height: 30,
                ),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    // Fallback: navigate to a default screen (e.g., HomeScreen)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: HomeTab(
              onGridItemSelected: (index) {
                // Handle grid item selection
                final subject = ["Chemistry", "Biology", "Physics", "English", "Computer"][index];
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionScreen(subjectName: subject),
                  ),
                );
              },
              cardGradients: _cardGradients,
              titleCardColors: _titleCardColors,
              circleColors: _circleColors,
            ),
          ),
        ],
      ),
      // bottomNavigationBar: GuideraBottomNavBar(
      //   items: items,
      //   initialIndex: _currentIndex,
      //   onItemSelected: (index) => setState(() => _currentIndex = index),
      // ),
    );
  }
}

class HomeTab extends StatelessWidget {
  final Function(int) onGridItemSelected;
  final List<LinearGradient> cardGradients;
  final List<Color> titleCardColors;
  final List<Map<String, Color>> circleColors;

  const HomeTab({
    Key? key,
    required this.onGridItemSelected,
    required this.cardGradients,
    required this.titleCardColors,
    required this.circleColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The WelcomeCard is now outside the SingleChildScrollView
        WelcomeCard(
          userName: 'Stay Focused!',
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 1.2,
                    children: [
                      _buildGridCard("Chemistry", "assets/images/chemistry.svg", 0),
                      _buildGridCard("Biology", "assets/images/biology.svg", 1),
                      _buildGridCard("Physics", "assets/images/physics.svg", 2),
                      _buildGridCard("English", "assets/images/english.svg", 3),
                      _buildGridCard("Computer", "assets/images/test.svg", 4),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Here is some additional content printed under the welcome card.",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.myBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridCard(String title, String iconPath, int index) {
    final colorPair = circleColors[index % 4];
    final gradient = cardGradients[index % 4];
    final titleColor = titleCardColors[index % 4];

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16.0),
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.myBlack.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
            )
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () => onGridItemSelected(index),
          child: Stack(
            children: [
              // Title Card (top-left)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: titleColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getContrastColor(titleColor),
                    ),
                  ),
                ),
              ),
              // Circular Button (bottom-left)
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorPair['circle']!.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.myBlack.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Transform.rotate(
                    angle: 145 * math.pi / 180,
                    child: SvgPicture.asset(
                      "assets/images/back.svg",
                      width: 16,
                      height: 16,
                      color: colorPair['icon'],
                    ),
                  ),
                ),
              ),
              // Main Icon (bottom-right)
              Positioned(
                bottom: 12,
                right: 12,
                child: SvgPicture.asset(
                  iconPath,
                  height: 50,
                  width: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? AppColors.myBlack : AppColors.myWhite;
  }
}

class WelcomeCard extends StatelessWidget {
  final String userName;

  const WelcomeCard({
    Key? key,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.myWhite, AppColors.myGray],
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enjoy Preparing',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: AppColors.darkBlue,
                  ),
                ),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.normal,
                    color: AppColors.myBlack,
                  ),
                ),
              ],
            ),
          ),
          SvgPicture.asset(
            'assets/images/student_laptop.svg',
            height: 100.0,
            width: 80.0,
          ),
        ],
      ),
    );
  }
}