import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:guidera_app/screens/privacy_policy.dart';
import 'package:guidera_app/screens/login-signup.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/providers/theme_provider.dart';
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

  /// Helper method to build a settings card with a title and options.
  Widget _buildSettingsCard({required String title, required List<Widget> options}) {
    return Card(
      color: AppColors.surfaceColor(context),
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
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
      backgroundColor: AppColors.backgroundColor(context),
      // Add the common drawer with selectedIndex set to 3 (Settings)
      drawer: const GuideraDrawer(selectedIndex: 3),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        // Menu icon to open the drawer.
        leading: Builder(
          builder: (context) => IconButton(
            icon: SvgPicture.asset(
              "assets/images/menu.svg",
              color: AppColors.textPrimary(context),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "Settings",
          style: TextStyle(color: AppColors.textPrimary(context)),
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
                  leading: Icon(
                      Icons.notifications,
                      color: AppColors.textPrimary(context)
                  ),
                  title: Text(
                    "Notification Settings",
                    style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 17
                    ),
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
                Divider(color: AppColors.borderColor(context)),
                // Theme selection inline control.
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                          Icons.tune,
                          color: AppColors.textPrimary(context)
                      ),
                      title: Text(
                        "Theme",
                        style: TextStyle(color: AppColors.textPrimary(context)),
                      ),
                      trailing: DropdownButton<String>(
                        value: themeProvider.themePreference,
                        dropdownColor: AppColors.surfaceColor(context),
                        style: TextStyle(color: AppColors.textPrimary(context)),
                        underline: Container(),
                        icon: Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.textPrimary(context)
                        ),
                        items: _preferences.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(color: AppColors.textPrimary(context)),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            themeProvider.setThemePreference(newValue);
                          }
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            // Privacy Settings Card.
            _buildSettingsCard(
              title: "Privacy",
              options: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                      Icons.lock,
                      color: AppColors.textPrimary(context)
                  ),
                  title: Text(
                    "Privacy & Policies",
                    style: TextStyle(color: AppColors.textPrimary(context)),
                  ),
                  trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.textPrimary(context),
                      size: 16
                  ),
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
                  leading: Icon(
                      Icons.help_outline,
                      color: AppColors.textPrimary(context)
                  ),
                  title: Text(
                    "Help & Support",
                    style: TextStyle(color: AppColors.textPrimary(context)),
                  ),
                  trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.textPrimary(context),
                      size: 16
                  ),
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
                  leading: Icon(
                      Icons.logout,
                      color: AppColors.textPrimary(context)
                  ),
                  title: Text(
                    "Logout",
                    style: TextStyle(color: AppColors.textPrimary(context)),
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