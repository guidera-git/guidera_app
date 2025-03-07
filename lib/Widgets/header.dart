// header.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GuideraHeader extends StatelessWidget {
  const GuideraHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the app is in dark mode
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Fixed height for the header; adjust as needed.
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // "Guidera" Text positioned near the center
          Positioned(
            top: 70,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "G",
                    style: TextStyle(
                      fontSize: 40,
                      fontFamily: "ProductSans",
                      fontWeight: FontWeight.bold,
                      color: Colors.blue, // "G" is blue
                    ),
                  ),
                  TextSpan(
                    text: "uidera",
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: "ProductSans",
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Graduation Hat (placed with a slight tilt)
          Positioned(
            // Adjust the top value so the hat starts with a sharp curve effect
            top: 55,
            left: MediaQuery.of(context).size.width * 0.28 + 15,
            child: Transform.rotate(
              angle: -0.5, // Tilt angle in radians (~ -28.6 degrees)
              child: SvgPicture.asset(
                "assets/images/hat.svg",
                height: 30,
                colorFilter: ColorFilter.mode(
                  isDarkMode ? Colors.blue : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          // Lifeline (Line) drawn just below the text; now static without animation
          Positioned(
            top: 89, // Adjusted from the original (50 + 17)
            child: SvgPicture.asset(
              "assets/images/line.svg",
              width: 130,
              colorFilter: ColorFilter.mode(
                isDarkMode ? Colors.white : Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
