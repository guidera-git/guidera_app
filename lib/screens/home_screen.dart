import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/Widgets/header.dart';
import 'package:guidera_app/Widgets/fancy_bottom_nav_bar.dart';
import 'package:guidera_app/Widgets/fancy_nav_item.dart';
import 'package:guidera_app/screens/university_search_screen.dart';
import 'package:guidera_app/theme/app_colors.dart'; // <-- Import your color constants
import 'dart:math' as math;


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;


  // final List<Widget> _screens = [
  //   const HomeTab(), // Updated home tab with welcome card.
  //   const UniversitySearchScreen(),
  //   const Center(child: Text("Analytics Screen")),
  //   const Center(child: Text("Entry Test Screen")),
  //   const Center(child: Text("Chatbot Screen"))
  // // Color configurations
  final List<LinearGradient> _cardGradients = [
    LinearGradient(colors: [AppColors.myWhite, AppColors.myWhite]),
    LinearGradient(colors: [AppColors.darkBlue, AppColors.darkBlue]),
    LinearGradient(colors: [AppColors.darkBlack, AppColors.darkBlack]),
    LinearGradient(colors: [AppColors.myWhite, AppColors.myWhite]),

  ];

  final List<Color> _titleCardColors = [
    AppColors.darkBlue,
    AppColors.myWhite,
    AppColors.myWhite,
    AppColors.darkBlue,
  ];

  final List<Map<String, Color>> _circleColors = [
    {'circle': AppColors.darkBlue, 'icon': AppColors.myWhite},
    {'circle': AppColors.myWhite, 'icon': AppColors.darkBlue},
    {'circle': AppColors.myWhite, 'icon': AppColors.myBlack},
    {'circle': AppColors.darkBlue, 'icon': AppColors.myWhite},
  ];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeTab(
        onGridItemSelected: (index) => setState(() => _currentIndex = index),
        cardGradients: _cardGradients,
        titleCardColors: _titleCardColors,
        circleColors: _circleColors,
      ),
      const UniversitySearchScreen(),
      const Center(child: Text("Analytics Screen")),
      const Center(child: Text("Entry Test Screen")),
      const Center(child: Text("Chatbot Screen")),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? AppColors.myBlack : AppColors.myWhite;

    final List<FancyNavItem> items = [
      FancyNavItem(label: "Home",       svgPath: "assets/images/home.svg"),
      FancyNavItem(label: "Find", svgPath: "assets/images/search.svg"),
      FancyNavItem(label: "Analytics",  svgPath: "assets/images/analytics.svg"),
      FancyNavItem(label: "Entry Test", svgPath: "assets/images/entry_test.svg"),
      FancyNavItem(label: "Chatbot",    svgPath: "assets/images/chatbot.svg"),


    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          const GuideraHeader(),
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
      bottomNavigationBar: GuideraBottomNavBar(
        items: items,
        initialIndex: _currentIndex,
        onItemSelected: (index) => setState(() => _currentIndex = index),
      ),
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
    return SingleChildScrollView(
      child: Column(
        children: [
          WelcomeCard(
            userName: 'Saad Mahmood',
            lastLogin: DateTime.now(),
          ),
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
                _buildGridCard("Find University", "assets/images/find.svg", 0),
                _buildGridCard("Analytics", "assets/images/visual.svg", 1),
                _buildGridCard("Prepare Test", "assets/images/test.svg", 2),
                _buildGridCard("Chatbot", "assets/images/chat.svg", 3),
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
                  height: 64,
                  width: 64,
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
  final DateTime lastLogin;

  const WelcomeCard({
    Key? key,
    required this.userName,
    required this.lastLogin,
  }) : super(key: key);

  String getFormattedLastLogin() {
    return '${lastLogin.day}/${lastLogin.month}/${lastLogin.year} ${lastLogin.hour}:${lastLogin.minute.toString().padLeft(2, '0')}';
  }

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
                  'Hello,',
                  style: TextStyle(
                    fontSize: 22.0,
                    color: AppColors.darkBlue,
                  ),
                ),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.myBlack,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Last login: ${getFormattedLastLogin()}',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: AppColors.myBlack.withOpacity(0.7),
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