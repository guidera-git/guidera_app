import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/screens/about_screen.dart';
import 'package:guidera_app/screens/help_support_screen.dart';
import 'package:guidera_app/screens/home_screen.dart';
import 'package:guidera_app/screens/privacy_policy.dart';
import 'package:guidera_app/screens/rate_share_social_screen.dart';
import 'package:guidera_app/screens/settings_screen.dart';
import 'package:guidera_app/theme/app_colors.dart';

/// Simple model for each drawer item.
class _DrawerItem {
  final String title;
  final String svgPath;
  const _DrawerItem({required this.title, required this.svgPath});
}

class GuideraDrawer extends StatefulWidget {
  /// The index of the currently selected item.
  final int selectedIndex;
  const GuideraDrawer({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  _GuideraDrawerState createState() => _GuideraDrawerState();
}

class _GuideraDrawerState extends State<GuideraDrawer> {
  late int _selectedIndex;

  final List<_DrawerItem> _drawerItems = const [
    _DrawerItem(title: "Home", svgPath: "assets/images/home.svg"),
    _DrawerItem(title: "About Guidera", svgPath: "assets/images/info.svg"),
    _DrawerItem(title: "Privacy & Policies", svgPath: "assets/images/privacy.svg"),
    _DrawerItem(title: "Settings", svgPath: "assets/images/settings.svg"),
    _DrawerItem(title: "Help & Support", svgPath: "assets/images/help.svg"),
    _DrawerItem(title: "Rate & Social", svgPath: "assets/images/share.svg"),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _handleNavigation(int index) {
    Navigator.pop(context); // Close the drawer
    setState(() {
      _selectedIndex = index;
    });
    // Navigate based on index.
    // You can use Navigator.pushReplacementNamed if using named routes.
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AboutGuideraScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PrivacyScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
        );
        break;
      case 5:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RateShareSocialScreen()),
        );
        break;
    }
  }

  Widget _buildDrawerItem({required _DrawerItem item, required int index}) {
    final bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _handleNavigation(index),
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
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
          const Divider(color: AppColors.myGray, thickness: 1, height: 0),
          // Drawer items
          Expanded(
            child: ListView.builder(
              itemCount: _drawerItems.length,
              itemBuilder: (context, index) {
                return _buildDrawerItem(item: _drawerItems[index], index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
