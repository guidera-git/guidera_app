import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/widgets/header.dart';
import 'package:guidera_app/widgets/fancy_bottom_nav_bar.dart';
import 'package:guidera_app/widgets/fancy_nav_item.dart';
import 'package:guidera_app/models/program.dart';
import 'SavedUniversitiesScreen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UniversityInformation extends StatefulWidget {
  final Program program;

  const UniversityInformation({Key? key, required this.program}) : super(key: key);

  @override
  State<UniversityInformation> createState() => _UniversityInformationState();
}

class _UniversityInformationState extends State<UniversityInformation> {
  int selectedIndex = 0;
  int _navIndex = 0;
  bool isSaved = false; // Track save state

  final List<String> chipLabels = [
    'Overview',
    'Course Detail',
    'Requirements',
    'Registration',
    'Fee',
    'About University',
  ];

  static const List<Color> rowColors = [
    Color(0xFF565756),
    Color(0xFF3F3F3F),
  ];

  void _toggleSave() {
    setState(() {
      isSaved = !isSaved; // Toggle save state
    });

    // Show toast message
    Fluttertoast.showToast(
      msg: isSaved ? "Data is saved" : "Data is unsaved",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.darkBlue,
      textColor: AppColors.myWhite,
      fontSize: 16.0,
    );
  }

  List<Map<String, String>> _generateOverviewItems() {
    return [
      {
        'Total Fees': widget.program.formattedTotalFee,
        'Duration': widget.program.durationInSemesters,
        'Credit Hours': widget.program.creditHours,
        'Location': widget.program.location,
        'University Link': widget.program.mainLink ?? 'N/A',
        'QS Ranking': widget.program.qsRanking ?? 'Not Ranked',
      },
    ];
  }

  List<Map<String, String>> _generateCourseDetails() {
    return [
      {
        'Program Name': widget.program.programTitle,
        'Program Key': widget.program.programKey ?? 'N/A',
        'Credit Hours': widget.program.creditHours,
        'Duration': widget.program.programDuration,
        'Course Outline': widget.program.courseOutline ?? 'N/A',
        'Description': widget.program.programDescription.length > 200
            ? '${widget.program.programDescription.substring(0, 200)}...'
            : widget.program.programDescription,
      }
    ];
  }

  List<Map<String, String>> _generateRequirements() {
    final criteria = widget.program.admissionCriteria ?? [];
    Map<String, String> requirements = {};

    for (int i = 0; i < criteria.length; i++) {
      requirements['Requirement ${i + 1}'] = criteria[i].criteria;
    }

    if (requirements.isEmpty) {
      requirements['Requirements'] = 'No specific requirements listed';
    }

    return [requirements];
  }

  List<Map<String, String>> _generateRegistrationInfo() {
    final dates = widget.program.importantDates?.isNotEmpty == true
        ? widget.program.importantDates!.first
        : null;

    return [
      {
        'Application Deadline': dates?.deadlineApplicationSubmission ?? 'N/A',
        'Admission Test Deadline': dates?.deadlineAdmissionTestECAT ?? 'N/A',
        'Classes Start': dates?.commencementOfClasses ?? 'N/A',
        'SAT Deadline': dates?.deadlineSAT ?? 'N/A',
        'ACT Deadline': dates?.deadlineACT ?? 'N/A',
      },
    ];
  }

  List<Map<String, String>> _generateFeeDetails() {
    return [
      {
        'Total Tuition Fee': widget.program.fee.isNotEmpty
            ? widget.program.fee.first.totalTutionFee
            : 'N/A',
        'Per Credit Hour Fee': widget.program.fee.isNotEmpty
            ? widget.program.fee.first.perCreditHourFee
            : 'N/A',
        'Total Program Cost': widget.program.formattedTotalFee,
      },
    ];
  }

  List<Map<String, String>> _generateUniversityInfo() {
    return [
      {
        'University Name': widget.program.universityTitle,
        'Introduction': widget.program.introduction?.length != null && widget.program.introduction!.length > 300
            ? '${widget.program.introduction!.substring(0, 300)}...'
            : widget.program.introduction ?? 'No introduction available',
        'Main Website': widget.program.mainLink ?? 'N/A',
        'QS Ranking': widget.program.qsRanking ?? 'Not Ranked',
        'Contact Email': widget.program.contactDetails?.infoEmail ?? 'N/A',
        'Phone': widget.program.contactDetails?.call ?? 'N/A',
        'Facebook': widget.program.socialLinks?.facebook ?? 'N/A',
        'Twitter': widget.program.socialLinks?.twitter ?? 'N/A',
        'Instagram': widget.program.socialLinks?.instagram ?? 'N/A',
      },
    ];
  }

  void _shareApp(BuildContext context) {
    String shareText = "Check out this university: ${widget.program.universityTitle}\n"
        "Program: ${widget.program.programTitle}\n"
        "Location: ${widget.program.location}\n"
        "Fee: ${widget.program.formattedTotalFee}";

    if (widget.program.mainLink != null) {
      shareText += "\nLink: ${widget.program.mainLink}";
    }

    Share.share(shareText);
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
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                "assets/images/globe.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "To activate the map, click on the \"Show map\" button. We would like to point out that data will be transmitted to Google Maps after activation. You can find out more in our privacy policy. You can revoke your consent to the transmission of data at any time.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.myBlack,
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
                    _openGoogleMaps();
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
        ],
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
                color: AppColors.myWhite,
                fontSize: 14,
                fontFamily: "ProductSans",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 25),
          Expanded(
            flex: 6,
            child: (label.toLowerCase().contains('link') ||
                label.toLowerCase().contains('website') ||
                label.toLowerCase().contains('outline') ||
                label.toLowerCase().contains('email') ||
                label.toLowerCase().contains('facebook') ||
                label.toLowerCase().contains('twitter') ||
                label.toLowerCase().contains('instagram'))
                ? GestureDetector(
              onTap: () {
                _launchURL(value);
              },
              child: Text(
                value,
                style: TextStyle(
                  color: AppColors.myWhite,
                  fontSize: 14,
                  fontFamily: "ProductSans",
                  decoration: TextDecoration.underline,
                ),
              ),
            )
                : Text(
              value,
              style: TextStyle(
                color: AppColors.myWhite,
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

  /// Launches the given URL in the default browser.
  void _launchURL(String url) async {
    if (url == 'N/A') return;

    String finalUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      finalUrl = 'https://$url';
    }

    if (await canLaunch(finalUrl)) {
      await launch(finalUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch $finalUrl")),
      );
    }
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

  void _showMapBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.myBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Share Location",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.myWhite,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Your location will be shared with the selected app.",
              style: TextStyle(
                color: AppColors.myWhite,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _openGoogleMaps();
                Navigator.pop(context);
              },
              child: Text(
                "Share Location",
                style: TextStyle(
                  color: AppColors.myWhite,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openGoogleMaps() async {
    print("Opening Google Maps...");
    final String query = Uri.encodeComponent("${widget.program.universityTitle} ${widget.program.location}");
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$query";
    print("Google Maps URL: $googleMapsUrl");

    if (await canLaunch(googleMapsUrl)) {
      print("Launching Google Maps...");
      await launch(googleMapsUrl);
    } else {
      print("Could not launch Google Maps.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not open Google Maps. Please check your internet connection or install Google Maps."),
        ),
      );
    }
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
                padding: const EdgeInsets.only(top: 3.0, left: 20.0, right: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.program.programTitle,
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
                      onTap: _toggleSave,
                      child: Transform.translate(
                        offset: const Offset(8, 1),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: SvgPicture.asset(
                            isSaved ? "assets/images/filledsave.svg" : "assets/images/save.svg",
                            key: ValueKey<bool>(isSaved),
                            height: 34,
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.program.universityTitle,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: AppColors.myWhite,
                              fontSize: 16,
                              fontFamily: "ProductSans",
                            ),
                            overflow: TextOverflow.ellipsis,
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
                          widget.program.location,
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
                        // Share Icon
                        GestureDetector(
                          onTap: () {
                            _shareApp(context);
                          },
                          child: SvgPicture.asset(
                            "assets/images/share.svg",
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              AppColors.darkBlue,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Map Icon
                        GestureDetector(
                          onTap: () {
                            _showMapBottomSheet(context);
                          },
                          child: SvgPicture.asset(
                            "assets/images/map.svg",
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              AppColors.darkBlue,
                              BlendMode.srcIn,
                            ),
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
                        itemCount: entries.length + (selectedIndex == 5 ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < entries.length) {
                            final entry = entries[index];
                            return _buildTableRow(entry.key, entry.value, index);
                          }
                          if (selectedIndex == 5) {
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
            top: 85,
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
    );
  }
}