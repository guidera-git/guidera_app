// lib/screens/result_loader_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:guidera_app/theme/app_colors.dart';

class ResultLoaderScreen extends StatefulWidget {
  final VoidCallback onLoaderComplete;

  const ResultLoaderScreen({Key? key, required this.onLoaderComplete})
      : super(key: key);

  @override
  _ResultLoaderScreenState createState() => _ResultLoaderScreenState();
}

class _ResultLoaderScreenState extends State<ResultLoaderScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate loading delay
    Timer(const Duration(seconds: 2), widget.onLoaderComplete);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightBlue),
            ),
            SizedBox(height: 16),
            Text(
              'Calculating Results...',
              style: TextStyle(
                color: AppColors.myWhite,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
