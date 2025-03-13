import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/Widgets/fancy_bottom_nav_bar.dart';
import 'package:guidera_app/Widgets/header.dart';
import 'package:guidera_app/theme/app_colors.dart';

class RecommendationResultsScreen extends StatelessWidget {
  final String userName = "Ali Raza"; // Replace with actual user name

  const RecommendationResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.myBlack,
      body: Column(
        children: [
          const GuideraHeader(),
          _buildBackButton(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMessageCard(),
                  const SizedBox(height: 24),
                  _buildRecommendationCard(
                    context: context,
                    profession: "Software Engineering",
                    degree: "BS Computer Science",
                    university: "FAST NUCES Lahore",
                    avgSalary: "PKR 120,000",
                    demandStars: 4.5,
                    reason: "Based on your high aptitude for problem-solving and "
                        "strong math scores, this field matches your personality "
                        "and academic strengths.",
                    onViewMore: () => _navigateToSearch(context, "Computer Science"),
                  ),
                  // Add more recommendation cards as needed
                ],
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: GuideraBottomNavBar(
      //   items: const [], // Add your nav items
      //   initialIndex: 1,
      //   onItemSelected: (index) {},
      // ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -43), // Move it 20 pixels up. Adjust as needed.
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: SvgPicture.asset(
              'assets/images/back.svg',
              width: 29,
              color: AppColors.myWhite,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.lightGray, AppColors.darkGray],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Hi, ',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: userName,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Here are your personalized recommendations '
                      'based on your academic profile and personality:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.myBlack,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          SvgPicture.asset(
            'assets/images/recommendation_illustration.svg',
            width: 100,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard({
    required BuildContext context,
    required String profession,
    required String degree,
    required String university,
    required String avgSalary,
    required double demandStars,
    required String reason,
    required VoidCallback onViewMore,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  profession,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/images/info.svg',
                  width: 24,
                  color: AppColors.myBlack,
                ),
                onPressed: () => _showReasonDialog(context, reason),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn('Degree', degree),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn('University', university),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn('Avg Salary', avgSalary),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Demand',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Row(children: _buildDemandStars(demandStars)),
                  ],
                ),
              ],
            ),
          ),
    Transform.translate(
    offset: const Offset(-10, 0),
    child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onViewMore,
              icon: const Text('View More Options',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: AppColors.darkBlue,
                      decorationColor: AppColors.darkBlue)),
              label: SvgPicture.asset(
                'assets/images/right_arrow.svg',
                width: 16,
                color: AppColors.darkBlue,
              ),
            ),
          ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.myBlack,
            )),
      ],
    );
  }

  List<Widget> _buildDemandStars(double rating) {
    List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      stars.add(Icon(
        i < rating.floor()
            ? Icons.star
            : (i < rating ? Icons.star_half : Icons.star_border),
        color: AppColors.darkBlue,
        size: 20,
      ));
    }
    return stars;
  }

  void _showReasonDialog(BuildContext context, String reason) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: AppColors.darkBlue),
        ),
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
              minWidth: MediaQuery.of(context).size.width * 1.5,
            ),
            decoration: BoxDecoration(
              color: AppColors.myWhite.withOpacity(0.97),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkBlue.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -15,
                  right: -15,
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.myBlack,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkBlue.withOpacity(0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        color: AppColors.myWhite,
                        size: 28,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommendation Reason',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlue,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            reason,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: AppColors.myBlack.withOpacity(0.85),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSearch(BuildContext context, String query) {
    Navigator.pushNamed(
      context,
      '/university_search',
      arguments: {'searchQuery': query},
    );
  }
}