import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/theme/app_colors.dart';
// import your mock data or real data if needed

class UniversitySearchScreen extends StatefulWidget {
  const UniversitySearchScreen({super.key});

  @override
  State<UniversitySearchScreen> createState() => _UniversitySearchScreenState();
}

class _UniversitySearchScreenState extends State<UniversitySearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Example stub for filters
  void _showFilters() {
    // Show your filter UI
  }

  // Example stub for recommendations
  void _showRecommendations() {
    // Show your recommendations UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.myBlack,

      /// --- SEARCH BAR (AppBar) ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Container(
          color: AppColors.myBlack,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Back Icon
              IconButton(
                icon: SvgPicture.asset(
                  'assets/images/back.svg',
                  width: 30,
                  color: AppColors.darkGray,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 6),

              // Expanded Search Bar
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.darkGray,
                    borderRadius: BorderRadius.circular(70),
                  ),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // TextField
                      TextField(
                        controller: _searchController,
                        textAlign: TextAlign.justify,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(
                            left: 15,
                            top: 4,
                            bottom: 8,
                          ),
                          hintText: 'Software Engineering',
                          hintStyle: TextStyle(
                            fontFamily: 'Product Sans',
                            fontWeight: FontWeight.normal,
                            color: AppColors.myBlack,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      // Filter & Send icons
                      Positioned(
                        right: 0,
                        child: Row(
                          children: [
                            IconButton(
                              icon: SvgPicture.asset(
                                'assets/images/filter.svg',
                                width: 20,
                                color: AppColors.myBlack,
                              ),
                              onPressed: _showFilters,
                            ),
                            Container(
                              height: 35,
                              margin: const EdgeInsets.only(right: 14),
                              decoration: BoxDecoration(
                                color: AppColors.lightBlue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: SvgPicture.asset(
                                  'assets/images/send.svg',
                                  width: 20,
                                  color: AppColors.myWhite,
                                ),
                                onPressed: () {
                                  // Handle send action here
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      /// --- BODY CONTENT WITH HISTORY & CARDS ---
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // History label at top left
                Text(
                  'History',
                  style: TextStyle(
                    color: AppColors.myGray,
                    fontFamily: 'Product Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Wrap displaying history chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildHistoryChip('BBA'),
                    _buildHistoryChip('Electrical Engineering'),
                    _buildHistoryChip('Dental'),
                    _buildHistoryChip('Fashion Design'),
                    _buildHistoryChip('ACCA'),
                    _buildHistoryChip('MBBS'),
                  ],
                ),
                const SizedBox(height: 20),

                // SCROLLABLE LIST OF UNIVERSITY CARDS
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildUniversityCard(
                          name: 'UCP',
                          degree: 'BSSE',
                          beginning: 'Summer 2025',
                          feePerSem: 180000,
                          duration: 8,
                          location: 'Lahore',
                          rating: 4.5,
                        ),
                        buildUniversityCard(
                          name: 'FAST NUCES',
                          degree: 'BSSE',
                          beginning: 'Summer 2025',
                          feePerSem: 140000,
                          duration: 8,
                          location: 'Abbottabad',
                          rating: 4.0,
                        ),
                        buildUniversityCard(
                          name: 'COMSATS',
                          degree: 'BSSE',
                          beginning: 'Summer 2025',
                          feePerSem: 110000,
                          duration: 8,
                          location: 'Islamabad',
                          rating: 4.2,
                        ),
                        // Add more cards if needed
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Positioned "Recommend Me" button (floating over the body)
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _showRecommendations,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
              ),
              icon: const Text('Recommend Me'),
              label: SvgPicture.asset(
                'assets/images/recommend.svg',
                width: 26,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build a history chip
  Widget _buildHistoryChip(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.myGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.myBlack,
          fontSize: 13,
          fontFamily: 'Product Sans',
        ),
      ),
    );
  }


  /// University Card Widget
  Widget buildUniversityCard({
    required String name,
    required double rating,
    required String degree,
    required int duration,
    required String beginning,
    required int feePerSem,
    required String location,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.myGray, // Card background color
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ROW 1: University Name Only
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.myBlack,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Adjust this for more/less space between Row 1 & Row 2
            const SizedBox(height: 8),

            /// ROW 2: Degree and Duration
            Row(
              children: [
                _buildLabelValue('Degree', degree),
                const SizedBox(width: 86),
                _buildLabelValue('Duration', '$duration Semesters'),
              ],
            ),

            // Adjust this for more/less space between Row 2 & Row 3
            const SizedBox(height: 8),

            /// ROW 3: Beginning and Tuition Fee Per Sem
            Row(
              children: [
                _buildLabelValue('Beginning', beginning),
                const SizedBox(width: 30),
                _buildLabelValue('Tuition Fee Per Sem', '$feePerSem PKR'),
              ],
            ),

            // Adjust this for more/less space between Row 3 & Row 4
            const SizedBox(height: 8),

            /// ROW 4: Star Rating, Location, and Save/Compare Icons
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // STAR RATING (on the far left)
                Row(children: _buildStarIconsBlack(rating)),

                // Space between star rating and location
                const SizedBox(width: 45),

                // LOCATION (text + icon)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      location,
                      style: TextStyle(
                        fontFamily: 'Product Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: AppColors.myBlack,
                      ),
                    ),
                    const SizedBox(width: 4),
                    SvgPicture.asset(
                      'assets/images/location.svg',
                      width: 16,
                      color: AppColors.myBlack,
                    ),
                  ],
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    // Handle bookmark / save
                  },
                  icon: SvgPicture.asset(
                    'assets/images/save.svg',
                    width: 25,
                    color: AppColors.myBlack,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    // Handle compare
                  },
                  icon: SvgPicture.asset(
                    'assets/images/compare.svg',
                    width: 25,
                    color: AppColors.myBlack,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method: builds a label-value pair in a column.
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

  /// Helper method: builds star icons in black for the given rating.
  List<Widget> _buildStarIconsBlack(double rating) {
    final stars = <Widget>[];
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.black, size: 18));
    }
    if (hasHalfStar) {
      stars.add(const Icon(Icons.star_half, color: Colors.black, size: 18));
    }
    while (stars.length < 5) {
      stars.add(const Icon(Icons.star_border, color: Colors.black, size: 18));
    }
    return stars;
  }
}