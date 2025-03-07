import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _hatController;
  late Animation<double> _hatAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _lineController;
  late Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();

    // Hat Animation (Bounce)
    _hatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _hatAnimation = Tween<double>(begin: -100, end: 0).animate(
      CurvedAnimation(parent: _hatController, curve: Curves.bounceOut),
    );

    _hatController.forward();

    // Fade Animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();

    // Line Filling Animation
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _lineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut),
    );

    _lineController.forward();

    // Navigate to Home after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _hatController.dispose();
    _fadeController.dispose();
    _lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Guidera Text
            Positioned(
              top: MediaQuery.of(context).size.height * 0.42,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "G",
                      style: TextStyle(
                        fontSize: 40,
                        fontFamily: "ProductSans",
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Blue color for "G"
                      ),
                    ),
                    TextSpan(
                      text: "uidera",
                      style: TextStyle(
                        fontSize: 40,
                        fontFamily: "ProductSans",
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black, // Black or white color for "uidera"
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Graduation Hat (Bounce Animation)
            AnimatedBuilder(
              animation: _hatAnimation,
              builder: (context, child) {
                return Positioned(
                  top: MediaQuery.of(context).size.height * 0.42 - 25 + _hatAnimation.value,
                  left: MediaQuery.of(context).size.width * 0.28 - 3,
                  child: Transform.rotate(
                    angle: -0.5, // Tilt angle in radians (-0.5 ≈ 28.6 degrees)
                    child: SvgPicture.asset(
                      "assets/images/hat.svg",
                      height: 40,
                      colorFilter: ColorFilter.mode(
                        isDarkMode ? Colors.blue : Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Lifeline (Filling Animation)
            AnimatedBuilder(
              animation: _lineAnimation,
              builder: (context, child) {
                return Positioned(
                  top: MediaQuery.of(context).size.height * 0.42 + 17,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: _lineAnimation.value, // Animate the width of the line
                      child: SvgPicture.asset(
                        "assets/images/line.svg",
                        width: 160, // Make it wide enough to cover the whole text
                        colorFilter: ColorFilter.mode(
                          isDarkMode ? Colors.white : Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Fade Animation (Optional: Apply to the entire Stack or specific widgets)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(), // Replace with the widget you want to fade
            ),
          ],
        ),
      ),
    );
  }
}