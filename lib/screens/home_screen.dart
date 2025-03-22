import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/Widgets/header.dart';
import 'package:guidera_app/Widgets/fancy_bottom_nav_bar.dart';
import 'package:guidera_app/Widgets/fancy_nav_item.dart';
import 'package:guidera_app/screens/privacy_policy.dart';
import 'package:guidera_app/screens/profile_dashboard_screen.dart';
import 'package:guidera_app/screens/rate_share_social_screen.dart';
import 'package:guidera_app/screens/settings_screen.dart';
import 'package:guidera_app/screens/university_search_screen.dart';
import 'package:guidera_app/screens/analytics_screen.dart';
import 'package:guidera_app/screens/chatbot_screen.dart';
import 'package:guidera_app/screens/entrytest-screen.dart';
import 'package:guidera_app/screens/notification_screen.dart';
import 'package:guidera_app/screens/about_screen.dart';
import 'package:guidera_app/screens/help_support_screen.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'dart:math' as math;

/// HomeScreen now loads its header only for the Home tab.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Simple model for each drawer item.
class _DrawerItem {
  final String title;
  final String svgPath;

  const _DrawerItem({required this.title, required this.svgPath});
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Track the selected item in the drawer for highlighting.
  int _selectedDrawerIndex = 0;

  // Define the drawer items with text and corresponding SVG paths.
  final List<_DrawerItem> _drawerItems = [
    _DrawerItem(title: "Home", svgPath: "assets/images/home.svg"),
    _DrawerItem(title: "About Guidera", svgPath: "assets/images/info.svg"),
    _DrawerItem(title: "Privacy & Policies", svgPath: "assets/images/privacy.svg"),
    _DrawerItem(title: "Settings", svgPath: "assets/images/settings.svg"),
    _DrawerItem(title: "Help & Support", svgPath: "assets/images/help.svg"),
    _DrawerItem(title: "Rate & Social", svgPath: "assets/images/share.svg"),
  ];

  // Colors and gradients used by the grid tiles on the Home dashboard.
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
    // Updated _screens with an additional NotificationScreen.
    _screens = [
      HomeTab(
        cardGradients: _cardGradients,
        titleCardColors: _titleCardColors,
        circleColors: _circleColors,
      ),
      const UniversitySearchScreen(),
      const UserProfileScreen(),
      const NotificationScreen(),
    ];
  }

  // Handle drawer item taps:
  //  - For "Home" (index 0), set _currentIndex=0 to show the Home tab.
  //  - For others, push their respective screens.
  void _handleDrawerNavigation(int index) {
    Navigator.pop(context); // Close the drawer
    setState(() {
      _selectedDrawerIndex = index;
    });

    switch (index) {
      case 0:
      // Home
        setState(() {
          _currentIndex = 0;
        });
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AboutGuideraScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PrivacyScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RateShareSocialScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? AppColors.myBlack : AppColors.myWhite;

    // Bottom navigation items.
    final List<FancyNavItem> items = [
      FancyNavItem(label: "Home", svgPath: "assets/images/home.svg"),
      FancyNavItem(label: "Search", svgPath: "assets/images/search.svg"),
      FancyNavItem(label: "Profile", svgPath: "assets/images/profile.svg"),
      FancyNavItem(label: "Notifications", svgPath: "assets/images/notification.svg"),
    ];

    return WillPopScope(
      onWillPop: () async {
        // If the user is not on Home, back returns to Home instead of exiting the app.
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.myBlack,
        // Professional Drawer
        drawer: Drawer(
          backgroundColor: AppColors.myBlack,
          width: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER with avatar, name, email
              Container(
                color: AppColors.myBlack,
                padding: const EdgeInsets.only(top: 62, left: 26, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Circular Avatar
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(
                        "https://avatars.githubusercontent.com/u/168419532?v=4",
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name + Email
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Saad",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.myWhite,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "saad@example.com",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.myGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Divider
              const Divider(color: AppColors.myGray, thickness: 1, height: 0),
              // DRAWER ITEMS
              Expanded(
                child: ListView.builder(
                  itemCount: _drawerItems.length,
                  itemBuilder: (context, index) {
                    final item = _drawerItems[index];
                    final isSelected = _selectedDrawerIndex == index;

                    return InkWell(
                      onTap: () => _handleDrawerNavigation(index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.myGray : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: SvgPicture.asset(
                            item.svgPath,
                            color: isSelected ? AppColors.darkBlue : AppColors.myWhite,
                            width: 24,
                            height: 24,
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              color: isSelected ? AppColors.darkBlue : AppColors.myWhite,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Only load header for Home tab. Other tabs should render their own header inside their screen.
        appBar: _currentIndex == 0
            ? PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Builder(
            builder: (context) => Stack(
              children: [
                const GuideraHeader(),
                Positioned(
                  top: 75, // Adjust this value to lower the icon as desired
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.myWhite),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ],
            ),
          ),
        )
            : null,

        body: _screens[_currentIndex],
        bottomNavigationBar: GuideraBottomNavBar(
          items: items,
          initialIndex: _currentIndex,
          onItemSelected: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}

/// HomeTab remains as your dashboard for the Home screen.
class HomeTab extends StatelessWidget {
  final List<LinearGradient> cardGradients;
  final List<Color> titleCardColors;
  final List<Map<String, Color>> circleColors;

  const HomeTab({
    Key? key,
    required this.cardGradients,
    required this.titleCardColors,
    required this.circleColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy deadlines data for demonstration.
    final deadlines = [
      {"event": "FAST - Entry Test", "date": "March 25, 2025"},
      {"event": "NUST - Application", "date": "April 05, 2025"},
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting section with a profile avatar.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 26.0, top: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, Saad!",
                      style: TextStyle(
                        color: AppColors.myWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Welcome to Guidera",
                      style: TextStyle(
                        color: AppColors.myGray,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // The profile avatar also allows navigation to the profile screen.
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserProfileScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(25),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                      "https://avatars.githubusercontent.com/u/168419532?v=4",
                    ),
                    backgroundColor: AppColors.darkBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Info carousel card shows dynamic info like last login and deadlines.
          InfoCarouselCard(
            lastLogin: DateTime.now(),
            deadlines: deadlines,
          ),
          const SizedBox(height: 16.0),
          // Main Grid Tiles: tapping each tile pushes its respective screen.
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
                _buildGridCard(context, "Find University", "assets/images/find.svg", 0),
                _buildGridCard(context, "Analytics", "assets/images/visual.svg", 1),
                _buildGridCard(context, "Prepare Test", "assets/images/test.svg", 2),
                _buildGridCard(context, "Chatbot", "assets/images/chat.svg", 3),
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

  Widget _buildGridCard(
      BuildContext context,
      String title,
      String iconPath,
      int index,
      ) {
    final gradient = cardGradients[index % cardGradients.length];
    final titleColor = titleCardColors[index % titleCardColors.length];

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
          onTap: () {
            // Based on the tile tapped, push the corresponding screen.
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UniversitySearchScreen(),
                  ),
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnalyticsTrackingScreen(),
                  ),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const EntryTestScreen(subjectName: ""),
                  ),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatbotScreen(),
                  ),
                );
                break;
            }
          },
          child: Stack(
            children: [
              // Title card at the top-left.
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
              // Circular button at the bottom-left.
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: circleColors[index % circleColors.length]['circle']!
                        .withOpacity(0.9),
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
                      color: circleColors[index % circleColors.length]['icon'],
                    ),
                  ),
                ),
              ),
              // Main icon at the bottom-right.
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

/// InfoCarouselCard shows dynamic information such as last login time and deadlines.
class InfoCarouselCard extends StatefulWidget {
  final DateTime lastLogin;
  final List<Map<String, String>> deadlines;

  const InfoCarouselCard({
    Key? key,
    required this.lastLogin,
    required this.deadlines,
  }) : super(key: key);

  @override
  State<InfoCarouselCard> createState() => _InfoCarouselCardState();
}

class _InfoCarouselCardState extends State<InfoCarouselCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.myWhite, AppColors.myGray],
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Stack(
        children: [
          // A PageView for the different info slides.
          Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    // Slide 1: Last Login Info.
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Last Login",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "You last logged in on ${_formatDate(widget.lastLogin)}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.myBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Slide 2: Upcoming Deadlines.
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Upcoming Deadlines",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...widget.deadlines.map((deadline) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                "${deadline['event']}: ${deadline['date']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.myBlack,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    // Slide 3: Profile Completion (Quick Stats).
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Profile Completion",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Your profile is 80% complete.",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.myBlack,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: 0.8,
                            backgroundColor: AppColors.myGray,
                            valueColor: const AlwaysStoppedAnimation(AppColors.darkBlue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Dot indicators for the carousel.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: _currentPage == index ? 12 : 8,
                    height: _currentPage == index ? 12 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.darkBlue
                          : AppColors.myGray,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
