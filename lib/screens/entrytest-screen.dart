import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/Widgets/header.dart';
import 'package:guidera_app/screens/home_screen.dart';
import 'package:guidera_app/screens/question-screen.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/services/api_service.dart';
import 'dart:math' as math;

/// Data model for each subject tile
class SubjectCard {
  final String title;
  final String iconPath;
  final LinearGradient gradient;
  final Color titleColor;
  final Color circleColor;
  final Color iconColor;
  final String code;

  const SubjectCard({
    required this.title,
    required this.iconPath,
    required this.gradient,
    required this.titleColor,
    required this.circleColor,
    required this.iconColor,
    required this.code,
  });
}

/// Consolidated list of subjects with backend codes
const subjects = <SubjectCard>[
  SubjectCard(
    title: 'Chemistry',
    iconPath: 'assets/images/chemistry.svg',
    gradient: LinearGradient(colors: [AppColors.myWhite, AppColors.myWhite]),
    titleColor: AppColors.darkBlue,
    circleColor: AppColors.darkBlue,
    iconColor: AppColors.myWhite,
    code: 'CHEMISTRY',
  ),
  SubjectCard(
    title: 'Biology',
    iconPath: 'assets/images/biology.svg',
    gradient: LinearGradient(colors: [AppColors.darkBlue, AppColors.darkBlue]),
    titleColor: AppColors.myWhite,
    circleColor: AppColors.myWhite,
    iconColor: AppColors.darkBlue,
    code: 'BIOLOGY',
  ),
  SubjectCard(
    title: 'Physics',
    iconPath: 'assets/images/physics.svg',
    gradient: LinearGradient(colors: [AppColors.darkBlack, AppColors.darkBlack]),
    titleColor: AppColors.myWhite,
    circleColor: AppColors.myWhite,
    iconColor: AppColors.myBlack,
    code: 'PHY',
  ),
  SubjectCard(
    title: 'English',
    iconPath: 'assets/images/english.svg',
    gradient: LinearGradient(colors: [AppColors.myWhite, AppColors.myWhite]),
    titleColor: AppColors.darkBlue,
    circleColor: AppColors.darkBlue,
    iconColor: AppColors.myWhite,
    code: 'ENGLISH',
  ),
  SubjectCard(
    title: 'Analytical Reasoning',
    iconPath: 'assets/images/test.svg',
    gradient: LinearGradient(colors: [AppColors.myWhite, AppColors.myWhite]),
    titleColor: AppColors.myWhite,
    circleColor: AppColors.myWhite,
    iconColor: AppColors.darkBlue,
    code: 'ANALYTICAL_REASONING',
  ),
];

class EntryTestScreen extends StatefulWidget {
  const EntryTestScreen({Key? key}) : super(key: key);

  @override
  State<EntryTestScreen> createState() => _EntryTestScreenState();
}

class _EntryTestScreenState extends State<EntryTestScreen> {
  final ApiService _apiService = ApiService();

  Future<void> _startTest(SubjectCard subject) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Call backend to initiate test
      final response = await _apiService.startTest(subject.code);
      Navigator.of(context).pop(); // hide loader

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final attemptId = data['attemptId'];
        final questions = data['questions'];

        //Navigate to QuestionScreen with payload
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuestionScreen(
              subjectName: subject.title,
              attemptId: attemptId,
              questions: questions,
            ),
          ),
        );
      } else {
        // Error handling
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start test: ${response.statusCode}')),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.myBlack,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Stack(
          children: [
            const GuideraHeader(),
            Positioned(
              top: 70,
              left: 10,
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/images/back.svg',
                  color: AppColors.myWhite,
                  height: 30,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const WelcomeCard(userName: 'Stay Focused!'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return SubjectCardWidget(
                    data: subject,
                    onTap: () => _startTest(subject),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SubjectCardWidget extends StatelessWidget {
  final SubjectCard data;
  final VoidCallback onTap;

  const SubjectCardWidget({Key? key, required this.data, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16.0),
      child: Ink(
        decoration: BoxDecoration(
          gradient: data.gradient,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.myBlack.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onTap,
          child: Stack(
            children: [
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: data.titleColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    data.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: data.titleColor.computeLuminance() > 0.5
                          ? AppColors.myBlack
                          : AppColors.myWhite,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: data.circleColor.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.myBlack.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Transform.rotate(
                    angle: 145 * math.pi / 180,
                    child: SvgPicture.asset(
                      'assets/images/back.svg',
                      width: 16,
                      height: 16,
                      color: data.iconColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: SvgPicture.asset(
                  data.iconPath,
                  height: 50,
                  width: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomeCard extends StatelessWidget {
  final String userName;

  const WelcomeCard({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.myWhite, AppColors.myGray],
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enjoy Preparing',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: AppColors.darkBlue,
                  ),
                ),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.normal,
                    color: AppColors.myBlack,
                  ),
                ),
              ],
            ),
          ),
          SvgPicture.asset(
            'assets/images/student_laptop.svg',
            height: 100.0,
            width: 80.0,
          ),
        ],
      ),
    );
  }
}