import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/screens/home_screen.dart';
import 'package:guidera_app/screens/login.dart';
import 'package:guidera_app/screens/signup.dart';
import 'package:guidera_app/theme/app_colors.dart';
import '../Widgets/header.dart';

class LoginSignup extends StatefulWidget {
  const LoginSignup({Key? key}) : super(key: key);

  @override
  State<LoginSignup> createState() => _LoginSignupState();
}

class _LoginSignupState extends State<LoginSignup> {
  final List<String> _texts = [
    "Let's Discover",
    "Let's Explore",
    "Let's Brainstorm",
    "Let's Collaborate",
    "Let's Achieve"
  ];

  String _currentDisplay = "";
  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTypingLoop();
  }

  Future<void> _startTypingLoop() async {
    const initialDelay = Duration(milliseconds: 500);
    const typingDuration = Duration(milliseconds: 200);
    const pauseDuration = Duration(milliseconds: 1000);

    while (mounted) {
      final text = _texts[_currentTextIndex];

      setState(() {
        _currentDisplay = "";
      });
      await Future.delayed(initialDelay);

      for (int i = 1; i <= text.length; i++) {
        if (!mounted) return;
        setState(() {
          _currentDisplay = text.substring(0, i);
        });
        await Future.delayed(typingDuration);
      }

      await Future.delayed(pauseDuration);

      for (int i = text.length; i >= 0; i--) {
        if (!mounted) return;
        setState(() {
          _currentDisplay = text.substring(0, i);
        });
        await Future.delayed(typingDuration);
      }

      await Future.delayed(initialDelay);
      _currentTextIndex = (_currentTextIndex + 1) % _texts.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final double containerHeight = size.height * 0.28;
    final double containerCurveRadius = 30.0;
    final double buttonSpacing = 12.0;
    final double containerHorizontalPadding = 16.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: Stack(
          children: [
            const GuideraHeader(),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentDisplay,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SvgPicture.asset(
                  "assets/images/dot.svg",
                  height: 52,
                  color: AppColors.darkBlue,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: containerHeight,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkBlack : AppColors.lightSurface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(containerCurveRadius),
                  topRight: Radius.circular(containerCurveRadius),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor(context),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(
                horizontal: containerHorizontalPadding,
                vertical: 10,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 350,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? AppColors.myWhite : AppColors.lightSurface,
                        foregroundColor: isDarkMode ? AppColors.myBlack : AppColors.lightTextPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 3,
                      ),
                      onPressed: () {
                        // TODO: Implement Google sign-in
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/images/google.svg",
                            height: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Continue with Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    width: 350,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? AppColors.lightBlack : AppColors.lightBorder,
                        foregroundColor: AppColors.textPrimary(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: buttonSpacing),
                  Container(
                    width: 340,
                    height: 1,
                    color: AppColors.borderColor(context),
                  ),
                  SizedBox(height: buttonSpacing),
                  SizedBox(
                    width: 350,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        foregroundColor: AppColors.myWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 3,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
