import 'package:flutter/material.dart';
import 'package:guidera_app/screens/question-screen.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/Widgets/header.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/animation.dart';


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
  int retakesLeft = 2; // Number of retakes left
  bool isRetakeEnabled = false; // Whether retake is allowed
  String retakeMessage = "You have 2 retakes left."; // Retake status message

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
    _checkRetakeStatus(); // Check retake status when the screen loads
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Check if the user can retake the test
  Future<void> _checkRetakeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRetakeTimestamp = prefs.getInt('lastRetakeTimestamp') ?? 0;
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    final cooldownDuration = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

    // Check if 24 hours have passed since the last retake
    if ((currentTimestamp - lastRetakeTimestamp) >= cooldownDuration) {
      setState(() {
        isRetakeEnabled = true;
      });
    } else {
      setState(() {
        isRetakeEnabled = false;
        retakeMessage = "You can retake the test after 24 hours.";
      });
    }

    // Update the number of retakes left
    final retakes = prefs.getInt('retakesLeft') ?? 2;
    setState(() {
      retakesLeft = retakes;
      if (retakesLeft <= 0) {
        retakeMessage = "No retakes left.";
      }
    });
  }

  // Handle retake button press
  Future<void> _handleRetake() async {
    if (retakesLeft <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No retakes left."),
        ),
      );
      return;
    }

    if (!isRetakeEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You can retake the test after 24 hours."),
        ),
      );
      return;
    }

    // Update retake count and timestamp
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('retakesLeft', retakesLeft - 1);
    await prefs.setInt('lastRetakeTimestamp', DateTime.now().millisecondsSinceEpoch);

    // Navigate back to the question screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionScreen(subjectName: widget.subjectName),
      ),
    );
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
      backgroundColor: AppColors.myBlack,
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
                  // Check if the previous screen is QuestionScreen
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop(); // Go back to the previous screen
                  } else {
                    // If QuestionScreen is not in the stack, navigate to it explicitly
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionScreen(subjectName: widget.subjectName),
                      ),
                    );
                  }
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

                // Retake Button (Only shown if the user failed)
                if (percentage < 70) // Show retake button only if the user failed
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                    child: Column(
                      children: [
                        Text(
                          retakeMessage,
                          style: TextStyle(
                            color: AppColors.myWhite,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _handleRetake,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isRetakeEnabled ? Colors.red : AppColors.darkGray, // Red color for retake button
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              "Retake Test",
                              style: TextStyle(
                                color: AppColors.darkBlue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }
}