import 'package:flutter/material.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/Widgets/header.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/animation.dart';
import 'package:guidera_app/Widgets/fancy_bottom_nav_bar.dart';
import 'package:guidera_app/Widgets/fancy_nav_item.dart';
import 'entrytest-screen.dart';

class ResultScreen extends StatefulWidget {
  final int totalScore;
  final String grade;
  final String subjectName;

  const ResultScreen({
    Key? key,
    required this.totalScore,
    required this.grade,
    required this.subjectName,
  }) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentIndex = 0;

  final List<FancyNavItem> items = [
    FancyNavItem(label: "Home", svgPath: "assets/images/home.svg"),
    FancyNavItem(label: "Search", svgPath: "assets/images/search.svg"),
    FancyNavItem(label: "Profile", svgPath: "assets/images/profile.svg"),
    FancyNavItem(label: "Notifications", svgPath: "assets/images/notification.svg"),
  ];

  Future<bool> canRetakeTest() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRetakeTimestamp = prefs.getInt('lastRetakeTimestamp') ?? 0;
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    final cooldownDuration = 24 * 60 * 60 * 1000;
    return (currentTimestamp - lastRetakeTimestamp) >= cooldownDuration;
  }

  Future<void> setRetakeTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastRetakeTimestamp', DateTime.now().millisecondsSinceEpoch);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double percentage = (widget.totalScore / 10) * 100;

    String feedback;
    String suggestion;
    if (percentage >= 90) {
      feedback = "Excellent! You have a strong understanding of the subject.";
      suggestion = "Keep up the good work and explore advanced topics.";
    } else if (percentage >= 80) {
      feedback = "Great job! You passed with a good score.";
      suggestion = "Review the questions you missed to improve further.";
    } else if (percentage >= 70) {
      feedback = "Good effort! You passed, but there's room for improvement.";
      suggestion = "Focus on the areas where you struggled.";
    } else {
      feedback = "You didn't pass this time, but don't give up!";
      suggestion = "Retake the test after reviewing the material.";
    }

    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      body: Stack(
        children: [
          const GuideraHeader(),
          Positioned(
            top: 85,
            left: 25,
            child: Transform.rotate(
              angle: 0.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EntryTestScreen(subjectName: ""),
                    ),
                  );
                },
                child: SvgPicture.asset(
                  "assets/images/back.svg",
                  height: 30,
                  colorFilter: ColorFilter.mode(
                    AppColors.myWhite,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 74,
            right: 25,
            child: CircleAvatar(
              radius: 21,
              backgroundImage: NetworkImage(
                  "https://avatars.githubusercontent.com/u/168419532?v=4"),
              backgroundColor: AppColors.darkBlue,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject Name Header
                Padding(
                  padding: const EdgeInsets.only(top: 170, left: 35, right: 20),
                  child: Text(
                    'Result: ${widget.subjectName}',
                    style: TextStyle(
                      color: AppColors.myWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),


                // Existing Card
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: AppColors.myWhite,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, Saad!",
                            style: TextStyle(
                              color: AppColors.myBlack,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Score: ${widget.totalScore}/10',
                            style: TextStyle(
                              color: AppColors.myBlack,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Grade: ${widget.grade} (${percentage.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              color: AppColors.myBlack,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Remarks: $feedback',
                            style: TextStyle(
                              color: AppColors.myBlack,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Progress Circle
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 330,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.lightBlue.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 210,
                        height: 210,
                        child: CircularProgressIndicator(
                          value: _animation.value,
                          strokeWidth: 5,
                          color: AppColors.lightBlue,
                        ),
                      ),
                      Text(
                        percentage >= 70
                            ? 'Congratulations\nPassed!'
                            : 'Failed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.myWhite,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: GuideraBottomNavBar(
        items: items,
        initialIndex: _currentIndex,
        onItemSelected: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}