import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/screens/saved_programs_screen.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/widgets/header.dart';
import 'package:guidera_app/widgets/fancy_bottom_nav_bar.dart';
import 'package:guidera_app/widgets/fancy_nav_item.dart';



class UniversityInformation extends StatefulWidget {
  const UniversityInformation({Key? key}) : super(key: key);

  @override
  State<UniversityInformation> createState() => _UniversityInformationState();
}

class _UniversityInformationState extends State<UniversityInformation> {
  int selectedIndex = 0;
  int _navIndex = 0;

  final List<String> chipLabels = [
    'Overview',
    'Course Detail',
    'Requirement',
    'Registration',
    'Fee',
    'About University',
  ];

  static const List<Color> rowColors = [
    Color(0xFF222222),
    Color(0xFF3F3F3F),
  ];

  List<Map<String, String>> _generateOverviewItems() {
    return [
      {
        'Total Fees': '1,300,000 PKR',
        'Deadline Date': 'July 15, 2024',
        'University Link': 'https://www.ucp.edu.pk',
        'Total Duration': '8 Semesters (4 Years)',
        'Accreditation': 'Approved by HEC & PEC',
      },
    ];
  }

  List<Map<String, String>> _generateCourseDetails() {
    return [
      {
        'Programme Name': 'BSSE',
        'Program Link': 'https://ucp.edu.pk/bs-software-engineering',
        'Credit Hours': '133',
        'Duration': '8 semesters',
        'Course Type': 'Undergraduate',
        'Degree Awarded': 'Bachelor of Software Engineering',
      }
    ];
  }

  List<Map<String, String>> _generateRequirements() {
    return [
      {
        'FSC Pre-Medical': '50% Marks',
        'FSC Pre-Engineering': '50% Marks',
        'ICS Physics': '50% Marks',
        'Entry Test': 'Pass Required',
      },
    ];
  }

  List<Map<String, String>> _generateRegistrationInfo() {
    return [
      {
        'Application Submission Deadline': 'July 5 (Fri)',
        'Admission Test (ECAT) Deadline': 'Jul 8 (Mon) - Jul 19 (Fri)',
        'Financial Aid Application Deadline': 'N/A',
        'SAT Deadline': 'Jul 23 (Tue)',
        'Commencement of Classes': 'Aug 19 (Mon)',
        'Last Registration Date': 'July 30 (Tue)',
        'University Website': 'https://admissions.ucp.edu.pk'
      },
    ];
  }

  List<Map<String, String>> _generateFeeDetails() {
    return [
      {
        'per_credit_hour_fee': '10,000 PKR',
        'total_tution_fee': '1,300,000 PKR',
      },
    ];
  }

  List<Map<String, String>> _generateUniversityInfo() {
    return [
      {
        'university_title': 'University of Central Punjab',
        'introduction': 'The National University of Computer & Emerging Sciences has the honor of being the first multi-campus private sector university set up under the Federal Charter granted by Ordinance No.XXIII of 2000, dated July 01, 2000.',
        'main_link': 'https://www.ucp.edu.pk',
        'ranking': 'Top 10 in Punjab',
        'info_email': 'admissions@ucp.edu.pk',
        'Phone': '+92 42 35880007',
        'instagram': 'https://www.instagram.com/fast_nuces/',
        'facebook': 'https://www.facebook.com/FastUniversityOfficial/',
        'twitter': 'https://www.twitter.com/FastNuOfficial',
      },
    ];
  }

  Future<List<Map<String, String>>> _fetchSectionData(int index) async {
    await Future.delayed(const Duration(milliseconds: 500));
    switch (index) {
      case 0:
        return _generateOverviewItems();
      case 1:
        return _generateCourseDetails();
      case 2:
        return _generateRequirements();
      case 3:
        return _generateRegistrationInfo();
      case 4:
        return _generateFeeDetails();
      case 5:
        return _generateUniversityInfo();
      default:
        return [];
    }
  }

  Widget _buildMapConsentCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      color: AppColors.myWhite,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "To activate the map, click on the \"Show map\" button. We would like to point out that data will be transmitted to OpenStreetMap after activation. You can find out more in our privacy policy. You can revoke your consent to the transmission of data at any time.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.lightBlue,
                fontSize: 12,
                fontFamily: "ProductSans",
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Add your map activation logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Map functionality would be implemented here'),
                  ),
                );
              },
              child: const Text(
                "Show Map",
                style: TextStyle(
                  color: AppColors.myWhite,
                  fontFamily: "ProductSans",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(String label, String value, int rowIndex) {
    return Container(
      decoration: BoxDecoration(
        color: rowColors[rowIndex % rowColors.length],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.lightBlue,
                fontSize: 14,
                fontFamily: "ProductSans",
              ),
            ),
          ),
          const SizedBox(width: 25),
          Expanded(
            flex: 6,
            child: (label.contains('Link') || label.contains('Social Media'))
                ? GestureDetector(
              onTap: () {
                /* Handle link opening */
              },
              child: Text(
                value,
                style: TextStyle(
                  color: AppColors.darkBlue,
                  fontSize: 14,
                  fontFamily: "ProductSans",
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
                : Text(
              value,
              style: TextStyle(
                color: AppColors.darkBlue,
                fontSize: 14,
                fontFamily: "ProductSans",
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Chip(
        backgroundColor: isSelected ? AppColors.darkBlue : AppColors.darkGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.myBlack, width: 3),
        ),
        label: Text(
          chipLabels[index],
          style: TextStyle(
            color: isSelected ? AppColors.myWhite : AppColors.myBlack,
            fontSize: 12,
            fontFamily: 'Product Sans',
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.myBlack,
      body: Stack(
        children: [
          Column(
            children: [
              const GuideraHeader(),
              Padding(
                padding: const EdgeInsets.only(
                    top: 3.0, left: 20.0, right: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Bachelors in Software\nEngineering",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: "ProductSans",
                          color: AppColors.myWhite,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        softWrap: true,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SavedProgramsScreen()),
                        );
                      },
                      child: Transform.translate(
                        offset: const Offset(8, 1),
                        child: SvgPicture.asset(
                          "assets/images/save.svg",
                          height: 34,
                          colorFilter: ColorFilter.mode(
                            AppColors.myWhite,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "University of Central Punjab",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: AppColors.myWhite,
                            fontSize: 16,
                            fontFamily: "ProductSans",
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: SvgPicture.asset(
                            "assets/images/dot.svg",
                            height: 15,
                            colorFilter: ColorFilter.mode(
                              AppColors.darkBlue,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        Text(
                          "Lahore",
                          style: TextStyle(
                            color: AppColors.darkGray,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontFamily: "ProductSans",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        SvgPicture.asset(
                          "assets/images/share.svg",
                          height: 22,
                          colorFilter: ColorFilter.mode(
                            AppColors.darkBlue,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 14),
                        SvgPicture.asset(
                          "assets/images/compare.svg",
                          height: 22,
                          colorFilter: ColorFilter.mode(
                            AppColors.darkBlue,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 14),
                        SvgPicture.asset(
                          "assets/images/map.svg",
                          height: 22,
                          colorFilter: ColorFilter.mode(
                            AppColors.darkBlue,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 6.0,
                      children: List.generate(
                        chipLabels.length,
                            (index) => _buildInfoChip(index),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, String>>>(
                  future: _fetchSectionData(selectedIndex),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final data = snapshot.data?.first ?? {};
                    final entries = data.entries.toList();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ListView.builder(
                        itemCount: entries.length + (selectedIndex == 5 ? 1 : 0), // Added
                        itemBuilder: (context, index) {
                          if (index < entries.length) {
                            final entry = entries[index];
                            return _buildTableRow(entry.key, entry.value, index);
                          }
                          if (selectedIndex == 5) { // Show card only for About University
                            return _buildMapConsentCard();
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            top: 90,
            left: 20,
            child: Transform.rotate(
              angle: 0.0,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: SvgPicture.asset(
                  "assets/images/back.svg",
                  height: 28,
                  colorFilter: ColorFilter.mode(
                    AppColors.myWhite,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: GuideraBottomNavBar(
      //   items: [
      //     FancyNavItem(label: "Home", svgPath: "assets/images/home.svg"),
      //     FancyNavItem(label: "Find", svgPath: "assets/images/search.svg"),
      //     FancyNavItem(
      //         label: "Analytics", svgPath: "assets/images/analytics.svg"),
      //     FancyNavItem(
      //         label: "Entry Test", svgPath: "assets/images/entry_test.svg"),
      //     FancyNavItem(label: "Chatbot", svgPath: "assets/images/chatbot.svg"),
      //   ],
      //   initialIndex: _navIndex,
      //   onItemSelected: (index) => setState(() => _navIndex = index),
      // ),
    );
  }
}