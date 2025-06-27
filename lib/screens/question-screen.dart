import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guidera_app/services/api_service.dart';
import 'package:guidera_app/screens/result_loading_screen.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import '../widgets/header.dart';

class Question {
  final String id;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  String? selectedOption;

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.selectedOption,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id']?.toString() ?? '',
      questionText: json['question']?.toString() ?? '',
      options: (json['options'] as List<dynamic>?)
          ?.map((o) => o.toString())
          .toList() ??
          [],
      correctAnswer: json['correct_ans']?.toString() ?? '',
    );
  }
}

class QuestionProvider extends ChangeNotifier {
  final String subjectName;
  final String attemptId;
  final List<Question> questions;
  bool isLoading = true;
  bool submitting = false;
  int progress = 0;
  String timeLeft = '00:30';
  late Timer _timer;
  final ApiService _apiService = ApiService();

  final ScrollController scrollController = ScrollController();
  double sliderPosition = 0.0;
  static const double questionWidgetHeight = 200.0;

  QuestionProvider({
    required this.subjectName,
    required this.attemptId,
    required List<dynamic> rawQuestions,
  }) : questions = rawQuestions
      .map((q) => Question.fromJson(q as Map<String, dynamic>))
      .toList() {
    _startTimer();
    _setupScrollListener();
    _updateProgress();
    isLoading = false;
    notifyListeners();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      sliderPosition = (scrollController.offset /
          (questions.length * questionWidgetHeight))
          .clamp(0.0, 1.0);
      notifyListeners();
    });
  }

  void selectAnswer(int index, String option) {
    questions[index].selectedOption = option;
    _updateProgress();
    notifyListeners();
  }

  void _updateProgress() {
    final answered =
        questions.where((q) => q.selectedOption != null).length;
    progress = ((answered / questions.length) * 100).toInt();
  }

  void _startTimer() {
    int totalTime = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (totalTime <= 0) {
        timer.cancel();
        timeLeft = '00:00';
        notifyListeners();
      } else {
        totalTime--;
        final minutes = (totalTime ~/ 60).toString().padLeft(2, '0');
        final seconds = (totalTime % 60).toString().padLeft(2, '0');
        timeLeft = '$minutes:$seconds';
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> submitAnswers(BuildContext context) async {
    submitting = true;
    notifyListeners();

    final answers = <String, String>{
      for (var q in questions)
        if (q.selectedOption != null) q.id: q.selectedOption!,
    };

    try {
      final resp = await _apiService.submitTest(attemptId, answers);
      if (resp.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultLoaderScreen(
              attemptId: attemptId,
              subjectName: subjectName,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Submission failed: ${resp.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}

class QuestionScreen extends StatefulWidget {
  final String subjectName;
  final String attemptId;
  final List<dynamic> questions;

  const QuestionScreen({
    Key? key,
    required this.subjectName,
    required this.attemptId,
    required this.questions,
  }) : super(key: key);

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  bool isChecked = false;
  String userName = '';
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final resp = await _apiService.getProfile();
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      setState(() => userName = data['fullname'] as String? ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: ChangeNotifierProvider(
        create: (_) => QuestionProvider(
          subjectName: widget.subjectName,
          attemptId: widget.attemptId,
          rawQuestions: widget.questions,
        ),
        child: Consumer<QuestionProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.timeLeft == '00:00') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TimeUpScreen(
                      subjectName: widget.subjectName,
                    ),
                  ),
                );
              });
              return Container();
            }

            final allAttempted =
            provider.questions.every((q) => q.selectedOption != null);

            return Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(
                        height: 120, child: GuideraHeader()),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.subjectName,
                              style: TextStyle(
                                  color: AppColors.textPrimary(context),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              SvgPicture.asset(
                                  'assets/images/timer.svg',
                                  width: 20,
                                  height: 20,
                                  color: AppColors.textPrimary(context)),
                              const SizedBox(width: 8),
                              Text(provider.timeLeft,
                                  style: TextStyle(
                                      color: AppColors.textPrimary(context),
                                      fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: provider.progress / 100,
                          backgroundColor: AppColors.borderColor(context),
                          valueColor: AlwaysStoppedAnimation(
                              AppColors.primary(context)),
                          minHeight: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: provider.scrollController,
                        child: Column(
                          children: provider.questions
                              .asMap()
                              .entries
                              .map((entry) {
                            final idx = entry.key;
                            final q = entry.value as Question;
                            return Padding(
                              padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0),
                              child: Card(
                                color: AppColors.surfaceColor(context),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(16)),
                                child: Padding(
                                  padding:
                                  const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Q${idx + 1}. ${q.questionText}',
                                          style: TextStyle(
                                              color:
                                              AppColors.textPrimary(context),
                                              fontSize: 17)),
                                      ...q.options.map(
                                              (opt) =>
                                              RadioListTile<String>(
                                                value: opt,
                                                groupValue:
                                                q.selectedOption,
                                                onChanged: (val) =>
                                                    provider.selectAnswer(
                                                        idx, val!),
                                                title: Text(opt,
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .textPrimary(context))),
                                                activeColor: AppColors
                                                    .primary(context),
                                              )),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const SizedBox(height: 90),
                        Checkbox(
                          value: isChecked,
                          onChanged: allAttempted
                              ? (val) =>
                              setState(() => isChecked = val!)
                              : null,
                          activeColor: AppColors.primary(context),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontSize: 16,
                              ),
                              children: [
                                TextSpan(text: 'I, '),
                                TextSpan(
                                  text: userName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                  ', understand that submitting work that isn\'t my own may result in failure or account deactivation.',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: ElevatedButton(
                        onPressed: allAttempted &&
                            isChecked &&
                            !provider.submitting
                            ? () => provider.submitAnswers(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary(context),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: provider.submitting
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text('Submit'),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 83,
                  left: 23,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor(context),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowColor(context),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/images/back.svg',
                        height: 24,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -17,
                  top: 200,
                  bottom: 27,
                  width: 40,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final trackHeight =
                          constraints.maxHeight;
                      var y = trackHeight * provider.sliderPosition;
                      y = y.clamp(0.0, trackHeight - 20);
                      final currentIdx = (provider
                          .scrollController.offset /
                          QuestionProvider
                              .questionWidgetHeight)
                          .round()
                          .clamp(
                          0, provider.questions.length - 1);

                      return Stack(
                        children: [
                          Positioned(
                            left: 9,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 2,
                              color: AppColors.borderColor(context),
                            ),
                          ),
                          Positioned(
                            top: y,
                            left: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primary(context),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${currentIdx + 1}',
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

class TimeUpScreen extends StatefulWidget {
  final String subjectName;

  const TimeUpScreen({
    Key? key,
    required this.subjectName,
  }) : super(key: key);

  @override
  _TimeUpScreenState createState() => _TimeUpScreenState();
}

class _TimeUpScreenState extends State<TimeUpScreen> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor(context),
        title: Text(
          'Time\'s Up',
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/back.svg',
            color: AppColors.textPrimary(context),
            height: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Time has ended!\nYou have failed this test.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}