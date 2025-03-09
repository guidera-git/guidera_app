import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/models/university.dart';
import 'package:guidera_app/theme/app_colors.dart';

class BestUniversityCard extends StatelessWidget {
  final University university;

  const BestUniversityCard({Key? key, required this.university}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppColors.lightBlue.withOpacity(0.1),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // University details.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Best University',
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    university.name,
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.myBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.lightBlue, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${university.rating}/5.0',
                        style: TextStyle(
                          fontFamily: 'Product Sans',
                          fontSize: 16,
                          color: AppColors.myBlack,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Optional icon for visual enhancement.
            SvgPicture.asset(
              'assets/images/compare.svg',
              width: 40,
              color: AppColors.lightBlue,
            ),
          ],
        ),
      ),
    );
  }
}
