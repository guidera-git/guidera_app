import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/theme/app_colors.dart';
import '../Widgets/drawer.dart';


/// A screen that displays Privacy Policy, Terms of Service, and Credits
/// using a card-based UI similar to the About screen.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  // Content for Privacy Policy.
  final String _privacyPolicyText = '''
At Guidera, your privacy is our top priority. We collect and process your data solely to enhance your user experience and ensure a smooth application process. Your personal information is never shared with third parties without your explicit consent.
  ''';

  // Content for Terms of Service.
  final String _termsOfServiceText = '''
By using Guidera, you agree to abide by our Terms of Service. We reserve the right to update or modify these terms as needed. We encourage you to review these terms periodically for any changes.
  ''';

  // Content for Credits.
  final String _creditsText = '''
Developed by the Guidera Team with contributions from talented designers, developers, and educators. Special thanks to our partners and users for their ongoing support.
  ''';

  /// Helper method to build a section card with a title and its content.
  Widget _buildSection({required String title, required Widget content}) {
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
            content,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.myBlack,
      drawer: const GuideraDrawer(selectedIndex: 2), // Selected index for Privacy & Policies.
      appBar: AppBar(
        backgroundColor: AppColors.myBlack,
        elevation: 0,
        // Use a menu icon to open the drawer.
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
          "Privacy & Policies",
          style: TextStyle(color: AppColors.myWhite),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection(
              title: "Privacy Policy",
              content: Text(
                _privacyPolicyText,
                style: const TextStyle(fontSize: 16, color: AppColors.myWhite),
              ),
            ),
            _buildSection(
              title: "Terms of Service",
              content: Text(
                _termsOfServiceText,
                style: const TextStyle(fontSize: 16, color: AppColors.myWhite),
              ),
            ),
            _buildSection(
              title: "Credits",
              content: Text(
                _creditsText,
                style: const TextStyle(fontSize: 16, color: AppColors.myWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
