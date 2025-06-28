import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/widgets/header.dart';
import '../widgets/drawer.dart';

class AboutGuideraScreen extends StatelessWidget {
  AboutGuideraScreen({Key? key}) : super(key: key);

  final String _overviewText = '''
Guidera is an innovative platform designed to assist students in selecting and applying to universities. Our system streamlines the program and university selection process by offering personalized recommendations based on academic scores and personal preferences. With intuitive filtering and visually generated recommendations, Guidera helps you choose the right path.
  ''';

  final List<Map<String, String>> _team = [
    {
      'name': 'Aaliyan',
      'role': 'Frontend Developer',
      'bio': 'Expert in UI/UX and Flutter design.',
      'imageUrl': 'https://media.licdn.com/dms/image/v2/D4D03AQGny3fTTojZ0w/profile-displayphoto-shrink_100_100/profile-displayphoto-shrink_100_100/0/1724948029439?e=1747872000&v=beta&t=AyRl0cKnFepv_LuLq-CoZfFyfqaqFA0M9Q2sfUMLXFE'
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

  Widget _buildTeamMember(Map<String, String> member, BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(member['imageUrl'] ?? ''),
        radius: 30,
      ),
      title: Text(
        member['name'] ?? '',
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            member['role'] ?? '',
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
          const SizedBox(height: 4),
          Text(
            member['bio'] ?? '',
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      drawer: const GuideraDrawer(selectedIndex: 1),
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
              "About Guidera",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: "Overview",
              content: Text(
                _overviewText,
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary(context)),
              ),
              context: context,
            ),
            _buildSection(
              title: "Our Team",
              content: Column(
                children: _team.map((member) => _buildTeamMember(member, context)).toList(),
              ),
              context: context,
            ),
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
                  Text(
                    "Made with passion by UCP students as Final Year Project.",
                    style: TextStyle(fontSize: 16, color: AppColors.textPrimary(context)),
                  ),
                ],
              ),
              context: context,
            ),
          ],
        ),
      ),
    );
  }
}