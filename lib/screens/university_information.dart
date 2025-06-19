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
  final Map<String, bool> _expandedTexts = {}; // Track expanded state for long texts

  final List<String> chipLabels = [
    'Overview',
    'Course Detail',
    'Requirements',
    'Registration',
    'Fee',
    'About University',
  ];

  List<Color> _getRowColors(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (isDarkMode) {
      return [
        Color(0xFF565756),
        Color(0xFF3F3F3F),
      ];
    } else {
      return [
        AppColors.lightSurface,
        Color(0xFFF5F5F5),
      ];
    }
  }

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
        'Additional Locations': widget.program.additionalLocations?.join(', ') ?? 'N/A',
        'University Link': widget.program.mainLink ?? 'N/A',
        'QS Ranking': widget.program.qsRanking ?? 'Not Ranked',
      },
    ];
  }

  List<Map<String, String>> _generateCourseDetails() {
    return [
      {
        'Program Name': widget.program.displayTitle,
        'Credit Hours': widget.program.creditHours,
        'Duration': widget.program.programDuration,
        'Course Outline': widget.program.courseOutline ?? 'N/A',
        'Teaching System': widget.program.teachingSystem?.toString() ?? 'N/A',
        'Description': widget.program.programDescription,
      }
    ];
  }

  List<Map<String, String>> _generateRequirements() {
    final criteria = widget.program.admissionCriteria ?? [];
    Map<String, String> requirements = {};

    for (int i = 0; i < criteria.length; i++) {
      requirements['Requirement ${i + 1}'] = criteria[i].criteria;
    }

    // Add merit information if available
    if (widget.program.merit != null) {
      requirements['Merit Information'] = widget.program.merit.toString();
    }

    // Add merit formula if available
    if (widget.program.meritFormula != null && widget.program.meritFormula!.isNotEmpty) {
      requirements['Merit Formula'] = widget.program.meritFormula!.join(', ');
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
        'Teaching System': widget.program.teachingSystem?.toString() ?? 'N/A',
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
        'Calculated Total Fee': widget.program.calculatedTotalFee ?? 'N/A',
        'Total Program Cost': widget.program.formattedTotalFee,
        'Credit Hours': widget.program.creditHours,
        'Estimated Per Credit Cost': widget.program.creditFee > 0
            ? '${widget.program.creditFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} PKR'
            : 'N/A',
      },
    ];
  }

  List<Map<String, String>> _generateUniversityInfo() {
    // Format campuses properly
    String formattedCampuses = 'N/A';
    if (widget.program.campuses != null) {
      try {
        if (widget.program.campuses is List) {
          final campusList = widget.program.campuses as List;
          formattedCampuses = campusList.map((campus) =>
              campus.toString().replaceAll(RegExp(r'[{}"]'), '')).join('\n• ');
          if (formattedCampuses.isNotEmpty) {
            formattedCampuses = '• $formattedCampuses';
          }
        } else {
          formattedCampuses = widget.program.campuses.toString()
              .replaceAll(RegExp(r'[{}"[\]]'), '')
              .replaceAll(',', '\n• ');
          if (formattedCampuses.isNotEmpty) {
            formattedCampuses = '• $formattedCampuses';
          }
        }
      } catch (e) {
        formattedCampuses = 'Campus information available on university website';
      }
    }

    return [
      {
        'University Name': widget.program.universityTitle,
        'Introduction': widget.program.introduction ?? 'No introduction available',
        'Main Website': widget.program.mainLink ?? 'N/A',
        'Primary Location': widget.program.location,
        'Additional Locations': widget.program.additionalLocations?.join(', ') ?? 'N/A',
        'QS Ranking': widget.program.qsRanking ?? 'Not Ranked',
        'Contact Email': widget.program.contactDetails?.infoEmail ?? 'N/A',
        'Phone': widget.program.contactDetails?.call ?? 'N/A',
        'Facebook': widget.program.socialLinks?.facebook ?? 'N/A',
        'Twitter': widget.program.socialLinks?.twitter ?? 'N/A',
        'Instagram': widget.program.socialLinks?.instagram ?? 'N/A',
        'Campus Locations': formattedCampuses,
      },
    ];
  }

  void _shareApp(BuildContext context) {
    String shareText = "Check out this university: ${widget.program.universityTitle}\n"
        "Program: ${widget.program.displayTitle}\n" // Use displayTitle
        "Location: ${widget.program.location}\n"
        "Fee: ${widget.program.formattedTotalFee}";

    // Add additional locations if available
    if (widget.program.additionalLocations != null && widget.program.additionalLocations!.isNotEmpty) {
      shareText += "\nAdditional Locations: ${widget.program.additionalLocations!.join(', ')}";
    }

    // Add QS ranking if available
    if (widget.program.qsRanking != null) {
      shareText += "\nQS Ranking: ${widget.program.qsRanking}";
    }

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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.all(16),
      color: AppColors.surfaceColor(context),
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
                    color: AppColors.textPrimary(context),
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
    final rowColors = _getRowColors(context);
    final isLongText = value.length > 150;
    final isExpanded = _expandedTexts[label] ?? false;

    String displayValue = value;
    if (isLongText && !isExpanded) {
      displayValue = '${value.substring(0, 150)}...';
    }

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
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 14,
                fontFamily: "ProductSans",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 25),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (label.toLowerCase().contains('link') ||
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
                    displayValue,
                    style: TextStyle(
                      color: AppColors.lightBlue,
                      fontSize: 14,
                      fontFamily: "ProductSans",
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
                    : Text(
                  displayValue,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                    fontFamily: "ProductSans",
                    fontWeight: FontWeight.normal,
                  ),
                  softWrap: true,
                ),
                if (isLongText)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _expandedTexts[label] = !isExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        isExpanded ? 'See less' : 'See more',
                        style: TextStyle(
                          color: AppColors.lightBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
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
      child: Container(
        margin: const EdgeInsets.only(right: 6, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.lightBlue
              : AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor(context),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          chipLabels[index],
          style: TextStyle(
            color: isSelected
                ? AppColors.myWhite
                : AppColors.textPrimary(context),
            fontSize: 12,
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showMapBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceColor(context),
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
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Your location will be shared with the selected app.",
              style: TextStyle(
                color: AppColors.textSecondary(context),
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
      backgroundColor: AppColors.backgroundColor(context),
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
                        widget.program.displayTitle,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: "ProductSans",
                          color: AppColors.textPrimary(context),
                          height: 1.2,
                        ),
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _toggleSave,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: SvgPicture.asset(
                          isSaved ? "assets/images/filledsave.svg" : "assets/images/save.svg",
                          key: ValueKey<bool>(isSaved),
                          height: 32,
                          colorFilter: ColorFilter.mode(
                            AppColors.textPrimary(context),
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
                        Expanded(
                          child: Text(
                            widget.program.universityTitle,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: AppColors.textPrimary(context),
                              fontSize: 16,
                              fontFamily: "ProductSans",
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: SvgPicture.asset(
                            "assets/images/dot.svg",
                            height: 15,
                            colorFilter: ColorFilter.mode(
                              AppColors.lightBlue,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        Text(
                          widget.program.location,
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontFamily: "ProductSans",
                          ),
                        ),
                      ],
                    ),
                    // Show additional locations if available
                    if (widget.program.additionalLocations != null && widget.program.additionalLocations!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Also available in: ${widget.program.additionalLocations!.join(', ')}',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          fontFamily: "ProductSans",
                        ),
                      ),
                    ],
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
                              AppColors.lightBlue,
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
                              AppColors.lightBlue,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        // Show QS ranking if available
                        if (widget.program.qsRanking != null) ...[
                          const SizedBox(width: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'QS #${widget.program.qsRanking}',
                              style: TextStyle(
                                color: AppColors.lightBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'ProductSans',
                              ),
                            ),
                          ),
                        ],
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
                      return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.lightBlue,
                          )
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(color: AppColors.textPrimary(context)),
                          )
                      );
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
                    AppColors.textPrimary(context),
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