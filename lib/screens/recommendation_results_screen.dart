import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/Widgets/fancy_bottom_nav_bar.dart';
import 'package:guidera_app/Widgets/header.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/screens/university_search_screen.dart';

class RecommendationResultsScreen extends StatelessWidget {
  final String userName;
  final String recommendedDegree;

  const RecommendationResultsScreen({
    Key? key,
    required this.userName,
    required this.recommendedDegree,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.myBlack
          : AppColors.myWhite,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
              AppColors.myBlack,
              AppColors.lightBlack.withOpacity(0.9),
            ]
                : [
              AppColors.lightBackground,
              AppColors.lightSurface.withOpacity(0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const GuideraHeader(),
              _buildBackButton(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildMessageCard(context),
                      const SizedBox(height: 24),
                      _buildRecommendationCard(
                        context: context,
                        profession: recommendedDegree,
                        degree: "BS Computer Science",
                        university: "FAST NUCES Lahore",
                        avgSalary: "PKR 120,000",
                        demandStars: 4.5,
                        reason: "Based on your high aptitude for problem-solving and "
                            "strong math scores, this field matches your personality "
                            "and academic strengths.",
                        onViewMore: () => _navigateToSearch(context, recommendedDegree),
                      ),
                      const SizedBox(height: 20),
                      _buildAdditionalRecommendations(context),
                      const SizedBox(height: 20),
                      _buildAdditionalInfo(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -43),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor(context).withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor(context),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SvgPicture.asset(
                'assets/images/back.svg',
                width: 24,
                color: AppColors.textPrimary(context),
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isDarkMode
              ? [
            AppColors.lightBlack,
            AppColors.surfaceColor(context),
          ]
              : [
            AppColors.lightSurface,
            AppColors.lightBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 12,
            spreadRadius: 3,
          ),
        ],
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
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                          fontFamily: 'Product Sans',
                        ),
                      ),
                      TextSpan(
                        text: userName,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightBlue,
                          fontFamily: 'Product Sans',
                        ),
                      ),
                      TextSpan(
                        text: '! 🎉',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                          fontFamily: 'Product Sans',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Here are your personalized recommendations based on your academic profile and personality assessment:',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary(context),
                    height: 1.4,
                    fontFamily: 'Product Sans',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology,
              size: 40,
              color: AppColors.lightBlue,
            ),
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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.lightBlue.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 12,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.school,
                  color: AppColors.lightBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Recommended Field',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary(context),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Product Sans',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profession,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightBlue,
                        fontFamily: 'Product Sans',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: AppColors.lightBlue,
                    size: 20,
                  ),
                ),
                onPressed: () => _showReasonDialog(context, reason),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Career insights section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderColor(context),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Career Insights',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Product Sans',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInsightItem(
                        context,
                        'Market Demand',
                        'High',
                        Icons.trending_up,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildInsightItem(
                        context,
                        'Starting Salary',
                        avgSalary,
                        Icons.attach_money,
                        AppColors.lightBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInsightItem(
                        context,
                        'Growth Rate',
                        '15% annually',
                        Icons.show_chart,
                        Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _buildInsightItem(
                        context,
                        'Job Security',
                        'Very High',
                        Icons.security,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onViewMore,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              icon: Icon(
                Icons.search,
                color: AppColors.myWhite,
                size: 20,
              ),
              label: Text(
                'View Available Programs',
                style: TextStyle(
                  color: AppColors.myWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Product Sans',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                    fontFamily: 'Product Sans',
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Product Sans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalRecommendations(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: AppColors.lightBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Alternative Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                  fontFamily: 'Product Sans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAlternativeItem(
            context,
            'Software Engineering',
            '92% Match',
            'High demand in tech industry',
            Icons.computer,
          ),
          _buildAlternativeItem(
            context,
            'Data Science',
            '89% Match',
            'Growing field with AI/ML focus',
            Icons.analytics,
          ),
          _buildAlternativeItem(
            context,
            'Cybersecurity',
            '85% Match',
            'Critical need in digital era',
            Icons.security,
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeItem(BuildContext context, String title, String match, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToSearch(context, title),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.lightBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(context),
                            fontFamily: 'Product Sans',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            match,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Product Sans',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                        fontFamily: 'Product Sans',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.lightBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Next Steps',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                  fontFamily: 'Product Sans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNextStepItem(
            context,
            '1. Explore Programs',
            'Browse available programs in your recommended field',
            Icons.explore,
          ),
          _buildNextStepItem(
            context,
            '2. Compare Universities',
            'Compare fees, locations, and requirements',
            Icons.compare_arrows,
          ),
          _buildNextStepItem(
            context,
            '3. Prepare Applications',
            'Get ready for admission tests and applications',
            Icons.assignment,
          ),
          _buildNextStepItem(
            context,
            '4. Take Entry Tests',
            'Practice with our test preparation module',
            Icons.quiz,
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepItem(BuildContext context, String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.lightBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                    fontFamily: 'Product Sans',
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                    fontFamily: 'Product Sans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReasonDialog(BuildContext context, String reason) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor(context),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      color: AppColors.myWhite,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Why This Recommendation?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.myWhite,
                          fontFamily: 'Product Sans',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColors.myWhite,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    reason,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: AppColors.textPrimary(context),
                      fontFamily: 'Product Sans',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSearch(BuildContext context, String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UniversitySearchScreen(
          initialSearchQuery: query,
        ),
      ),
    );
  }
}