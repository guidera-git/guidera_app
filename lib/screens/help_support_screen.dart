import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:guidera_app/theme/app_colors.dart';
import '../Widgets/drawer.dart';


/// A screen for Help & Support that includes FAQs and a Contact section.
/// The Contact section uses an email container that copies the email to the clipboard
/// and shows a toast notification.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  // Sample FAQs – update these with your actual FAQs.
  final List<Map<String, String>> _faqs = const [
    {
      'question': 'How do I reset my password?',
      'answer':
      'To reset your password, go to the Account Settings and tap on "Reset Password".'
    },
    {
      'question': 'How can I update my profile?',
      'answer': 'You can update your profile details from the Profile section in the app.'
    },
    {
      'question': 'Where can I find the latest university notifications?',
      'answer':
      'All notifications regarding university deadlines and updates can be found in the Notifications tab.'
    },
  ];

  /// Builds a section card with a title and content.
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

  /// Builds the FAQ list.
  Widget _buildFAQSection() {
    return Column(
      children: _faqs.map((faq) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ExpansionTile(
            backgroundColor: AppColors.lightBlack,
            collapsedBackgroundColor: AppColors.lightBlack,
            title: Text(
              faq['question']!,
              style: const TextStyle(
                color: AppColors.myWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  faq['answer']!,
                  style: const TextStyle(color: AppColors.myWhite),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Builds the Contact section with a copy-to-clipboard email.
  Widget _buildContactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            Clipboard.setData(const ClipboardData(text: "guidera@ucp.edu.pk"));
            Fluttertoast.showToast(
              msg: "Email copied to clipboard",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: AppColors.darkBlue,
              textColor: AppColors.myWhite,
              fontSize: 16.0,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.darkBlue, AppColors.lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.mail, color: AppColors.myWhite, size: 28),
                SizedBox(width: 12),
                Text(
                  "guidera@ucp.edu.pk",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.myWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "For further assistance, please contact us via email.",
          style: TextStyle(fontSize: 16, color: AppColors.myWhite),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.myBlack,
      drawer: const GuideraDrawer(selectedIndex: 4), // Selected index for Help & Support.
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
          "Help & Support",
          style: TextStyle(color: AppColors.myWhite),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // FAQ Section.
            _buildSection(
              title: "FAQs",
              content: _buildFAQSection(),
            ),
            // Contact Section.
            _buildSection(
              title: "Contact Us",
              content: _buildContactSection(context),
            ),
          ],
        ),
      ),
    );
  }
}
