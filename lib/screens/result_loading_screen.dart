import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:guidera_app/Widgets/header.dart'; // Your existing header component
import 'package:guidera_app/theme/app_colors.dart'; // Your color constants

class ResultLoaderScreen extends StatefulWidget {
  final VoidCallback onLoaderComplete; // Callback for navigation

  const ResultLoaderScreen({
    super.key,
    required this.onLoaderComplete, // Accept callback as parameter
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

  @override
  void initState() {
    super.initState();
    _startMessageCycle();
  }

  void _startMessageCycle() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() => _currentMessageIndex = (_currentMessageIndex + 1) % _messages.length);
        if (timer.tick * 3 >= 15) {
          timer.cancel();
          _navigateAfterLoader();
        }
      }
    });
  }

  void _navigateAfterLoader() {
    // Call the provided callback to handle navigation
    widget.onLoaderComplete();
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
          const SizedBox(height: 50), // Add some spacing
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