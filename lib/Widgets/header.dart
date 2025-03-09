// header.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/theme/app_colors.dart'; // <-- Import your custom colors

class GuideraHeader extends StatelessWidget {
  const GuideraHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // "G" color: always darkBlue (like the snippet)
    final Color gColor = AppColors.darkBlue;

    // "uidera" text color: myGray if dark mode, myBlack if light mode
    final Color uideraTextColor =
    isDarkMode ? AppColors.myWhite : AppColors.myBlack;

    // Hat color: darkBlue if dark mode, myBlack if light mode
    final Color hatColor =
    isDarkMode ? AppColors.myWhite : AppColors.myBlack;

    // Line color: myGray if dark mode, myBlack if light mode
    final Color lineColor =
    isDarkMode ? AppColors.myWhite : AppColors.myBlack;

    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // "Guidera" Text near the center
          Positioned(
            top: 70,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "G",
                    style: TextStyle(
                      fontSize: 35,
                      fontFamily: "ProductSans",
                      fontWeight: FontWeight.bold,
                      color: gColor, // "G" is darkBlue
                    ),
                  ),
                  TextSpan(
                    text: "uidera.",
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: "ProductSans",
                      fontWeight: FontWeight.bold,
                      color: uideraTextColor, // myGray or myBlack
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Graduation Hat (slight tilt)
          Positioned(
            top: 54,
            left: MediaQuery.of(context).size.width * 0.28 + 18,
            child: Transform.rotate(
              angle: -0.5, // ~ -28.6 degrees
              child: SvgPicture.asset(
                "assets/images/hat.svg",
                height: 30,
                colorFilter: ColorFilter.mode(
                  hatColor, // darkBlue or myBlack
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          // Lifeline (Line) just below the text, static
          Positioned(
            top: 84,
            child: SvgPicture.asset(
              "assets/images/line.svg",
              width: 120,
              colorFilter: ColorFilter.mode(
                lineColor, // myGray or myBlack
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
