import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/models/university.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/Widgets/best_university_card.dart';
import 'package:guidera_app/Widgets/detailed_comparison.dart';

class ComparisonScreen extends StatelessWidget {
  final List<University> universities;

  const ComparisonScreen({Key? key, required this.universities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the best university based on the highest rating.
    final bestUniversity = universities.reduce(
          (curr, next) => curr.rating >= next.rating ? curr : next,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button and app title.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      'assets/images/back.svg',
                      width: 30,
                      color: AppColors.myBlack,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Guidera App',
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.myBlack,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Best University Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BestUniversityCard(university: bestUniversity),
            ),
            const SizedBox(height: 20),
            // Horizontal scroll for detailed comparison cards.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: universities
                        .map(
                          (uni) => Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: DetailedComparisonCard(university: uni),
                      ),
                    )
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
