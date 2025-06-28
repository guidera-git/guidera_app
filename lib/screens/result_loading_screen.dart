import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

class _ResultLoaderScreenState extends State<ResultLoaderScreen>
    with TickerProviderStateMixin {
  int _currentMessageIndex = 0;
  final List<String> _messages = [
    "Calculating your marks...",
    "Results are coming soon...",
    "Finalizing your score...",
    "Almost there!",
    "Your result is ready!"
  ];
  late Timer _messageTimer;
  final ApiService _apiService = ApiService();
  bool _isLoading = true;

  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startMessageCycle();
    _fetchResultContinuously(); // FIXED: Start fetching immediately
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  void _startMessageCycle() {
    _messageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _isLoading) {
        setState(() => _currentMessageIndex =
            (_currentMessageIndex + 1) % _messages.length);
      }
    });
  }

  // FIXED: Continuously fetch results until available
  Future<void> _fetchResultContinuously() async {
    while (_isLoading && mounted) {
      try {
        final resp = await _apiService.getTestResult(widget.attemptId);
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);

          // Stop loading and navigate to results
          _messageTimer.cancel();
          setState(() => _isLoading = false);

          if (mounted) {
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
          }
          return;
        } else if (resp.statusCode == 404) {
          // Result not ready yet, wait and try again
          await Future.delayed(const Duration(seconds: 2));
        } else {
          // Other error, show error message
          if (mounted) {
            _showErrorAndGoBack('Failed to fetch results: ${resp.statusCode}');
          }
          return;
        }
      } catch (e) {
        // Network or other error, wait and try again
        await Future.delayed(const Duration(seconds: 3));
      }
    }
  }

  void _showErrorAndGoBack(String message) {
    _messageTimer.cancel();
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageTimer.cancel();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: Stack(
        children: [
          Column(
            children: [
              const GuideraHeader(),
              Expanded(child: _buildLoadingContent()),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 35,
            left: 20,
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/images/back.svg',
                color: AppColors.textPrimary(context),
                width: 34,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 50),
          _buildThinkingMessages(),
          const SizedBox(height: 40),
          _buildAnimatedLoader(),
          const SizedBox(height: 30),
          _buildProgressIndicator(),
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
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Please wait while we process your results...',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedLoader() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.lightBlue,
                    AppColors.darkBlue,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.lightBlue.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.analytics,
                color: AppColors.myWhite,
                size: 40,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      width: 200,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.borderColor(context),
        borderRadius: BorderRadius.circular(2),
      ),
      child: LinearProgressIndicator(
        backgroundColor: Colors.transparent,
        valueColor: AlwaysStoppedAnimation(AppColors.lightBlue),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}