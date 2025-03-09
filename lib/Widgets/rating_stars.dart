import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double starSize;
  final Color activeColor;
  final Color inactiveColor;

  const RatingStars({
    super.key,
    required this.rating,
    this.starSize = 24.0,
    this.activeColor = AppColors.myGray,
    this.inactiveColor = AppColors.lightGray,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final double starValue = index + 1.0;
        return _buildStar(starValue);
      }),
    );
  }

  Widget _buildStar(double starNumber) {
    return IconButton(
      iconSize: starSize,
      padding: EdgeInsets.zero,
      icon: _getStarIcon(starNumber),
      onPressed: null, // Remove if you want interactive ratings later
    );
  }

  Widget _getStarIcon(double starNumber) {
    if (rating >= starNumber) {
      return SvgPicture.asset(
        'assets/svgs/star_filled.svg',
        color: activeColor,
      );
    } else if (rating > starNumber - 1 && rating < starNumber) {
      return SvgPicture.asset(
        'assets/svgs/star_half.svg',
        color: activeColor,
      );
    } else {
      return SvgPicture.asset(
        'assets/svgs/star_outline.svg',
        color: inactiveColor,
      );
    }
  }
}