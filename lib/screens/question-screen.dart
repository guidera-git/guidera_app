// This file handles the UI and data model for dynamically loading questions based on subject selection.

import 'package:flutter/material.dart';
import 'package:guidera_app/screens/result_loading_screen.dart';
import 'package:provider/provider.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/screens/result-screen.dart';
import 'dart:async';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/Widgets/header.dart'; // <-- Import your color constants
import 'dart:math' as math;

// Question Model Class
class Question {
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  String? selectedOption;
  final Color color;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.selectedOption,
    this.color = AppColors.myWhite,
  });

  static List<Question> getQuestionsBySubject(String subjectName) {
    if (subjectName == 'Biology') {
      return [
        Question(
          questionText: 'Blood carries oxygen to?',
          options: ['Brain', 'Cells', 'Liver'],
          correctAnswer: 'Cells',
        ),
        Question(
          questionText: 'Photosynthesis occurs in?',
          options: ['Roots', 'Leaves', 'Stem'],
          correctAnswer: 'Leaves',
        ),
        Question(
          questionText: 'The largest organ in the human body is?',
          options: ['Liver', 'Skin', 'Heart'],
          correctAnswer: 'Skin',
        ),
        Question(
          questionText: 'Which cell organelle is called the powerhouse?',
          options: ['Nucleus', 'Mitochondria', 'Ribosome'],
          correctAnswer: 'Mitochondria',
        ),
        Question(
          questionText: 'What is the main function of red blood cells?',
          options: ['Fight infection', 'Carry oxygen', 'Digest food'],
          correctAnswer: 'Carry oxygen',
        ),
        Question(
          questionText: 'Which vitamin is produced by the skin?',
          options: ['Vitamin A', 'Vitamin C', 'Vitamin D'],
          correctAnswer: 'Vitamin D',
        ),
        Question(
          questionText: 'What is the smallest unit of life?',
          options: ['Cell', 'Atom', 'Molecule'],
          correctAnswer: 'Cell',
        ),
        Question(
          questionText: 'Which part of the plant absorbs water?',
          options: ['Leaves', 'Roots', 'Stem'],
          correctAnswer: 'Roots',
        ),
        Question(
          questionText: 'What is the function of white blood cells?',
          options: ['Carry oxygen', 'Fight infection', 'Digest food'],
          correctAnswer: 'Fight infection',
        ),
        Question(
          questionText: 'Which gas do plants absorb during photosynthesis?',
          options: ['Oxygen', 'Carbon dioxide', 'Nitrogen'],
          correctAnswer: 'Carbon dioxide',
        ),
      ];
    } else if (subjectName == 'Chemistry') {
      return [
        Question(
          questionText: 'Water is made up of?',
          options: ['H2O', 'CO2', 'NaCl'],
          correctAnswer: 'H2O',
        ),
        Question(
          questionText: 'Atomic number of Helium is?',
          options: ['1', '2', '3'],
          correctAnswer: '2',
        ),
        Question(
          questionText: 'What is the chemical symbol for gold?',
          options: ['Au', 'Ag', 'Gd'],
          correctAnswer: 'Au',
        ),
        Question(
          questionText: 'Which gas is most abundant in Earth\'s atmosphere?',
          options: ['Oxygen', 'Carbon dioxide', 'Nitrogen'],
          correctAnswer: 'Nitrogen',
        ),
        Question(
          questionText: 'What is the pH of pure water?',
          options: ['5', '7', '9'],
          correctAnswer: '7',
        ),
        Question(
          questionText: 'Which element is used in batteries?',
          options: ['Lithium', 'Sodium', 'Potassium'],
          correctAnswer: 'Lithium',
        ),
        Question(
          questionText: 'What is the chemical formula for table salt?',
          options: ['NaCl', 'H2O', 'CO2'],
          correctAnswer: 'NaCl',
        ),
        Question(
          questionText:
              'Which gas is responsible for the smell of rotten eggs?',
          options: ['Oxygen', 'Hydrogen sulfide', 'Carbon dioxide'],
          correctAnswer: 'Hydrogen sulfide',
        ),
        Question(
          questionText: 'What is the lightest element?',
          options: ['Helium', 'Hydrogen', 'Oxygen'],
          correctAnswer: 'Hydrogen',
        ),
        Question(
          questionText: 'Which metal is liquid at room temperature?',
          options: ['Mercury', 'Iron', 'Gold'],
          correctAnswer: 'Mercury',
        ),
      ];
    } else if (subjectName == 'Physics') {
      return [
        Question(
          questionText: 'What is the unit of force?',
          options: ['Joule', 'Newton', 'Watt'],
          correctAnswer: 'Newton',
        ),
        Question(
          questionText:
              'Which law states that every action has an equal and opposite reaction?',
          options: [
            'Newton\'s 1st Law',
            'Newton\'s 2nd Law',
            'Newton\'s 3rd Law'
          ],
          correctAnswer: 'Newton\'s 3rd Law',
        ),
        Question(
          questionText: 'What is the speed of light?',
          options: ['300,000 km/s', '150,000 km/s', '450,000 km/s'],
          correctAnswer: '300,000 km/s',
        ),
        Question(
          questionText: 'What is the SI unit of electric current?',
          options: ['Volt', 'Ampere', 'Ohm'],
          correctAnswer: 'Ampere',
        ),
        Question(
          questionText:
              'Which device converts mechanical energy into electrical energy?',
          options: ['Motor', 'Generator', 'Transformer'],
          correctAnswer: 'Generator',
        ),
        Question(
          questionText: 'What is the unit of resistance?',
          options: ['Ohm', 'Volt', 'Ampere'],
          correctAnswer: 'Ohm',
        ),
        Question(
          questionText: 'What is the formula for kinetic energy?',
          options: ['KE = mv', 'KE = 1/2 mv^2', 'KE = mgh'],
          correctAnswer: 'KE = 1/2 mv^2',
        ),
        Question(
          questionText: 'Which type of lens is used to correct myopia?',
          options: ['Convex', 'Concave', 'Plano-convex'],
          correctAnswer: 'Concave',
        ),
        Question(
          questionText: 'What is the unit of power?',
          options: ['Joule', 'Watt', 'Newton'],
          correctAnswer: 'Watt',
        ),
        Question(
          questionText: 'What is the acceleration due to gravity on Earth?',
          options: ['9.8 m/s^2', '10 m/s^2', '8.5 m/s^2'],
          correctAnswer: '9.8 m/s^2',
        ),
      ];
    } else if (subjectName == 'English') {
      return [
        Question(
          questionText: 'What is the past tense of "go"?',
          options: ['Went', 'Gone', 'Goed'],
          correctAnswer: 'Went',
        ),
        Question(
          questionText: 'Which word is a synonym for "happy"?',
          options: ['Sad', 'Joyful', 'Angry'],
          correctAnswer: 'Joyful',
        ),
        Question(
          questionText: 'What is the plural of "child"?',
          options: ['Childs', 'Children', 'Childes'],
          correctAnswer: 'Children',
        ),
        Question(
          questionText: 'Which word is an antonym for "begin"?',
          options: ['Start', 'End', 'Continue'],
          correctAnswer: 'End',
        ),
        Question(
          questionText: 'What is the comparative form of "good"?',
          options: ['Gooder', 'Better', 'Best'],
          correctAnswer: 'Better',
        ),
        Question(
          questionText: 'Which sentence is in the passive voice?',
          options: [
            'She wrote the letter.',
            'The letter was written by her.',
            'She is writing the letter.'
          ],
          correctAnswer: 'The letter was written by her.',
        ),
        Question(
          questionText: 'What is the superlative form of "far"?',
          options: ['Farther', 'Farthest', 'Farer'],
          correctAnswer: 'Farthest',
        ),
        Question(
          questionText: 'Which word is a preposition?',
          options: ['Run', 'Under', 'Happy'],
          correctAnswer: 'Under',
        ),
        Question(
          questionText: 'What is the past participle of "eat"?',
          options: ['Ate', 'Eaten', 'Eating'],
          correctAnswer: 'Eaten',
        ),
        Question(
          questionText: 'Which word is a conjunction?',
          options: ['And', 'Quickly', 'House'],
          correctAnswer: 'And',
        ),
      ];
    } else if (subjectName == 'Computer Science') {
      return [
        Question(
          questionText: 'What does CPU stand for?',
          options: [
            'Central Processing Unit',
            'Computer Processing Unit',
            'Central Process Unit'
          ],
          correctAnswer: 'Central Processing Unit',
        ),
        Question(
          questionText: 'Which language is used for web development?',
          options: ['Python', 'HTML', 'Java'],
          correctAnswer: 'HTML',
        ),
        Question(
          questionText: 'What is the binary equivalent of decimal 10?',
          options: ['1010', '1001', '1100'],
          correctAnswer: '1010',
        ),
        Question(
          questionText: 'Which data structure uses LIFO?',
          options: ['Queue', 'Stack', 'Array'],
          correctAnswer: 'Stack',
        ),
        Question(
          questionText: 'What is the full form of RAM?',
          options: [
            'Random Access Memory',
            'Read Access Memory',
            'Random Allocation Memory'
          ],
          correctAnswer: 'Random Access Memory',
        ),
        Question(
          questionText:
              'Which protocol is used for secure communication over the internet?',
          options: ['HTTP', 'HTTPS', 'FTP'],
          correctAnswer: 'HTTPS',
        ),
        Question(
          questionText: 'What is the primary function of an operating system?',
          options: ['Manage hardware', 'Run applications', 'Both'],
          correctAnswer: 'Both',
        ),
        Question(
          questionText: 'Which language is used for Android development?',
          options: ['Swift', 'Kotlin', 'C++'],
          correctAnswer: 'Kotlin',
        ),
        Question(
          questionText: 'What is the smallest unit of data in a computer?',
          options: ['Byte', 'Bit', 'Kilobyte'],
          correctAnswer: 'Bit',
        ),
        Question(
          questionText:
              'Which programming language is known as the "mother of all languages"?',
          options: ['C', 'Java', 'Python'],
          correctAnswer: 'C',
        ),
      ];
    }
    return [];
  }
}

class QuestionProvider extends ChangeNotifier {
  final String subjectName;
  List<Question> questions = [];
  bool isLoading = true;
  int progress = 0;
  String timeLeft = "02:00";
  Timer? _timer;

  // ScrollController and helper variables
  final ScrollController scrollController = ScrollController();
  double sliderPosition = 0.0;
  double questionWidgetHeight = 200.0;

  QuestionProvider({required this.subjectName}) {
    _loadQuestions();
    _startTimer();
    _setupScrollListener();
  }

  void _loadQuestions() {
    questions = Question.getQuestionsBySubject(subjectName);

    isLoading = false;
    notifyListeners();
  }

  void selectAnswer(int index, String selectedOption) {
    questions[index].selectedOption = selectedOption;
    progress = ((questions.where((q) => q.selectedOption != null).length /
                questions.length) *
            100)
        .toInt();
    notifyListeners();
  }

  // Update slider position based on scroll offset.
  void _setupScrollListener() {
    scrollController.addListener(() {
      // Update slider position based on scroll offset
      sliderPosition =
          scrollController.offset / (questions.length * questionWidgetHeight);
      sliderPosition = sliderPosition.clamp(0.0, 1.0);
      notifyListeners();
    });
  }
  int calculateTotalScore() {
    int totalScore = 0;
    for (var question in questions) {
      if (question.selectedOption == question.correctAnswer) {
        totalScore++;
      }
    }
    return totalScore;
  }

  String calculateGrade(int totalScore) {
    double percentage = (totalScore / questions.length) * 100;
    if (percentage >= 90) {
      return 'A';
    } else if (percentage >= 80) {
      return 'B';
    } else if (percentage >= 70) {
      return 'C';
    } else if (percentage >= 60) {
      return 'D';
    } else {
      return 'F';
    }
  }



  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    int totalTime = 120;

    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (totalTime == 0) {
        timer.cancel();
      } else {
        totalTime--;
        final minutes = (totalTime ~/ 60).toString().padLeft(2, '0');
        final seconds = (totalTime % 60).toString().padLeft(2, '0');
        timeLeft = "$minutes:$seconds";
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class QuestionScreen extends StatefulWidget {
  final String subjectName;

  const QuestionScreen({Key? key, required this.subjectName}) : super(key: key);

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      body: ChangeNotifierProvider(
        create: (_) => QuestionProvider(subjectName: widget.subjectName),
        child: Consumer<QuestionProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }
            bool allQuestionsAttempted =
                provider.questions.every((q) => q.selectedOption != null);
            bool isSubmitEnabled = allQuestionsAttempted && isChecked;

            return Stack(
              children: [
                Column(
                  children: [
                    // Guidera Header
                    const GuideraHeader(),
                    Align(
                      alignment: Alignment.centerLeft, // Align text to the left
                      child: Padding(
                        padding: const EdgeInsets.only(left: 23.0, bottom: 8.0),
                        // Adjusted padding to place above cards
                        child: Text(
                          widget.subjectName, // Display only the subject name
                          style: TextStyle(
                            color: AppColors.myWhite,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                        child: SizedBox(
                          height: 12, // Increase height of the progress bar
                          child: LinearProgressIndicator(
                            value: provider.progress / 100, // Progress value (0.0 to 1.0)
                            backgroundColor: AppColors.myWhite,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkBlue),
                          ),
                        ),
                      ),
                    ),

                    // Questions List
                    Expanded(
                      child: SingleChildScrollView(
                        controller: provider.scrollController,
                        child: Column(
                          children: [
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: provider.questions.length,
                              itemBuilder: (context, index) {
                                final question = provider.questions[index];
                                return Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.001,
                                  padding: const EdgeInsets.only(right: 17.0),
                                  // Decrease width to 90% of screen width
                                  alignment: Alignment.centerLeft,
                                  // Align to the left
                                  child: Card(
                                    margin: EdgeInsets.all(7.0),
                                    color: AppColors.lightBlack,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(17),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Q${index + 1}. ${question.questionText}',
                                            style: TextStyle(
                                              color: AppColors.myWhite,
                                              fontSize: 17,
                                            ),
                                          ),
                                          ...question.options.map((option) {
                                            return RadioListTile<String>(
                                              value: option,
                                              groupValue:
                                                  question.selectedOption,
                                              onChanged: (value) {
                                                provider.selectAnswer(
                                                    index, value!);
                                              },
                                              title: Text(
                                                option,
                                                style: TextStyle(
                                                  color: AppColors.myWhite,
                                                  fontSize:
                                                      15, // Decrease font size for MCQ options
                                                ),
                                              ),
                                              activeColor: AppColors.lightBlue,
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Honour Code and Submit Button
                            SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start, // Align checkbox and text to the top
                              children: [
                                Checkbox(
                                  value: isChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      isChecked = value!;
                                    });
                                  },
                                  activeColor: AppColors.lightBlue,
                                ),
                                SizedBox(width: 0), // Reduced space between checkbox and text
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 1, right: 20), // Minimal top padding for alignment
                                    child: Text(
                                      "I, Muhammad Aaliyan Umar, understand that submitting work that isn't my own may result in failure or account deactivation.",
                                      style: TextStyle(color: AppColors.myWhite),
                                      textAlign: TextAlign.left, // Ensure text is left-aligned
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: isSubmitEnabled
                                  ? () {
                                // Calculate total score and grade
                                int totalScore = provider.calculateTotalScore();
                                String grade = provider.calculateGrade(totalScore);

                                // Navigate to ResultLoaderScreen with subject name, score, and grade
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ResultLoaderScreen(
                                      onLoaderComplete: () {
                                        // Navigate to ResultScreen after loader completes
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ResultScreen(
                                              totalScore: totalScore, // Pass actual score
                                              grade: grade, // Pass actual grade
                                              subjectName: widget.subjectName, // Pass selected subject
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }
                                  : null,
                              child: Text('Submit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightBlue,
                                elevation: 4,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Back Button on the Left
                Positioned(
                  top: 83, // Adjust top position as needed
                  left: 23, // Adjust left position as needed
                  child: Transform.rotate(
                    angle: 0.0, // No rotation
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      // Return to EntryTestScreen
                      child: SvgPicture.asset(
                        "assets/images/back.svg",
                        height: 28,
                        colorFilter: ColorFilter.mode(
                          AppColors.myWhite,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),

                // Timer on the Right
                Positioned(
                  top: 85, // Align with the back button
                  right: 20, // Adjust right position as needed
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/timer.svg',
                        // Add your timer.svg path here
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.timeLeft,
                        style: TextStyle(
                          color: AppColors.myWhite,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Vertical Scrollbar on the Right
                Positioned(
                  right: -17,
                  // Positioned on the right side
                  top: 200,
                  // Adjust top position to align below the header and progress bar
                  bottom: 27,
                  width: 40,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double trackHeight = constraints.maxHeight;
                      double circleY = trackHeight * provider.sliderPosition;
                      circleY = circleY.clamp(0.0, trackHeight - 20);
                      int questionIndex = ((provider.scrollController.offset /
                                  provider.questionWidgetHeight)
                              .round())
                          .clamp(0, provider.questions.length - 1)
                          .toInt();
                      return Stack(
                        children: [
                          Positioned(
                            left: 9,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 2,
                              color: AppColors.myGray,
                            ),
                          ),
                          Positioned(
                            top: circleY,
                            left: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.lightBlue,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "${questionIndex + 1}",
                                style: const TextStyle(
                                  color: AppColors.myWhite,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
