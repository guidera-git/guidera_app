// result_loading_screen.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:guidera_app/Widgets/header.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/services/api_service.dart';
import 'package:guidera_app/screens/result-screen.dart';

class ResultLoaderScreen extends StatefulWidget {
  final String attemptId;
  final String subjectName;

  const ResultLoaderScreen({
    super.key,
    required this.attemptId,
    required this.subjectName,
  });

  @override
  State<ResultLoaderScreen> createState() => _ResultLoaderScreenState();
}

class _ResultLoaderScreenState extends State<ResultLoaderScreen> {
  int _currentMessageIndex = 0;
  final List<String> _messages = [
    "Calculating your marks...",
    "Results are coming soon...",
    "Finalizing your score...",
    "Almost there!",
    "Your result is ready!"
  ];
  late Timer _messageTimer;
  late Timer _fetchTimer;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _startMessageCycle();
    _scheduleFetchResult();
  }

  void _startMessageCycle() {
    _messageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() => _currentMessageIndex =
            (_currentMessageIndex + 1) % _messages.length);
      }
    });
  }

  void _scheduleFetchResult() {
    // After 15 seconds, cancel the message timer and fetch actual results.
    _fetchTimer = Timer(const Duration(seconds: 15), () async {
      _messageTimer.cancel();
      await _navigateAfterLoader();
    });
  }

  Future<void> _navigateAfterLoader() async {
    try {
      final resp = await _apiService.getTestResult(widget.attemptId);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        // data structure:
        // {
        //   "attempt": { "attempt_id": "...", "subject": "...", "started_at": "...", "completed_at": "...", "score": 80 },
        //   "results": [ { "id": "...", "question": "...", "options": [...], "selected_ans": "...", "correct_ans": "...", "explanation": "...", "is_correct": true }, ... ]
        // }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultsScreen(
              subjectName: widget.subjectName,
              attemptData: data['attempt'],
              resultsList: data['results'] as List<dynamic>,
            ),
          ),
        );
      } else {
        // If fetching results failed, pop back and show an error.
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch results: ${resp.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching results: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageTimer.cancel();
    _fetchTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkMode ? AppColors.myWhite : AppColors.myBlack;

    return Scaffold(
      backgroundColor: AppColors.myBlack,
      body: Stack(
        children: [
          Column(
            children: [
              const GuideraHeader(),
              Expanded(child: _buildLoadingContent(isDarkMode)),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 35,
            left: 20,
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/images/back.svg',
                color: iconColor,
                width: 34,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 50),
          _buildThinkingMessages(),
          const SizedBox(height: 40),
          _buildParticleAnimation(),
        ],
      ),
    );
  }

  Widget _buildThinkingMessages() {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            _messages[_currentMessageIndex],
            key: ValueKey(_currentMessageIndex),
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'This usually takes 10-15 seconds',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildParticleAnimation() {
    return SizedBox(
      width: 300,
      height: 100,
      child: Lottie.asset(
        'assets/animations/loader.json',
        animate: true,
        repeat: true,
        frameRate: FrameRate(60),
      ),
    );
  }
}
