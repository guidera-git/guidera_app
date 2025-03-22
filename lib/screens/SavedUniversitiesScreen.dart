import 'package:flutter/material.dart';
import 'package:guidera_app/widgets/header.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/widgets/fancy_bottom_nav_bar.dart';
import 'package:guidera_app/widgets/fancy_nav_item.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';

class SavedUniversitiesScreen extends StatefulWidget {
  const SavedUniversitiesScreen({Key? key}) : super(key: key);

  @override
  _SavedUniversitiesScreenState createState() => _SavedUniversitiesScreenState();
}

class _SavedUniversitiesScreenState extends State<SavedUniversitiesScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScreen();
  }

  void _loadScreen() {
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.darkBlack, AppColors.darkBlack],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              const GuideraHeader(),
              Expanded(
                child: Center(
                  child: _isLoading
                      ? CircularProgressIndicator(color: AppColors.lightBlue)
                      : SlideInDown(
                    from: -100,
                    duration: Duration(seconds: 1),
                    child: Text(
                      'Data Saved Successfully!',
                      style: GoogleFonts.gabarito(
                        color: AppColors.myWhite,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 85,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: SvgPicture.asset(
                "assets/images/back.svg",
                height: 28,
                colorFilter: ColorFilter.mode(AppColors.myWhite, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: GuideraBottomNavBar(
        items: [
          FancyNavItem(label: "Home", svgPath: "assets/images/home.svg"),
          FancyNavItem(label: "Find", svgPath: "assets/images/search.svg"),
          FancyNavItem(label: "Analytics", svgPath: "assets/images/analytics.svg"),
          FancyNavItem(label: "Entry Test", svgPath: "assets/images/entry_test.svg"),
          FancyNavItem(label: "Chatbot", svgPath: "assets/images/chatbot.svg"),
        ],
        onItemSelected: (int value) {},
      ),
    );
  }
}
