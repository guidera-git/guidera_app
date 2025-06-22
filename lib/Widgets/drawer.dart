import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/services/api_service.dart';
import 'package:guidera_app/screens/about_screen.dart';
import 'package:guidera_app/screens/privacy_policy.dart';
import 'package:guidera_app/screens/settings_screen.dart';
import 'package:guidera_app/screens/help_support_screen.dart';
import 'package:guidera_app/screens/rate_share_social_screen.dart';
import 'package:guidera_app/screens/home_screen.dart';

class _DrawerItem {
  final String title;
  final String svgPath;

  const _DrawerItem({required this.title, required this.svgPath});
}

class GuideraDrawer extends StatefulWidget {
  final int selectedIndex;

  const GuideraDrawer({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  State<GuideraDrawer> createState() => _GuideraDrawerState();
}

class _GuideraDrawerState extends State<GuideraDrawer> {
  final _api = ApiService();
  Map<String, dynamic>? profile;
  bool _loadingProfile = true;

  final List<_DrawerItem> _drawerItems = [
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
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final resp = await _api.getProfile();
    if (resp.statusCode == 200) {
      setState(() {
        profile = jsonDecode(resp.body);
        _loadingProfile = false;
      });
    } else {
      setState(() => _loadingProfile = false);
    }
  }

  Widget _buildAvatar({double radius = 24}) {
    if (_loadingProfile) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surfaceColor(context),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary(context),
        ),
      );
    }
    final photoUrl = profile?['profilephoto'] as String?;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(radius: radius, backgroundImage: NetworkImage(photoUrl));
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      child: SvgPicture.asset(
        'assets/images/default_avatar.svg',
        width: radius * 2,
        height: radius * 2,
        color: AppColors.textPrimary(context),
      ),
    );
  }

  void _handleDrawerNavigation(int index) {
    Navigator.pop(context);

    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
        break;
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => AboutGuideraScreen()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PrivacyScreen()));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()));
        break;
      case 4:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
        break;
      case 5:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const RateShareSocialScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.drawerBackground(context),
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 62, left: 26, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(),
                const SizedBox(height: 16),
                Text(
                  profile?['fullname']?.split(' ').first ?? 'Guest',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile?['email'] ?? 'guest@gmail.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Divider(
              color: AppColors.borderColor(context),
              thickness: 1,
              height: 0),
          Expanded(
            child: ListView.builder(
              itemCount: _drawerItems.length,
              itemBuilder: (ctx, idx) {
                final item = _drawerItems[idx];
                final selected = widget.selectedIndex == idx;
                return InkWell(
                  onTap: () => _handleDrawerNavigation(idx),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary(context).withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: SvgPicture.asset(
                        item.svgPath,
                        color: selected
                            ? AppColors.primary(context)
                            : AppColors.textPrimary(context),
                        width: 24,
                        height: 24,
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          color: selected
                              ? AppColors.primary(context)
                              : AppColors.textPrimary(context),
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
    );
  }
}