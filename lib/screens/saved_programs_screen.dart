import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/widgets/header.dart';
import 'package:guidera_app/models/saved_program.dart';
import 'package:guidera_app/models/program.dart';
import 'package:guidera_app/services/saved_programs_service.dart';
import 'package:guidera_app/services/application_service.dart';
import 'package:guidera_app/screens/applications_screen.dart';
import 'package:guidera_app/screens/university_information.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class SavedProgramsScreen extends StatefulWidget {
  const SavedProgramsScreen({Key? key}) : super(key: key);

  @override
  State<SavedProgramsScreen> createState() => _SavedProgramsScreenState();
}

class _SavedProgramsScreenState extends State<SavedProgramsScreen> {
  final SavedProgramsService _savedProgramsService = SavedProgramsService();
  final ApplicationService _applicationService = ApplicationService();
  List<SavedProgramModel> _savedPrograms = [];
  List<SavedProgramModel> _filteredPrograms = [];
  Map<String, Map<String, dynamic>> _applicationStatuses = {};
  bool _isLoading = true;
  String? _error;

  // Search and filter controllers
  final TextEditingController _searchController = TextEditingController();
  String _selectedLocationFilter = 'All';
  String _selectedUniversityFilter = 'All';
  double _minFeeFilter = 0;
  double _maxFeeFilter = 1000000;
  bool _showFilters = false;

  // Available filter options
  List<String> _availableLocations = ['All'];
  List<String> _availableUniversities = ['All'];

  @override
  void initState() {
    super.initState();
    _loadSavedPrograms();
    _searchController.addListener(_filterPrograms);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPrograms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final savedPrograms = await _savedProgramsService.getSavedPrograms();
      final applications = await _applicationService.getApplications();

      // Create a map of application statuses for quick lookup
      Map<String, Map<String, dynamic>> statusMap = {};
      for (var app in applications) {
        final key = '${app['program_id']}_${app['university_id']}';
        statusMap[key] = app;
      }

      // Extract unique locations and universities for filters
      Set<String> locations = {'All'};
      Set<String> universities = {'All'};

      for (var program in savedPrograms) {
        if (program.location.isNotEmpty) {
          locations.add(program.location);
        }
        if (program.universityTitle.isNotEmpty) {
          universities.add(program.universityTitle);
        }
      }

      setState(() {
        _savedPrograms = savedPrograms;
        _filteredPrograms = List.from(savedPrograms);
        _applicationStatuses = statusMap;
        _availableLocations = locations.toList()..sort();
        _availableUniversities = universities.toList()..sort();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterPrograms() {
    String searchQuery = _searchController.text.toLowerCase();

    setState(() {
      _filteredPrograms = _savedPrograms.where((program) {
        // Search filter
        bool matchesSearch = searchQuery.isEmpty ||
            program.displayTitle.toLowerCase().contains(searchQuery) ||
            program.universityTitle.toLowerCase().contains(searchQuery) ||
            program.location.toLowerCase().contains(searchQuery);

        // Location filter
        bool matchesLocation = _selectedLocationFilter == 'All' ||
            program.location == _selectedLocationFilter;

        // University filter
        bool matchesUniversity = _selectedUniversityFilter == 'All' ||
            program.universityTitle == _selectedUniversityFilter;

        // Fee filter
        double programFee = _parseFee(program.formattedFee);
        bool matchesFee = programFee >= _minFeeFilter && programFee <= _maxFeeFilter;

        return matchesSearch && matchesLocation && matchesUniversity && matchesFee;
      }).toList();
    });
  }

  double _parseFee(String feeString) {
    // Remove all non-digit characters and parse
    String cleanFee = feeString.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(cleanFee) ?? 0;
  }

  Future<void> _unsaveProgram(SavedProgramModel program) async {
    try {
      final success = await _savedProgramsService.unsaveProgram(program.savedId);
      if (success) {
        setState(() {
          _savedPrograms.removeWhere((p) => p.savedId == program.savedId);
          _filterPrograms(); // Refresh filtered list
        });
        Fluttertoast.showToast(
          msg: "Program removed from saved",
          backgroundColor: AppColors.darkBlue,
          textColor: AppColors.myWhite,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error removing program: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: AppColors.myWhite,
      );
    }
  }

  Future<void> _handleApplicationAction(SavedProgramModel program) async {
    final key = '${program.programId}_${program.universityId}';
    final existingApp = _applicationStatuses[key];

    if (existingApp != null) {
      // Navigate to existing application
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ApplicationScreen(application: existingApp),
        ),
      ).then((_) {
        _loadSavedPrograms(); // Refresh data when returning
      });
    } else {
      // Start new application
      try {
        final success = await _applicationService.startApplication(
          program.programId,
          program.universityId,
        );

        if (success) {
          Fluttertoast.showToast(
            msg: "Application started successfully!",
            backgroundColor: AppColors.darkBlue,
            textColor: AppColors.myWhite,
          );

          // Refresh data and navigate to application screen
          await _loadSavedPrograms();
          final updatedKey = '${program.programId}_${program.universityId}';
          final newApp = _applicationStatuses[updatedKey];

          if (newApp != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ApplicationScreen(application: newApp),
              ),
            ).then((_) {
              _loadSavedPrograms();
            });
          }
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error starting application: ${e.toString()}",
          backgroundColor: Colors.red,
          textColor: AppColors.myWhite,
        );
      }
    }
  }

  void _navigateToUniversityDetails(SavedProgramModel savedProgram) {
    // Convert SavedProgramModel to Program model for UniversityInformation screen
    Program program = Program(
      id: savedProgram.programId,
      universityId: savedProgram.universityId,
      universityTitle: savedProgram.universityTitle,
      programTitle: savedProgram.displayTitle,
      standardizedTitle: savedProgram.displayTitle,
      location: savedProgram.location,
      programDuration: savedProgram.durationInSemesters,
      creditHours: '120', // Default value
      fee: [],
      admissionCriteria: [],
      programDescription: 'View full details on university information page',
      qsRanking: savedProgram.qsRanking,
      calculatedTotalFee: savedProgram.formattedFee,
      importantDates: _convertImportantDates(savedProgram.importantDates),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UniversityInformation(program: program),
      ),
    ).then((_) {
      _loadSavedPrograms(); // Refresh data when returning
    });
  }

  List<ImportantDate>? _convertImportantDates(List<dynamic>? dates) {
    if (dates == null || dates.isEmpty) return null;

    try {
      return dates.map((date) {
        if (date is Map<String, dynamic>) {
          return ImportantDate(
            deadlineApplicationSubmission: date['deadline_application_submission']?.toString(),
            deadlineAdmissionTestECAT: date['deadline_admission_test_ecat']?.toString(),
            deadlineSAT: date['deadline_sat']?.toString(),
            deadlineACT: date['deadline_act']?.toString(),
            commencementOfClasses: date['commencement_of_classes']?.toString(),
          );
        }
        return ImportantDate();
      }).toList();
    } catch (e) {
      print('Error converting important dates: $e');
      return null;
    }
  }

  String _getApplicationButtonText(SavedProgramModel program) {
    final key = '${program.programId}_${program.universityId}';
    final existingApp = _applicationStatuses[key];

    if (existingApp != null) {
      return 'View Application';
    }
    return 'Start Application';
  }

  Color _getApplicationButtonColor(SavedProgramModel program) {
    final key = '${program.programId}_${program.universityId}';
    final existingApp = _applicationStatuses[key];

    if (existingApp != null) {
      final status = existingApp['status']?.toString().toLowerCase() ?? '';
      final progress = double.tryParse(existingApp['progress_percentage']?.toString() ?? '0') ?? 0.0;

      if (status == 'completed' || progress >= 100) {
        return Colors.green;
      } else if (status == 'in_progress' || status == 'submitted' || progress > 0) {
        return Colors.orange;
      }
    }
    return AppColors.lightBlue;
  }

  String _getActualDeadline(SavedProgramModel program) {
    if (program.importantDates != null && program.importantDates!.isNotEmpty) {
      try {
        final dates = program.importantDates!.first as Map<String, dynamic>;

        // Try to get the most relevant deadline
        final deadline = dates['deadline_application_submission'] ??
            dates['deadline_admission_test_ecat'] ??
            dates['deadline_sat'] ??
            dates['deadline_act'];

        if (deadline != null && deadline.toString().isNotEmpty && deadline.toString() != 'null') {
          try {
            // Try to parse and format the date
            final parsedDate = DateTime.parse(deadline.toString());
            return DateFormat('dd/MM/yyyy').format(parsedDate);
          } catch (e) {
            // If parsing fails, return the raw deadline string if it's meaningful
            String deadlineStr = deadline.toString();
            if (deadlineStr.isNotEmpty && deadlineStr != 'null') {
              return deadlineStr;
            }
          }
        }
      } catch (e) {
        print('Error parsing deadline: $e');
      }
    }
    return 'Check university website';
  }

  void _launchURL(String url) async {
    if (url.isEmpty || url == 'N/A') return;

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

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search programs or universities...',
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary(context)),
          suffixIcon: IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list : Icons.tune,
              color: AppColors.textSecondary(context),
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintStyle: TextStyle(
            color: AppColors.textSecondary(context),
            fontFamily: 'Product Sans',
          ),
        ),
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontFamily: 'Product Sans',
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    if (!_showFilters) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
                fontFamily: 'Product Sans',
              ),
            ),
            const SizedBox(height: 16),

            // Location and University Filters in a Row that wraps on small screens
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 400) {
                  // Stack vertically on small screens
                  return Column(
                    children: [
                      _buildLocationFilter(),
                      const SizedBox(height: 16),
                      _buildUniversityFilter(),
                    ],
                  );
                } else {
                  // Side by side on larger screens
                  return Row(
                    children: [
                      Expanded(child: _buildLocationFilter()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildUniversityFilter()),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            // Fee Range Filter
            Text(
              'Fee Range (PKR)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
                fontFamily: 'Product Sans',
              ),
            ),
            const SizedBox(height: 8),
            RangeSlider(
              values: RangeValues(_minFeeFilter, _maxFeeFilter),
              min: 0,
              max: 1000000,
              divisions: 20,
              labels: RangeLabels(
                '${_minFeeFilter.round()}',
                '${_maxFeeFilter.round()}',
              ),
              onChanged: (values) {
                setState(() {
                  _minFeeFilter = values.start;
                  _maxFeeFilter = values.end;
                });
                _filterPrograms();
              },
            ),

            const SizedBox(height: 16),

            // Clear Filters Button
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _selectedLocationFilter = 'All';
                    _selectedUniversityFilter = 'All';
                    _minFeeFilter = 0;
                    _maxFeeFilter = 1000000;
                    _searchController.clear();
                  });
                  _filterPrograms();
                },
                child: Text(
                  'Clear All Filters',
                  style: TextStyle(
                    color: AppColors.lightBlue,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Product Sans',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
            fontFamily: 'Product Sans',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            value: _selectedLocationFilter,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            items: _availableLocations.map((location) {
              return DropdownMenuItem(
                value: location,
                child: Text(
                  location,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontFamily: 'Product Sans',
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLocationFilter = value ?? 'All';
              });
              _filterPrograms();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUniversityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'University',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
            fontFamily: 'Product Sans',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            value: _selectedUniversityFilter,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            items: _availableUniversities.map((university) {
              return DropdownMenuItem(
                value: university,
                child: Text(
                  university,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontFamily: 'Product Sans',
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedUniversityFilter = value ?? 'All';
              });
              _filterPrograms();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgramCard(SavedProgramModel program) {
    final key = '${program.programId}_${program.universityId}';
    final hasApplication = _applicationStatuses.containsKey(key);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surfaceColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with university name and unsave button
            Row(
              children: [
                Expanded(
                  child: Text(
                    program.universityTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                      fontFamily: 'Product Sans',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _unsaveProgram(program),
                  icon: SvgPicture.asset(
                    "assets/images/filledsave.svg",
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      AppColors.lightBlue,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),

            // Program title
            Text(
              program.displayTitle,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary(context),
                fontFamily: 'Product Sans',
              ),
            ),

            const SizedBox(height: 12),

            // Location and QS Ranking
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.textSecondary(context),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    program.location,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary(context),
                      fontFamily: 'Product Sans',
                    ),
                  ),
                ),
                if (program.qsRanking != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'QS #${program.qsRanking}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightBlue,
                        fontFamily: 'Product Sans',
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Fee and Duration
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Fee',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                          fontFamily: 'Product Sans',
                        ),
                      ),
                      Text(
                        program.formattedFee,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                          fontFamily: 'Product Sans',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duration',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                          fontFamily: 'Product Sans',
                        ),
                      ),
                      Text(
                        program.durationInSemesters,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                          fontFamily: 'Product Sans',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Deadline
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppColors.textSecondary(context),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Deadline: ${_getActualDeadline(program)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary(context),
                      fontFamily: 'Product Sans',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleApplicationAction(program),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getApplicationButtonColor(program),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      _getApplicationButtonText(program),
                      style: const TextStyle(
                        color: AppColors.myWhite,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Product Sans',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => _navigateToUniversityDetails(program),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.lightBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      color: AppColors.lightBlue,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Product Sans',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
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
                  color: AppColors.textPrimary(context),
                  height: 30,
                ),
                  onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'My Saved Programs',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                    fontFamily: 'Product Sans',
                  ),
                ),
                const Spacer(),
                if (!_isLoading)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_filteredPrograms.length} Programs',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightBlue,
                        fontFamily: 'Product Sans',
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Search Bar
          _buildSearchBar(),

          // Filter Section
          _buildFilterSection(),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading saved programs',
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSavedPrograms,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
                : _filteredPrograms.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _savedPrograms.isEmpty ? 'No Saved Programs' : 'No Programs Match Your Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                      fontFamily: 'Product Sans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _savedPrograms.isEmpty
                        ? 'Programs you save will appear here'
                        : 'Try adjusting your search or filters',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary(context),
                      fontFamily: 'Product Sans',
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadSavedPrograms,
              child: ListView.builder(
                itemCount: _filteredPrograms.length,
                itemBuilder: (context, index) {
                  return _buildProgramCard(_filteredPrograms[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}