import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../Widgets/header.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import 'recommendation_results_screen.dart';
import '../models/user_profile.dart'; // we’ll parse into this model

class RecommendationLoadingScreen extends StatefulWidget {
  final Map<String, dynamic> payload;

  const RecommendationLoadingScreen({
    Key? key,
    required this.payload,
  }) : super(key: key);

  @override
  State<RecommendationLoadingScreen> createState() =>
      _RecommendationLoadingScreenState();
}

class _RecommendationLoadingScreenState
    extends State<RecommendationLoadingScreen>
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
  late Timer _msgTimer;
  final ApiService _api = ApiService();
  String? _userName;

  @override
  void initState() {
    super.initState();
    // Start the rotating brain animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Cycle messages
    _msgTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() =>
        _currentMessageIndex = (_currentMessageIndex + 1) % _messages.length);
      }
    });

    // Kick off the prediction call
    _loadProfileAndPredict();
  }

  Future<void> _loadProfileAndPredict() async {
    try {
      // Fetch profile (must be authenticated)
      final profileResp = await _api.getProfile();
      if (profileResp.statusCode == 200) {
        final profileJson = jsonDecode(profileResp.body);
        _userName = profileJson['fullname'] as String? ?? '';
      } else {
        _userName = '';
      }

      // Then call prediction
      final predResp = await _api.predictDegree(widget.payload);
      final predJson = jsonDecode(predResp.body);
      final predictedDegree = predJson['predicted_degree'] as String;

      // Cleanup timers/animation
      _msgTimer.cancel();
      _controller.dispose();

      // Navigate to results, passing both userName and degree
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RecommendationResultsScreen(
            userName: _userName!,
            recommendedDegree: predictedDegree,
          ),
        ),
      );
    } catch (e) {
      _msgTimer.cancel();
      _controller.dispose();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _msgTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? AppColors.myWhite : AppColors.myBlack;

    return Scaffold(
      backgroundColor: AppColors.myBlack,
      body: Stack(
        children: [
          Column(
            children: [
              const GuideraHeader(),
              Expanded(child: _buildLoadingContent(isDark)),
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
          Text(
            _messages[_currentMessageIndex],
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 300,
            height: 100,
            child: Lottie.asset(
              'assets/animations/loader.json',
              animate: true,
              repeat: true,
              frameRate: FrameRate(60),
            ),
          ),
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
}
