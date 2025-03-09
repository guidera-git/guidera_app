import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class UniversityCard extends StatelessWidget {
  final String name;
  final String degree;
  final String beginning;
  final int feePerSem;
  final int duration;
  final String location;
  final double rating;

  const UniversityCard({
    Key? key,
    required this.name,
    required this.degree,
    required this.beginning,
    required this.feePerSem,
    required this.duration,
    required this.location,
    required this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.myGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: name + rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.bold,
                      color: AppColors.myBlack,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(children: _buildStarIcons(rating)),
              ],
            ),
            const SizedBox(height: 8),
            // Row 1: degree + duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabelValue('Degree', degree),
                _buildLabelValue('Duration', '$duration Semesters'),
              ],
            ),
            const SizedBox(height: 8),
            // Row 2: beginning + tuition
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabelValue('Beginning', beginning),
                _buildLabelValue('Tuition Fee Per Sem', '${feePerSem} PKR'),
              ],
            ),
            const SizedBox(height: 8),
            // location bottom right
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                location,
                style: TextStyle(
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.normal,
                  color: AppColors.myBlack,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.normal,
            color: AppColors.myBlack.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.bold,
            color: AppColors.myBlack,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStarIcons(double rating) {
    final stars = <Widget>[];
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.yellow, size: 18));
    }
    if (hasHalfStar) {
      stars.add(const Icon(Icons.star_half, color: Colors.yellow, size: 18));
    }
    while (stars.length < 5) {
      stars.add(const Icon(Icons.star_border, color: Colors.yellow, size: 18));
    }

    return stars;
  }
}
