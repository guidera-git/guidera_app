import 'package:flutter/material.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/Widgets/header.dart'; // Import GuideraHeader
import 'package:flutter_svg/flutter_svg.dart'; // For using SVG images
import 'package:shared_preferences/shared_preferences.dart'; // For 24-hour cooldown

class ResultScreen extends StatelessWidget {
  final int totalScore;
  final String grade;
  final String subjectName;

  const ResultScreen({
    Key? key,
    required this.totalScore,
    required this.grade,
    required this.subjectName,
  }) : super(key: key);

  // Check if the user can retake the test
  Future<bool> canRetakeTest() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRetakeTimestamp = prefs.getInt('lastRetakeTimestamp') ?? 0;
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    final cooldownDuration = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

    return (currentTimestamp - lastRetakeTimestamp) >= cooldownDuration;
  }

  // Set the retake timestamp
  Future<void> setRetakeTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastRetakeTimestamp', DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate percentage
    double percentage = (totalScore / 10) * 100; // Assuming 10 questions

    // Feedback based on grade
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
      body: Column(
        children: [
          // Guidera Header at the top
          const GuideraHeader(),

          // Beautiful Interactive Card for Score and Grade
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: AppColors.lightBlack,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // Score and Grade Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subject: $subjectName',
                            style: TextStyle(
                              color: AppColors.myWhite,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Score: $totalScore/10',
                            style: TextStyle(
                              color: AppColors.myWhite,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Grade: $grade ($percentage%)',
                            style: TextStyle(
                              color: AppColors.myWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Celebration SVG on the right
                    SvgPicture.asset(
                      "assets/images/celebrate.svg", // Add your SVG image
                      height: 80,
                      colorFilter: ColorFilter.mode(
                        AppColors.lightBlue,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Feedback and Suggestions
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // Feedback
                    Text(
                      feedback,
                      style: TextStyle(
                        color: AppColors.myWhite,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),

                    // Suggestion for Improvement
                    Text(
                      suggestion,
                      style: TextStyle(
                        color: AppColors.myWhite,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),

                    // Retake Button (Conditional)

                      FutureBuilder<bool>(
                        future: canRetakeTest(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator(); // Show loading while checking cooldown
                          } else if (snapshot.hasData && snapshot.data!) {
                            return ElevatedButton(
                              onPressed: () async {
                                await setRetakeTimestamp(); // Set the retake timestamp
                                Navigator.pop(context); // Navigate back to retake the test
                              },
                              child: Text('Retake Test'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightBlue,
                                elevation: 4,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                            );
                          } else {
                            return Text(
                              'You can retake the test after 24 hours.',
                              style: TextStyle(
                                color: AppColors.myWhite,
                                fontSize: 16,
                              ),
                            );
                          }
                        },
                      ),
                    SizedBox(height: 20),

                    // Go to Next Item Button
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the next item or screen
                        Navigator.pop(context);
                      },
                      child: Text('Go to Next Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightBlue,
                        elevation: 4,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}