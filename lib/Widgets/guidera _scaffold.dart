// lib/widgets/guidera_scaffold.dart

import 'package:flutter/material.dart';
import 'package:guidera_app/widgets/header.dart';
import 'package:guidera_app/widgets/fancy_bottom_nav_bar.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/widgets/fancy_nav_item.dart';

class GuideraScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final Color? backgroundColor;

  const GuideraScaffold({
    Key? key,
    required this.body,
    required this.currentIndex,
    required this.onItemSelected,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? AppColors.myBlack;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const GuideraHeader(),
          Expanded(child: body),
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
        initialIndex: currentIndex,
        onItemSelected: onItemSelected,
      ),
    );
  }
}
