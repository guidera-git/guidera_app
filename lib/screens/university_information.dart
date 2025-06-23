import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/widgets/header.dart';
import 'package:guidera_app/models/program.dart';
import 'package:guidera_app/services/saved_programs_service.dart';
import 'package:guidera_app/services/application_service.dart';
import 'package:guidera_app/screens/applications_screen.dart';
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
  bool isSaved = false;
  bool _isCheckingSaved = true;
  bool _isSaving = false;
  final Map<String, bool> _expandedTexts = {};
  final SavedProgramsService _savedProgramsService = SavedProgramsService();
  final ApplicationService _applicationService = ApplicationService();

  // Application status tracking
  Map<String, dynamic>? _applicationStatus;
  bool _isCheckingApplication = true;
  bool _isStartingApplication = false;

  final List<String> chipLabels = [
    'Overview',
    'Course Detail',
    'Requirements',
    'Registration',
    'Fee',
    'About University',
  ];

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
    _checkApplicationStatus();
  }

  Future<void> _checkIfSaved() async {
    try {
      final saved = await _savedProgramsService.isProgramSaved(widget.program.id);
      setState(() {
        isSaved = saved;
        _isCheckingSaved = false;
      });
    } catch (e) {
      setState(() {
        _isCheckingSaved = false;
      });
    }
  }

  Future<void> _checkApplicationStatus() async {
    try {
      final response = await _applicationService.getApiService().checkApplicationStatus(
        programId: widget.program.id,
        universityId: widget.program.universityId,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _applicationStatus = data['exists'] ? data['application'] : null;
          _isCheckingApplication = false;
        });
      } else {
        setState(() {
          _applicationStatus = null;
          _isCheckingApplication = false;
        });
      }
    } catch (e) {
      print('Error checking application status: $e');
      setState(() {
        _isCheckingApplication = false;
      });
    }
  }

  Future<void> _startApplication() async {
    if (_isStartingApplication) return;

    setState(() => _isStartingApplication = true);

    try {
      // First check if deadline has passed
      final deadlineResponse = await _applicationService.getApiService().get(
        '/programs/${widget.program.id}/${widget.program.universityId}/deadline-check',
        auth: true,
      );

      if (deadlineResponse.statusCode == 200) {
        final deadlineData = jsonDecode(deadlineResponse.body);

        if (!deadlineData['canApply']) {
          // Show deadline exceeded dialog
          _showDeadlineExceededDialog(deadlineData['reason']);
          setState(() => _isStartingApplication = false);
          return;
        }
      }

      // Proceed with starting application
      final success = await _applicationService.startApplication(
        widget.program.id,
        widget.program.universityId,
      );

      if (success) {
        Fluttertoast.showToast(
          msg: "Application started successfully! 🎉",
          backgroundColor: AppColors.darkBlue,
          textColor: AppColors.myWhite,
        );

        // Refresh application status
        await _checkApplicationStatus();
      }
    } catch (e) {
      if (e.toString().contains('deadline')) {
        _showDeadlineExceededDialog(e.toString().replaceAll('Exception: ', ''));
      } else {
        Fluttertoast.showToast(
          msg: e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red,
          textColor: AppColors.myWhite,
        );
      }
    } finally {
      setState(() => _isStartingApplication = false);
    }
  }

  void _showDeadlineExceededDialog(String reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Application Deadline Exceeded',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reason,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Unfortunately, you cannot start an application for this program as the deadline has already passed.',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('I Understand'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToApplication() {
    if (_applicationStatus != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ApplicationScreen(
            application: {
              'id': _applicationStatus!['id'],
              'program_title': widget.program.displayTitle,
              'university_title': widget.program.universityTitle,
              'status': _applicationStatus!['status'],
              'progress_percentage': _applicationStatus!['progress_percentage'],
              'phases': _applicationStatus!['phases'],
            },
          ),
        ),
      ).then((_) {
        // Refresh application status when returning
        _checkApplicationStatus();
      });
    }
  }

  Widget _buildApplicationStatusButton() {
    if (_isCheckingApplication) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.lightBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.lightBlue,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Checking...',
              style: TextStyle(
                color: AppColors.lightBlue,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_applicationStatus == null) {
      // No application exists - show start button
      return GestureDetector(
        onTap: _isStartingApplication ? null : _startApplication,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _isStartingApplication
                ? Colors.grey.withOpacity(0.3)
                : AppColors.darkBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isStartingApplication) ...[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Starting...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else ...[
                const SizedBox(width: 6),
                const Text(
                  'Apply',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    } else {
      // Application exists - show status
      final progress = double.tryParse(_applicationStatus!['progress_percentage']?.toString() ?? '0') ?? 0.0;
      final status = _applicationStatus!['status']?.toString() ?? 'started';

      Color statusColor;
      String statusText;
      IconData statusIcon;

      if (progress >= 100.0 || status == 'completed') {
        statusColor = Colors.green;
        statusText = 'Completed';
        statusIcon = Icons.check_circle;
      } else if (progress > 0 || status == 'in_progress') {
        statusColor = Colors.orange;
        statusText = 'In Progress';
        statusIcon = Icons.pending;
      } else {
        statusColor = AppColors.lightBlue;
        statusText = 'Started';
        statusIcon = Icons.play_circle_outline;
      }

      return GestureDetector(
        onTap: _navigateToApplication,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: statusColor,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (progress > 0 && progress < 100) ...[
                const SizedBox(width: 8),
                Text(
                  '${progress.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
  }

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

  void _toggleSave() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (isSaved) {
        final savedPrograms = await _savedProgramsService.getSavedPrograms();
        final savedProgram = savedPrograms.firstWhere(
              (sp) => sp.programId == widget.program.id,
          orElse: () => throw Exception('Saved program not found'),
        );

        final success = await _savedProgramsService.unsaveProgram(savedProgram.savedId);
        if (success) {
          setState(() {
            isSaved = false;
          });
          Fluttertoast.showToast(
            msg: "Program removed from saved",
            backgroundColor: AppColors.darkBlue,
            textColor: AppColors.myWhite,
          );
        }
      } else {
        final success = await _savedProgramsService.saveProgram(
          widget.program.id,
          widget.program.universityId,
        );
        if (success) {
          setState(() {
            isSaved = true;
          });
          Fluttertoast.showToast(
            msg: "Program saved successfully",
            backgroundColor: AppColors.darkBlue,
            textColor: AppColors.myWhite,
          );
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        textColor: AppColors.myWhite,
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
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

    if (widget.program.merit != null) {
      requirements['Merit Information'] = widget.program.merit.toString();
    }

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
              .replaceAll(RegExp(r'[{}"[]]'), '')
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
        "Program: ${widget.program.displayTitle}\n"
        "Location: ${widget.program.location}\n"
        "Fee: ${widget.program.formattedTotalFee}";

    if (widget.program.additionalLocations != null && widget.program.additionalLocations!.isNotEmpty) {
      shareText += "\nAdditional Locations: ${widget.program.additionalLocations!.join(', ')}";
    }

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
    return Card(
      margin: const EdgeInsets.all(16),
      color: AppColors.surfaceColor(context),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                "assets/images/globe.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "To activate the map, click on the Show map button. We would like to point out that data will be transmitted to Google Maps after activation. You can find out more in our privacy policy. You can revoke your consent to the transmission of data at any time",
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _isSaving ? null : _toggleSave,
                          child: _isSaving
                              ? SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.lightBlue,
                            ),
                          )
                              : AnimatedSwitcher(
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
                          const SizedBox(width: 14),
                          // Application Status Button
                          _buildApplicationStatusButton(),
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