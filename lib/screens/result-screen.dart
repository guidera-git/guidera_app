// result-screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/screens/question-screen.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/Widgets/header.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:guidera_app/services/api_service.dart';

/// Screen that displays overall test percentage, grade, and details.
/// Also offers “Review Answers” and “Try Again” functionality.
class ResultsScreen extends StatefulWidget {
  final String subjectName;
  final Map<String, dynamic> attemptData;
  final List<dynamic> resultsList;

  const ResultsScreen({
    Key? key,
    required this.subjectName,
    required this.attemptData,
    required this.resultsList,
  }) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();

}

class _ResultsScreenState extends State<ResultsScreen> {
  late int totalQuestions;
  late int correctCount;
  late double percentage; // 0.0–1.0
  late String gradeLetter;
  late String formattedDate; // “MMM dd, yyyy • hh:mm a”
  final ApiService _apiService = ApiService();
  bool isRetrying = false;

  @override
  void initState() {
    super.initState();
    _computeResults();
  }

  void _computeResults() {
    totalQuestions = widget.resultsList.length;
    correctCount = widget.resultsList
        .where((res) => (res['is_correct'] == true))
        .length;
    percentage = totalQuestions > 0
        ? correctCount / totalQuestions
        : 0.0;

    // Compute letter grade from percentage
    if (percentage >= 0.8) {
      gradeLetter = "A";
    } else if (percentage >= 0.6) {
      gradeLetter = "B";
    } else if (percentage >= 0.4) {
      gradeLetter = "C";
    } else if (percentage >= 0.2) {
      gradeLetter = "D";
    } else {
      gradeLetter = "F";
    }

    // Format the current date/time
    formattedDate =
        DateFormat("MMM dd, yyyy  •  hh:mm a").format(DateTime.now());
  }

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

  String getPerformanceMessage(double pct) {
    if (pct >= 0.8) {
      return "Excellent performance!";
    } else if (pct >= 0.6) {
      return "Good effort, keep improving!";
    } else {
      return "Needs improvement, try harder!";
    }
  }

  Future<void> _retryTest() async {
    setState(() {
      isRetrying = true;
    });

    try {
      final resp = await _apiService.startTest(widget.subjectName);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        // data = { "attemptId": "...", "startedAt": "...", "questions": [ {...}, ... ] }
        final String newAttemptId = data['attemptId'];
        final List<dynamic> newQuestions = data['questions'];

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => QuestionScreen(
                subjectName: widget.subjectName,
                attemptId: newAttemptId,
                questions: newQuestions,
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start a new test: ${resp.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting new test: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isRetrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showTryAgain = gradeLetter.toUpperCase() == "F";

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
                  // Simply pop to go back to previous screen (e.g. entry test list).
                  Navigator.pop(context);
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
            // Subject Name, Date/Time, Performance Message.
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.subjectName,
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
                          text: getPerformanceMessage(percentage),
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
                progressColor:
                percentage >= 0.6 ? Colors.greenAccent : Colors.redAccent,
                backgroundColor: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 20),
            Center(
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
                    gradeLetter,
                    style: TextStyle(
                      color: getGradeColor(gradeLetter),
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
                      _buildDetailItem(
                          "Correct", correctCount, Colors.greenAccent),
                      _buildDetailItem("Incorrect",
                          totalQuestions - correctCount, Colors.redAccent),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Performance Chart
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
                      correct: correctCount,
                      incorrect: totalQuestions - correctCount,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Call-to-Action buttons: Review Answers and Try Again
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Always show REVIEW ANSWERS
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReviewAnswersScreen(
                            subjectName: widget.subjectName,
                            resultsList: widget.resultsList,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility, color: Colors.white),
                    label: const Text("Review Answers"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

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

/// PerformanceChart widget using fl_chart to display a simple bar chart.
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
                  style: TextStyle(
                      color: AppColors.myWhite, fontSize: 12),
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
                    style: TextStyle(
                        color: AppColors.myWhite, fontSize: 12),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
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

/// A new screen that displays each attempted question, shows the user’s selected answer,
/// highlights the correct answer, and prints the one-line explanation underneath.
class ReviewAnswersScreen extends StatelessWidget {
  final String subjectName;
  final List<dynamic> resultsList;

  const ReviewAnswersScreen({
    Key? key,
    required this.subjectName,
    required this.resultsList,
  }) : super(key: key);

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
        title: const Text("Review Answers",
            style: TextStyle(color: AppColors.myWhite)),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: resultsList.length,
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemBuilder: (context, index) {
          final res = resultsList[index] as Map<String, dynamic>;
          final questionText = res['question'] as String;
          final options =
          (res['options'] as List<dynamic>).cast<String>();
          final selectedAns = res['selected_ans'] as String;
          final correctAns = res['correct_ans'] as String;
          final explanation = res['explanation'] as String;
          final isCorrect = res['is_correct'] as bool;

          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0),
            child: Card(
              color: AppColors.lightBlack,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q${index + 1}. $questionText',
                      style: TextStyle(
                          color: AppColors.myWhite,
                          fontSize: 17),
                    ),
                    const SizedBox(height: 8),
                    ...options.map((opt) {
                      Color textColor = AppColors.myWhite;
                      if (opt == correctAns) {
                        textColor = Colors.greenAccent;
                      } else if (opt == selectedAns &&
                          selectedAns != correctAns) {
                        textColor = Colors.redAccent;
                      }
                      return Padding(
                        padding:
                        const EdgeInsets.symmetric(
                            vertical: 2.0),
                        child: Row(
                          children: [
                            Icon(
                              opt == selectedAns
                                  ? Icons.radio_button_checked
                                  : Icons
                                  .radio_button_unchecked,
                              color: opt == correctAns
                                  ? Colors.greenAccent
                                  : opt == selectedAns &&
                                  selectedAns !=
                                      correctAns
                                  ? Colors.redAccent
                                  : AppColors.myGray,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                opt,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 8),
                    Text(
                      'Explanation: $explanation',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isCorrect
                          ? 'You answered correctly.'
                          : 'Your answer was incorrect.',
                      style: TextStyle(
                        color:
                        isCorrect ? Colors.greenAccent : Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
