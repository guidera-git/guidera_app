import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:guidera_app/screens/home_screen.dart';
import 'package:guidera_app/screens/login-signup.dart';
import 'package:guidera_app/theme/app_colors.dart';

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

  // Storage for our JWT
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    // Hat Animation (Bounce)
    _hatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _hatAnimation = Tween<double>(begin: -200, end: 0).animate(
      CurvedAnimation(parent: _hatController, curve: Curves.bounceOut),
    );
    _hatController.forward();

    // Fade Animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();

    // Line Filling Animation
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _lineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut),
    );
    _lineController.forward();

    // After animations, decide where to go
    Timer(const Duration(seconds: 5), _checkAuthAndNavigate);
  }

  Future<void> _checkAuthAndNavigate() async {
    final token = await _storage.read(key: 'token');
    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginSignup()),
      );
    }
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
    final Color backgroundColor =
    isDarkMode ? AppColors.myBlack : AppColors.myWhite;
    final Color guideraTextColor =
    isDarkMode ? AppColors.myWhite : AppColors.myBlack;
    final Color hatColor =
    isDarkMode ? AppColors.lightBlue : AppColors.myBlack;
    final Color lineColor =
    isDarkMode ? AppColors.myWhite : AppColors.myBlack;

    return Scaffold(
      backgroundColor: backgroundColor,
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
                        fontSize: 50,
                        fontFamily: "ProductSans",
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightBlue,
                      ),
                    ),
                    TextSpan(
                      text: "uidera.",
                      style: TextStyle(
                        fontSize: 40,
                        fontFamily: "ProductSans",
                        fontWeight: FontWeight.bold,
                        color: guideraTextColor,
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
                  top: MediaQuery.of(context).size.height * 0.42 - 22 + _hatAnimation.value,
                  left: MediaQuery.of(context).size.width * 0.28 - 19,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: SvgPicture.asset(
                      "assets/images/hat.svg",
                      height: 40,
                      colorFilter: ColorFilter.mode(
                        hatColor,
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
                  top: MediaQuery.of(context).size.height * 0.42 + 18,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: _lineAnimation.value,
                      child: SvgPicture.asset(
                        "assets/images/line.svg",
                        width: 185,
                        colorFilter: ColorFilter.mode(
                          lineColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Fade Animation (Optional overlay)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
