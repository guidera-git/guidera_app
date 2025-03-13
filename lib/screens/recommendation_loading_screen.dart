import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/screens/recommendation_results_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:guidera_app/Widgets/header.dart';        // Your existing header component
import 'package:guidera_app/theme/app_colors.dart'; // Your color constants

class RecommendationLoadingScreen extends StatefulWidget {
  const RecommendationLoadingScreen({super.key});

  @override
  State<RecommendationLoadingScreen> createState() => _RecommendationLoadingScreenState();
}

class _RecommendationLoadingScreenState extends State<RecommendationLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentMessageIndex = 0;
  final List<String> _messages = [
    "Analyzing your academic profile...",
    "Evaluating personality matches...",
    "Scanning university databases...",
    "Optimizing best choices...",
    "Almost there!"
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startMessageCycle();
  }

  void _startMessageCycle() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() => _currentMessageIndex = (_currentMessageIndex + 1) % _messages.length);
        if (timer.tick * 3 >= 15) {
          timer.cancel();
          _navigateToResults();
        }
      }
    });
  }

  void _navigateToResults() {
    // Replace with actual navigation
    Navigator.push(context, MaterialPageRoute(builder: (context) => RecommendationResultsScreen(),));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
          _buildAnimatedBrain(isDarkMode),
          const SizedBox(height: 30),
          _buildThinkingMessages(),
          const SizedBox(height: 40),
          _buildParticleAnimation(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBrain(bool isDarkMode) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isDarkMode ? AppColors.darkBlue : AppColors.lightBlue)
                .withOpacity(0.1),
          ),
        ),
        RotationTransition(
          turns: _controller,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: (isDarkMode ? AppColors.myWhite : AppColors.darkBlue)
                    .withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 120,
          height: 120,
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              (isDarkMode ? AppColors.myWhite : AppColors.darkBlue)
                  .withOpacity(0.8),
              BlendMode.srcIn,
            ),
            child: Lottie.asset(
              'assets/animations/ai_brain.json',
              animate: true,
            ),
          ),
        ),
      ],
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