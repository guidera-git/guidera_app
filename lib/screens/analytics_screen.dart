import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/widgets/header.dart';
import 'package:guidera_app/screens/profile_dashboard_screen.dart';

class AnalyticsTrackingScreen extends StatefulWidget {
  const AnalyticsTrackingScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsTrackingScreen> createState() => _AnalyticsTrackingScreenState();
}

class _AnalyticsTrackingScreenState extends State<AnalyticsTrackingScreen> {
  final PageController _pageController = PageController();
  bool _notifyMe = false;
  int _currentPage = 0;

  // Sample data for the analytics cards.
  final List<Map<String, dynamic>> _cardData = [
    {
      'current': 1,
      'total': 3,
      'percentage': 50,
      'progress': 0.5,
      'applicationNo': 721,
    },
    {
      'current': 2,
      'total': 3,
      'percentage': 75,
      'progress': 0.75,
      'applicationNo': 109,
    },
    {
      'current': 3,
      'total': 3,
      'percentage': 90,
      'progress': 0.9,
      'applicationNo': 512,
    },
  ];

  // Sample data for the table.
  final List<Map<String, String>> _applications = [
    {'id': '791001', 'date': '26/11/24', 'status': 'In Progress'},
    {'id': '791002', 'date': '26/11/24', 'status': 'In Progress'},
    {'id': '791003', 'date': '26/11/24', 'status': 'In Progress'},
  ];

  // Filters for the horizontal row.
  final List<String> _filters = ['All', 'Recent', 'Completed', 'Unfinished'];
  String _activeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page ?? 0;
      setState(() {
        _currentPage = page.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Builds a single analytics card.
  Widget _buildAnalyticsCard(BuildContext context, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.88,
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [AppColors.darkGray, AppColors.lightGray],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          // "X of total" at top-left.
          Positioned(
            top: 8,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.darkBlack.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${data['current']} of ${data['total']}",
                style: const TextStyle(
                  color: AppColors.myWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Percentage text.
          Positioned(
            top: 40,
            left: 0,
            child: Text(
              "${data['percentage']}%",
              style: const TextStyle(
                color: AppColors.darkBlue,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Progress bar with curved sides.
          Positioned(
            top: 100,
            left: 0,
            right: 200, // space for SVG image on the right.
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: data['progress'],
                minHeight: 10,
                backgroundColor: AppColors.darkBlack.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.darkBlue),
              ),
            ),
          ),
          // "View" button.
          Positioned(
            top: 130,
            left: 0,
            child: SizedBox(
              width: 80,
              height: 35,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  // TODO: Implement "View" action.
                },
                child: const Text(
                  "View",
                  style: TextStyle(
                    color: AppColors.myWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          // "Application No." text.
          Positioned(
            top: 175,
            left: 0,
            child: Text(
              "Application No. ${data['applicationNo']}",
              style: const TextStyle(
                color: AppColors.darkBlack,
                fontSize: 14,
              ),
            ),
          ),
          // analytics_2.svg image on the right.
          Positioned(
            right: 0,
            top: 30,
            child: SvgPicture.asset(
              'assets/images/student_laptop.svg',
              height: 120,
              width: 120,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the carousel of analytics cards with a dot indicator.
  Widget _buildAnalyticsCarousel(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 230,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _cardData.length,
              itemBuilder: (context, index) {
                return _buildAnalyticsCard(context, _cardData[index]);
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_cardData.length, (index) {
            final isActive = (index == _currentPage);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 12 : 8,
              height: isActive ? 12 : 8,
              decoration: BoxDecoration(
                color: isActive ? AppColors.lightBlue : AppColors.myWhite.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Builds the horizontal filter row.
  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final bool isActive = (filter == _activeFilter);
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = filter),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: isActive ? AppColors.darkBlue : AppColors.lightGray,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 14,
                  color: isActive ? AppColors.myWhite : AppColors.darkBlack,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDataTable() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(AppColors.myWhite.withOpacity(0.5)),
          columnSpacing: 16,
          columns: [
            DataColumn(
              label: Text(
                "Application ID",
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Date",
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Status",
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Edit",
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Delete",
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: _applications.map((application) {
            return DataRow(cells: [
              DataCell(
                Text(
                  application['id'] ?? "",
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ),
              DataCell(
                Text(
                  application['date'] ?? "",
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ),
              DataCell(
                Text(
                  application['status'] ?? "",
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ),
              DataCell(
                IconButton(
                  onPressed: () {
                    // TODO: Implement edit functionality.
                  },
                  icon: SvgPicture.asset(
                    "assets/images/edit.svg",
                    height: 20,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  onPressed: () {
                    // TODO: Implement delete functionality.
                  },
                  icon: SvgPicture.asset(
                    "assets/images/delete.svg",
                    height: 20,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.myBlack,
      // Custom AppBar using GuideraHeader with back and notification icons.
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Stack(
          children: [
            const GuideraHeader(),
            Positioned(
              top: 70,
              left: 10,
              child: IconButton(
                icon: SvgPicture.asset(
                  "assets/images/back.svg",
                  color: AppColors.myWhite,
                  height: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Positioned(
              top: 70,
              right: 10,
              child: IconButton(
                icon: SvgPicture.asset(
                  "assets/images/notification.svg",
                  color: AppColors.myWhite,
                  height: 30,
                ),
                onPressed: () {
                  // TODO: Handle notifications action.
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child:
        Column(
          children: [
            // Welcome row.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: "Hello," and then user name.
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Hello,",
                          style: TextStyle(
                            color: AppColors.lightGray,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          "Saad Mahmood",
                          style: TextStyle(
                            color: AppColors.myWhite,
                            fontSize: 22,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right: "Notify me" + switch.
                  Row(
                    children: [
                      const Text(
                        "Notify me",
                        style: TextStyle(
                          color: AppColors.myWhite,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Switch(
                        value: _notifyMe,
                        onChanged: (val) {
                          setState(() => _notifyMe = val);
                        },
                        activeColor: AppColors.lightBlue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // "Analytics & Tracking" title.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Analytics & Tracking",
                  style: TextStyle(
                    color: AppColors.myWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Analytics card carousel.
            _buildAnalyticsCarousel(context),
            const SizedBox(height: 20),
            // Horizontal filter row.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildFilterTabs(),
            ),
            const SizedBox(height: 12),
            // Data table for applications.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildDataTable(),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
