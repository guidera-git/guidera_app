import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/widgets/header.dart';
import '../widgets/drawer.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  final String _privacyPolicyText = '''
At Guidera, your privacy is our top priority. We collect and process your data solely to enhance your user experience and ensure a smooth application process. Your personal information is never shared with third parties without your explicit consent.
  ''';

  final String _termsOfServiceText = '''
By using Guidera, you agree to abide by our Terms of Service. We reserve the right to update or modify these terms as needed. We encourage you to review these terms periodically for any changes.
  ''';

  final String _creditsText = '''
Developed by the Guidera Team with contributions from talented designers, developers, and educators. Special thanks to our partners and users for their ongoing support.
  ''';

  Widget _buildSection({required String title, required Widget content, required BuildContext context}) {
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
            content,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      drawer: const GuideraDrawer(selectedIndex: 2),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Stack(
          children: [
            const GuideraHeader(),
            Positioned(
              top: 70,
              left: 10,
              child: Builder(
                builder: (context) => IconButton(
                  icon: SvgPicture.asset(
                    "assets/images/menu.svg",
                    color: AppColors.textPrimary(context),
                    height: 30,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Privacy & Policies",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: "Privacy Policy",
              content: Text(
                _privacyPolicyText,
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary(context)),
              ),
              context: context,
            ),
            _buildSection(
              title: "Terms of Service",
              content: Text(
                _termsOfServiceText,
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary(context)),
              ),
              context: context,
            ),
            _buildSection(
              title: "Credits",
              content: Text(
                _creditsText,
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary(context)),
              ),
              context: context,
            ),
          ],
        ),
      ),
    );
  }
}