import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/Widgets/header.dart';
import 'package:guidera_app/screens/entrytest-screen.dart';
import 'package:guidera_app/screens/question-screen.dart'; // Contains your Question model

class ReviewAnswersScreen extends StatelessWidget {
  final List<Question> questions;
  final String subjectName;
  final String grade;
  final String userName;

  const ReviewAnswersScreen({
    Key? key,
    required this.questions,
    required this.subjectName,
    required this.grade,
    required this.userName,
  }) : super(key: key);

  // Helper: Determines if the Try Again button should be shown (only for grade F).
  bool get _showTryAgain => grade.toUpperCase() == "F";

  // Helper: Returns a summary message based on performance.
  String get summaryMessage {
    final int total = questions.length;
    final int correct = questions.where((q) => q.selectedOption == q.correctAnswer).length;
    return "You answered $correct out of $total correctly.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlack,
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
                  "assets/images/back.svg",
                  color: AppColors.myWhite,
                  height: 30,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary Header: subject, date/time, user & performance summary.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subjectName,
                  style: const TextStyle(
                    color: AppColors.myWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "User: $userName",
                  style: const TextStyle(
                    color: AppColors.myWhite,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  summaryMessage,
                  style: const TextStyle(
                    color: AppColors.myWhite,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          // Expanded ListView to review each question.
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: questions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final question = questions[index];
                final bool isCorrect = question.selectedOption == question.correctAnswer;
                return Card(
                  color: AppColors.lightBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question text.
                        Text(
                          "Q${index + 1}: ${question.questionText}",
                          style: const TextStyle(
                            color: AppColors.myWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // User's answer.
                        Row(
                          children: [
                            const Text(
                              "Your Answer: ",
                              style: TextStyle(
                                color: AppColors.myWhite,
                                fontSize: 14,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                question.selectedOption ?? "Not Answered",
                                style: TextStyle(
                                  color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Correct answer.
                        Row(
                          children: [
                            const Text(
                              "Correct Answer: ",
                              style: TextStyle(
                                color: AppColors.myWhite,
                                fontSize: 14,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                question.correctAnswer,
                                style: const TextStyle(
                                  color: AppColors.myWhite,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // CTA Buttons: arranged vertically, full width.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Always show "Review Mistakes" button.
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReviewAnswersScreen(questions: questions, subjectName: subjectName, grade: grade, userName: userName),
                        ),
                      );
                    },
                    icon: const Icon(Icons.error_outline, color: Colors.white),
                    label: const Text("Review Mistakes"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Show "Try Again" button only if grade is F.
                if (_showTryAgain)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to the QuestionScreen to retake the test.
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuestionScreen(subjectName: subjectName),
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text("Try Again"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
