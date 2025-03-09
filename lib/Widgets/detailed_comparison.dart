import 'package:flutter/material.dart';
import 'package:guidera_app/models/university.dart';
import 'package:guidera_app/theme/app_colors.dart';

class DetailedComparisonCard extends StatelessWidget {
  final University university;

  const DetailedComparisonCard({Key? key, required this.university}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.myGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // University name.
            Text(
              university.name,
              style: TextStyle(
                fontFamily: 'Product Sans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.myBlack,
              ),
            ),
            const SizedBox(height: 12),
            // Detailed attributes.
            _buildDetailRow('Degree', university.degree),
            const SizedBox(height: 8),
            _buildDetailRow('Rating', '${university.rating}/5.0'),
            const SizedBox(height: 8),
            _buildDetailRow('Duration', '${university.duration} Sem'),
            const SizedBox(height: 8),
            _buildDetailRow('Beginning', university.beginning),
            const SizedBox(height: 8),
            _buildDetailRow('Fee/Sem', '${university.feePerSem} PKR'),
            const SizedBox(height: 8),
            _buildDetailRow('Location', university.location),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            '$label:',
            style: TextStyle(
              fontFamily: 'Product Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.myBlack.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Product Sans',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.myBlack,
            ),
          ),
        ),
      ],
    );
  }
}
