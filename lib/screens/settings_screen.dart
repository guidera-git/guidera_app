import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/screens/privacy_policy.dart';
import 'package:guidera_app/screens/login-signup.dart';
import 'package:guidera_app/theme/app_colors.dart';
import '../Widgets/drawer.dart';


/// A settings screen with inline controls for General settings,
/// and separate cards for Privacy, Support, and Account.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Inline setting values.
  bool _notificationsEnabled = true;
  final List<String> _preferences = ['Light', 'Dark', 'System'];
  String _selectedPreference = 'Dark';

  /// Helper method to build a settings card with a title and options.
  Widget _buildSettingsCard({required String title, required List<Widget> options}) {
    return Card(
      color: AppColors.lightBlack,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.myWhite,
              ),
            ),
            const SizedBox(height: 8),
            ...options,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.myBlack,
      // Add the common drawer with selectedIndex set to 3 (Settings)
      drawer: const GuideraDrawer(selectedIndex: 3),
      appBar: AppBar(
        backgroundColor: AppColors.myBlack,
        elevation: 0,
        // Menu icon to open the drawer.
        leading: Builder(
          builder: (context) => IconButton(
            icon: SvgPicture.asset(
              "assets/images/menu.svg",
              color: AppColors.myWhite,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(color: AppColors.myWhite),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // General Settings Card with inline controls.
            _buildSettingsCard(
              title: "General",
              options: [
                // Notification Settings inline control.
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications, color: AppColors.myWhite),
                  title: const Text(
                    "Notification Settings",
                    style: TextStyle(color: AppColors.myWhite, fontSize: 17),
                  ),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    activeColor: AppColors.lightBlue,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ),
                const Divider(color: AppColors.myGray),
                // Preferences inline control.
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.tune, color: AppColors.myWhite),
                  title: const Text(
                    "Theme",
                    style: TextStyle(color: AppColors.myWhite),
                  ),
                  trailing: DropdownButton<String>(
                    value: _selectedPreference,
                    dropdownColor: AppColors.lightBlack,
                    style: const TextStyle(color: AppColors.myWhite),
                    underline: Container(),
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.myWhite),
                    items: _preferences.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: AppColors.myWhite),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedPreference = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            // Privacy Settings Card.
            _buildSettingsCard(
              title: "Privacy",
              options: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lock, color: AppColors.myWhite),
                  title: const Text(
                    "Privacy & Policies",
                    style: TextStyle(color: AppColors.myWhite),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.myWhite, size: 16),
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const PrivacyScreen()),
                    );
                  },
                ),
              ],
            ),
            // Support Card.
            _buildSettingsCard(
              title: "Support",
              options: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.help_outline, color: AppColors.myWhite),
                  title: const Text(
                    "Help & Support",
                    style: TextStyle(color: AppColors.myWhite),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.myWhite, size: 16),
                  onTap: () {
                    // TODO: Navigate to Help & Support.
                  },
                ),
              ],
            ),
            // Account Card (Logout Option).
            _buildSettingsCard(
              title: "Account",
              options: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout, color: AppColors.myWhite),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: AppColors.myWhite),
                  ),
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const LoginSignup()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
