import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:guidera_app/theme/app_colors.dart';
import '../Widgets/header.dart';

class LoginSignup extends StatefulWidget {
  const LoginSignup({Key? key}) : super(key: key);

  @override
  State<LoginSignup> createState() => _LoginSignupState();
}

class _LoginSignupState extends State<LoginSignup> {
  // List of texts to cycle through (all texts will have constant style)
  final List<String> _texts = [
    "Let's Discover",
    "Let's Explore",
    "Let's Brainstorm",
    "Let's Collaborate",
    "Let's Achieve"
  ];

  // The text currently displayed (updated during the animation)
  String _currentDisplay = "";
  // The index of the current text in the list
  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTypingLoop();
  }

  // This async loop handles the full animation cycle:
  // 1) Dot only (empty text) -> 2) Typing text letter-by-letter ->
  // 3) Pause -> 4) Deleting letter-by-letter -> 5) Pause -> next text.
  Future<void> _startTypingLoop() async {
    // Timing configurations:
    const initialDelay = Duration(milliseconds: 500);
    const typingDuration = Duration(milliseconds: 200);
    const pauseDuration = Duration(milliseconds: 1000);

    while (mounted) {
      final text = _texts[_currentTextIndex];

      // Phase 1: Show dot only (empty text)
      setState(() {
        _currentDisplay = "";
      });
      await Future.delayed(initialDelay);

      // Phase 2: Type out text letter-by-letter
      for (int i = 1; i <= text.length; i++) {
        if (!mounted) return;
        setState(() {
          _currentDisplay = text.substring(0, i);
        });
        await Future.delayed(typingDuration);
      }

      // Phase 3: Pause with full text visible
      await Future.delayed(pauseDuration);

      // Phase 4: Delete text letter-by-letter
      for (int i = text.length; i >= 0; i--) {
        if (!mounted) return;
        setState(() {
          _currentDisplay = text.substring(0, i);
        });
        await Future.delayed(typingDuration);
      }

      // Phase 5: Pause with empty text (dot centered)
      await Future.delayed(initialDelay);

      // Move to the next text in the list (cycling forever)
      _currentTextIndex = (_currentTextIndex + 1) % _texts.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // Adjustable parameters for the bottom curved container and button layout
    final double containerHeight = size.height * 0.28;
    final double containerCurveRadius = 30.0;
    final double buttonSpacing = 12.0;
    final double containerHorizontalPadding = 16.0;

    return Scaffold(
      // Fixed scaffold background color (myBlack)
      backgroundColor: AppColors.myBlack,
      // ---------------------------------------------------
      // 1) GuideraHeader app bar with back/home icons
      // ---------------------------------------------------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Stack(
          children: [
            const GuideraHeader(),
            // Top-left: Back button
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
                  Navigator.pop(context);
                },
              ),
            ),
            // Top-right: Home button
            Positioned(
              top: 70,
              right: 20,
              child: IconButton(
                icon: SvgPicture.asset(
                  "assets/images/home.svg",
                  color: AppColors.myWhite,
                  height: 30,
                ),
                onPressed: () {
                  // TODO: Implement home navigation logic
                },
              ),
            ),
          ],
        ),
      ),
      // ---------------------------------------------------
      // 2) Body: Custom typewriter animation with dot, plus bottom container with buttons
      // ---------------------------------------------------
      body: Stack(
        children: [
          // Positioned widget to control vertical placement of the text + dot row
          Positioned(
            top: 200, // Adjust this value to move the text vertically
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display the animated text (updates letter-by-letter)
                Text(
                  _currentDisplay,
                  style: const TextStyle(
                    color: AppColors.myWhite,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Dot.svg is placed immediately after the text (no extra spacing)
                SvgPicture.asset(
                  "assets/images/dot.svg",
                  height: 52,
                  color: AppColors.darkBlue,
                ),
              ],
            ),
          ),

          // Bottom container with curved top corners and three buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: containerHeight,
              decoration: BoxDecoration(
                color: AppColors.darkBlack,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(containerCurveRadius),
                  topRight: Radius.circular(containerCurveRadius),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: containerHorizontalPadding,
                vertical: 10,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1) "Continue with Google" button
                  SizedBox(
                    width: 350,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.myWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
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
                            style: const TextStyle(
                              color: AppColors.myBlack,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  // 2) "Sign up" button
                  SizedBox(
                    width: 350,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Sign up logic
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: AppColors.myWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Thin separator line
                  SizedBox(height: buttonSpacing),
                  Container(
                    width: 340,
                    height: 1,
                    color: AppColors.myGray,
                  ),
                  SizedBox(height: buttonSpacing),
                  // 3) "Log in" button
                  SizedBox(
                    width: 350,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Login logic
                      },
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          color: AppColors.myWhite,
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
