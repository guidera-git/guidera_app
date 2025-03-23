import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/screens/question-screen.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/Widgets/header.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'entrytest-screen.dart';

// Placeholder for the ReviewAnswersScreen.
// Replace with your actual implementation.
class ReviewAnswersScreen extends StatelessWidget {
  const ReviewAnswersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      appBar: AppBar(
        backgroundColor: AppColors.darkBlack,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            "assets/images/back.svg",
            color: AppColors.myWhite,
            height: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Review Answers", style: TextStyle(color: AppColors.myWhite)),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "Review Answers Content Here",
          style: TextStyle(color: AppColors.myWhite, fontSize: 20),
        ),
      ),
    );
  }
}

class ResultsScreen extends StatelessWidget {
  final int totalScore;
  final String grade;
  final String subjectName;


  const ResultsScreen({
    Key? key,
    required this.totalScore,
    required this.grade,
    required this.subjectName,

  }) : super(key: key);

  // Helper to choose dynamic color for the grade letter.
  Color getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case "A":
        return Colors.greenAccent;
      case "B":
        return Colors.blueAccent;
      case "C":
        return Colors.orangeAccent;
      case "D":
        return Colors.yellowAccent;
      case "F":
        return Colors.redAccent;
      default:
        return Colors.white;
    }
  }

  // Helper to choose a performance message based on percentage.
  String getPerformanceMessage(double percentage) {
    if (percentage >= 0.8) {
      return "Excellent performance!";
    } else if (percentage >= 0.6) {
      return "Good effort, keep improving!";
    } else {
      return "Needs improvement, try harder!";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Assuming 10 questions per test.
    final int totalQuestions = 10;
    final double percentage = totalScore / totalQuestions;
    // Format current date and time.
    final String formattedDate = DateFormat("MMM dd, yyyy  •  hh:mm a").format(DateTime.now());
    final String performanceMessage = getPerformanceMessage(percentage);
    final bool showTryAgain = grade.toUpperCase() == "F";

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
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const EntryTestScreen(subjectName: '')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject Name, Date/Time, User Name and Performance Message.
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
                    formattedDate,
                    style: const TextStyle(
                      color: AppColors.myWhite,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      text: "",
                      style: const TextStyle(
                        color: AppColors.myWhite,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: performanceMessage,
                          style: const TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            color: AppColors.myWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),

            Center(
              // Reduced circular progress indicator.
              child: CircularPercentIndicator(
                radius: 120,
                lineWidth: 12,
                animation: true,
                percent: percentage,
                center: Text(
                  "${(percentage * 100).toInt()}%",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.myWhite,
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: percentage >= 0.6 ? Colors.greenAccent : Colors.redAccent,
                backgroundColor: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              // Grade text with dynamic colored grade letter.
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Grade: ",
                    style: TextStyle(
                      color: AppColors.myWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    grade,
                    style: TextStyle(
                      color: getGradeColor(grade),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Card for Correct vs Incorrect counts.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: AppColors.lightBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailItem("Correct", totalScore, Colors.greenAccent),
                      _buildDetailItem("Incorrect", totalQuestions - totalScore, Colors.redAccent),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Separate Card for Performance Chart.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: AppColors.lightBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    height: 200,
                    child: PerformanceChart(
                      correct: totalScore,
                      incorrect: totalQuestions - totalScore,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Call-to-Action buttons: Review Answers and Try Again.
        // Determine if "Try Again" should be shown.


// Call-to-Action buttons: always show "Review Answers", and show "Try Again" conditionally.
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                if (showTryAgain) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to the QuestionScreen for the respective subject.
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
                  ),
                ],
              ],
            ),
    const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Helper widget for displaying detail items.
  Widget _buildDetailItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          "$value",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.myWhite,
          ),
        ),
      ],
    );
  }
}

// PerformanceChart widget using fl_chart to display a simple bar chart.
class PerformanceChart extends StatelessWidget {
  final int correct;
  final int incorrect;

  const PerformanceChart({
    Key? key,
    required this.correct,
    required this.incorrect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = correct + incorrect;
    return BarChart(
      BarChartData(
        maxY: total.toDouble(),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: total / 5 > 0 ? total / 5 : 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(color: AppColors.myWhite, fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                String title;
                if (value.toInt() == 0) {
                  title = "Correct";
                } else if (value.toInt() == 1) {
                  title = "Incorrect";
                } else {
                  title = "";
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    title,
                    style: TextStyle(color: AppColors.myWhite, fontSize: 12),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: correct.toDouble(),
                color: Colors.greenAccent,
                width: 22,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: incorrect.toDouble(),
                color: Colors.redAccent,
                width: 22,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
