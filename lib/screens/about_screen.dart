import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:guidera_app/theme/app_colors.dart';
import '../Widgets/drawer.dart';
import '../Widgets/drawer.dart'; // Import the common drawer widget

/// A screen that provides an overview of Guidera,
/// introduces the team, and includes contact details.
class AboutGuideraScreen extends StatelessWidget {
  AboutGuideraScreen({Key? key}) : super(key: key);

  // Overview content.
  final String _overviewText = '''
Guidera is an innovative platform designed to assist students in selecting and applying to universities. Our system streamlines the program and university selection process by offering personalized recommendations based on academic scores and personal preferences. With intuitive filtering and visually generated recommendations, Guidera helps you choose the right path.
  ''';

  // Team data with provided avatar links.
  final List<Map<String, String>> _team = [
    {
      'name': 'Aaliyan',
      'role': 'Frontend Developer',
      'bio': 'Expert in UI/UX and Flutter design.',
      'imageUrl':
      'https://media.licdn.com/dms/image/v2/D4D03AQGny3fTTojZ0w/profile-displayphoto-shrink_100_100/profile-displayphoto-shrink_100_100/0/1724948029439?e=1747872000&v=beta&t=AyRl0cKnFepv_LuLq-CoZfFyfqaqFA0M9Q2sfUMLXFE'
    },
    {
      'name': 'Saad',
      'role': 'Backend Developer',
      'bio': 'Handles server-side logic and data management.',
      'imageUrl': 'https://avatars.githubusercontent.com/u/168419532?v=4'
    },
    {
      'name': 'Hamza',
      'role': 'Full Stack Developer',
      'bio': 'Bridges both frontend and backend with robust solutions.',
      'imageUrl':
      'https://media.licdn.com/dms/image/v2/D5603AQFrkQWdrUsCng/profile-displayphoto-shrink_100_100/profile-displayphoto-shrink_100_100/0/1732851505442?e=1747872000&v=beta&t=bnsf3cMY04HJgS7WJOP5Rf8vYBoBXIAIeXseUQrPRYA'
    },
    {
      'name': 'Sami Ullah',
      'role': 'Project Manager',
      'bio': 'Ensures project milestones and team coordination.',
      'imageUrl':
      'https://media.licdn.com/dms/image/v2/D4E03AQGFNhJPK5r-ng/profile-displayphoto-shrink_100_100/profile-displayphoto-shrink_100_100/0/1715785167813?e=1747872000&v=beta&t=8uzZn-KJyAKYUw_1UXHl0UwX66PUalyxXsceHkY9Cyg'
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

  /// Builds a list tile representing a team member.
  Widget _buildTeamMember(Map<String, String> member) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(member['imageUrl'] ?? ''),
        radius: 30,
      ),
      title: Text(
        member['name'] ?? '',
        style: const TextStyle(
          color: AppColors.myWhite,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            member['role'] ?? '',
            style: const TextStyle(color: AppColors.myWhite),
          ),
          const SizedBox(height: 4),
          Text(
            member['bio'] ?? '',
            style: const TextStyle(color: AppColors.myWhite),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.myBlack,
      // Use the common drawer and set selectedIndex to 1 for About Guidera.
      drawer: const GuideraDrawer(selectedIndex: 1),
      appBar: AppBar(
        backgroundColor: AppColors.myBlack,
        elevation: 0,
        // Use a menu icon to open the drawer (no back button).
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
          "About Guidera",
          style: TextStyle(color: AppColors.myWhite),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Overview Section.
            _buildSection(
              title: "Overview",
              content: Text(
                _overviewText,
                style: const TextStyle(fontSize: 16, color: AppColors.myWhite),
              ),
            ),
            // Team Section.
            _buildSection(
              title: "Our Team",
              content: Column(
                children: _team.map((member) => _buildTeamMember(member)).toList(),
              ),
            ),
            // Contact Section with copy-to-clipboard functionality.
            _buildSection(
              title: "Contact Us",
              content: Column(
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
                    "Made with passion by UCP students as Final Year Project.",
                    style: TextStyle(fontSize: 16, color: AppColors.myWhite),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
