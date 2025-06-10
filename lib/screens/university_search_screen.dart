import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/Widgets/header.dart';
import 'package:guidera_app/models/program.dart';
import 'package:guidera_app/screens/recommendation_loading_screen.dart';
import 'package:guidera_app/screens/recommendation_results_screen.dart';
import 'package:guidera_app/screens/saved_programs_screen.dart';
import 'package:guidera_app/screens/university_information.dart';
import 'package:guidera_app/screens/user_form.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/services/api_service.dart';
import 'package:guidera_app/services/search_history_service.dart';
import 'package:guidera_app/models/filter_options.dart';
import 'home_screen.dart';

class UniversitySearchScreen extends StatefulWidget {
  const UniversitySearchScreen({super.key});

  @override
  State<UniversitySearchScreen> createState() => _UniversitySearchScreenState();
}

class _UniversitySearchScreenState extends State<UniversitySearchScreen> {
  // Track selected programs by their id for comparison
  final Set<String> _selectedForComparison = {};
  List<Program> _programs = [];
  List<Program> _filteredPrograms = [];
  List<String> _searchHistory = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Timer? _searchTimer;

  final TextEditingController _searchController = TextEditingController();
  FilterOptions _currentFilters = FilterOptions();
  final ApiService _apiService = ApiService();

  // Initial offset for the draggable compare button
  Offset _compareButtonOffset = const Offset(20, 500);

  @override
  void initState() {
    super.initState();
    _loadPrograms();
    _loadSearchHistory();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchTimer?.cancel(); // FIXED: Cancel timer
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _searchTimer?.cancel();

    // Set new timer for debounced search (don't add to history yet)
    _searchTimer = Timer(Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  Future<void> _loadSearchHistory() async {
    final history = await SearchHistoryService.getSearchHistory();
    setState(() {
      _searchHistory = history;
    });
  }

  Future<void> _addToSearchHistory(String searchTerm) async {
    await SearchHistoryService.addSearchTerm(searchTerm);
    _loadSearchHistory();
  }

  Future<void> _loadPrograms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _apiService.filterPrograms(
        location: _currentFilters.location,
        universityTitle: _currentFilters.universityTitle,
        programTitle: _currentFilters.programTitle,
        minTotalFee: _currentFilters.minTotalFee > 0
            ? _currentFilters.minTotalFee.toInt()
            : null,
        maxTotalFee: _currentFilters.maxTotalFee < 5000000
            ? _currentFilters.maxTotalFee.toInt()
            : null,
      );

      print('API returned: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('decoded.runtimeType = ${decoded.runtimeType}');

        // FIXED: Handle the API response correctly
        if (decoded is List) {
          setState(() {
            _programs = decoded
                .map((json) => Program.fromMap(json as Map<String, dynamic>))
                .toList();
            _filteredPrograms = List.from(_programs);
            _isLoading = false;
          });

          _performSearch(); // Perform initial search/filter
        } else {
          throw FormatException('Expected List but got ${decoded.runtimeType}');
        }
      } else if (response.statusCode == 401) {
        _handleAuthenticationError();
      } else {
        setState(() {
          _errorMessage = 'Failed to load programs: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error in _loadPrograms: $e');
      setState(() {
        _errorMessage = 'Error loading programs: $e';
        _isLoading = false;
      });
    }
  }

  void _handleAuthenticationError() {
    // Show dialog to inform user about authentication issue
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Authentication Required'),
          content: const Text(
            'Your session has expired or you are not logged in. Please login to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login screen - replace with your actual login screen
                // Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadProgramsWithoutAuth(); // Try loading without auth as fallback
              },
              child: const Text('Continue as Guest'),
            ),
          ],
        );
      },
    );
  }

  // Fallback method to load programs without authentication
  Future<void> _loadProgramsWithoutAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Try to get universities first (might not require auth)
      final response = await _apiService.getAllPrograms();

      if (response.statusCode == 200) {
        // If universities endpoint works, create sample programs
        // This is a temporary fallback - you should implement proper guest access
        setState(() {
          _programs = _createSamplePrograms();
          _filteredPrograms = List.from(_programs);
          _isLoading = false;
        });
        _performSearch();
      } else {
        setState(() {
          _errorMessage = 'Unable to load programs. Please check your connection and try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _programs = _createSamplePrograms(); // Use sample data as last resort
        _filteredPrograms = List.from(_programs);
        _isLoading = false;
      });
    }
  }

  // Create sample programs for fallback
  List<Program> _createSamplePrograms() {
    return [
      Program(
        id: '1',
        programTitle: 'Bachelor of Software Engineering',
        programDescription: 'A comprehensive program in software engineering with scholarship opportunities.',
        programDuration: '4 years',
        creditHours: '133',
        fee: [Fee(totalTutionFee: '1,440,000 PKR', perCreditHourFee: '10,000 PKR')],
        universityId: 'ucp',
        universityTitle: 'University of Central Punjab',
        location: 'Lahore',
      ),
      Program(
        id: '2',
        programTitle: 'Bachelor of Computer Science',
        programDescription: 'A rigorous computer science program.',
        programDuration: '4 years',
        creditHours: '130',
        fee: [Fee(totalTutionFee: '1,120,000 PKR', perCreditHourFee: '8,500 PKR')],
        universityId: 'fast',
        universityTitle: 'FAST National University',
        location: 'Islamabad',
      ),
      Program(
        id: '3',
        programTitle: 'Bachelor of Business Administration',
        programDescription: 'A comprehensive business program with financial aid available.',
        programDuration: '4 years',
        creditHours: '124',
        fee: [Fee(totalTutionFee: '880,000 PKR', perCreditHourFee: '7,000 PKR')],
        universityId: 'comsats',
        universityTitle: 'COMSATS University',
        location: 'Karachi',
      ),
    ];
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        _filteredPrograms = List.from(_programs);
      });
      return;
    }

    // FIXED: Don't add to history on every keystroke
    // Only add when user submits or stops typing for meaningful searches

    setState(() {
      _filteredPrograms = _programs.where((program) {
        return program.programTitle.toLowerCase().contains(query) ||
            program.universityTitle.toLowerCase().contains(query) ||
            program.location.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.myBlack,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Stack(
          children: [
            const GuideraHeader(),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildAppBar(),
              Expanded(child: _buildBody()),
            ],
          ),
          // Draggable Compare Button – appears only when at least 2 programs are selected
          if (_selectedForComparison.length >= 2)
            Positioned(
              left: _compareButtonOffset.dx,
              top: _compareButtonOffset.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _compareButtonOffset += details.delta;
                  });
                },
                child: FloatingActionButton.extended(
                  backgroundColor: AppColors.lightBlue,
                  label: Text(
                    "Compare (${_selectedForComparison.length})",
                    style: const TextStyle(fontFamily: 'Product Sans'),
                  ),
                  icon: SvgPicture.asset(
                    'assets/images/compare.svg',
                    width: 25,
                    color: AppColors.myWhite,
                  ),
                  onPressed: () {
                    final selectedPrograms = _filteredPrograms
                        .where((program) => _selectedForComparison.contains(program.id))
                        .toList();
                    _showComparisonPopup(selectedPrograms);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: AppColors.myBlack,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/images/back.svg',
              width: 30,
              color: AppColors.darkGray,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 6),
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
                  TextField(
                    controller: _searchController,
                    textAlign: TextAlign.justify,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Colors.black,
                      contentPadding: const EdgeInsets.only(
                        left: 15,
                        top: 4,
                        bottom: 8,
                      ),
                      hintText: 'Search programs or universities...',
                      hintStyle: TextStyle(
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.normal,
                        color: AppColors.lightBlack,
                        fontSize: 15,
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty && value.trim().length >= 3) {
                        _addToSearchHistory(value.trim());
                        _performSearch();
                      }
                    },
                  ),
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
                              final query = _searchController.text.trim();
                              if (query.isNotEmpty) {
                                _addToSearchHistory(query);
                              }
                              _performSearch();
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
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomScrollView(
            slivers: [
              // History section
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'History',
                          style: TextStyle(
                            color: AppColors.myGray,
                            fontFamily: 'Product Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_searchHistory.isNotEmpty)
                          TextButton(
                            onPressed: () async {
                              await SearchHistoryService.clearHistory();
                              _loadSearchHistory();
                            },
                            child: Text(
                              'Clear',
                              style: TextStyle(
                                color: AppColors.lightBlue,
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_searchHistory.isEmpty)
                      Text(
                        'No search history yet',
                        style: TextStyle(
                          color: AppColors.myGray.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _searchHistory.take(6).map((term) => _buildHistoryChip(term)).toList(),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              // Loading indicator
              if (_isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              // Error message
              if (_errorMessage.isNotEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _loadPrograms,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.lightBlue,
                                ),
                                child: const Text('Retry'),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: _loadProgramsWithoutAuth,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                                child: const Text('Continue as Guest'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Programs list
              if (!_isLoading && _errorMessage.isEmpty)
                _filteredPrograms.isEmpty
                    ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            color: AppColors.myGray,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No programs found matching your criteria.',
                            style: TextStyle(
                              color: AppColors.myGray,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _searchController.clear();
                              _currentFilters.reset();
                              _loadPrograms();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightBlue,
                            ),
                            child: const Text('Clear Filters'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    : SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final program = _filteredPrograms[index];
                      final isSelected = _selectedForComparison.contains(program.id);
                      return _buildProgramCard(
                        context,
                        program: program,
                        isSelected: isSelected,
                        onCompareToggle: () {
                          setState(() {
                            if (isSelected) {
                              _selectedForComparison.remove(program.id);
                            } else {
                              _selectedForComparison.add(program.id);
                            }
                          });
                        },
                      );
                    },
                    childCount: _filteredPrograms.length,
                  ),
                ),
            ],
          ),
        ),
        // "Recommend Me" button
        Positioned(
          bottom: 20,
          right: 20,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileCompletionScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            icon: SvgPicture.asset(
              'assets/images/recommend.svg',
              width: 26,
              color: Colors.white,
            ),
            label: const Text('Recommend Me'),
          ),
        ),
      ],
    );
  }

  void _showFilters() {
    showFilters(context, _currentFilters, (newFilters) {
      setState(() {
        _currentFilters = newFilters;
      });
      _loadPrograms(); // Reload programs with new filters
    });
  }

  Widget _buildHistoryChip(String text) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        _performSearch();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.myGray,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: AppColors.myBlack,
                fontSize: 13,
                fontFamily: 'Product Sans',
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () async {
                await SearchHistoryService.removeFromHistory(text);
                _loadSearchHistory();
              },
              child: Icon(
                Icons.close,
                size: 16,
                color: AppColors.myBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Program card with compare toggle
  Widget _buildProgramCard(
      BuildContext context, {
        required Program program,
        required bool isSelected,
        required VoidCallback onCompareToggle,
      }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UniversityInformation(program: program),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.myGray,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with university name and icons
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          program.universityTitle,
                          style: TextStyle(
                            fontFamily: 'Product Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.myBlack,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          program.programTitle,
                          style: TextStyle(
                            fontFamily: 'Product Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightBlue,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
                      offset: const Offset(20, 0),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          // Save functionality placeholder
                        },
                        icon: SvgPicture.asset(
                          'assets/images/save.svg',
                          width: 25,
                          color: AppColors.myBlack,
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(10, 0),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: onCompareToggle,
                      icon: SvgPicture.asset(
                        'assets/images/compare.svg',
                        width: 25,
                        color: isSelected ? AppColors.lightBlue : AppColors.myBlack,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Program details - Updated layout
              Row(
                children: [
                  Expanded(
                    child: _buildLabelValue('Duration', program.durationInSemesters),
                  ),
                  Expanded(
                    child: _buildLabelValue('Total Fee', program.formattedTotalFee),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildLabelValue('Credit Hours', program.creditHours),
                  ),
                  Expanded(
                    child: _buildLabelValue('Location', program.location),
                  ),
                ],
              ),
              if (program.hasScholarship) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school,
                        color: Colors.green[700],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Scholarship Available',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Product Sans',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
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
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildComparisonTable(List<Program> selectedPrograms) {
    final List<String> attributes = [
      'Program Title',
      'University',
      'Duration',
      'Total Fee',
      'Credit Hours',
      'Location',
    ];

    // Calculate total width needed for all columns
    final double criteriaWidth = 150;
    final double programWidth = 200;
    final double totalWidth = criteriaWidth + (selectedPrograms.length * programWidth);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: totalWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.lightBlue.withOpacity(0.3),
              ),
              child: Row(
                children: [
                  _buildHeaderCell('Criteria', criteriaWidth),
                  ...selectedPrograms.map((program) => _buildHeaderCell(program.universityTitle, programWidth)),
                ],
              ),
            ),
            // Data Rows
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attributes.length,
              itemBuilder: (context, index) {
                final attr = attributes[index];
                return Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.myGray)),
                  ),
                  child: Row(
                    children: [
                      _buildAttributeCell(attr, criteriaWidth),
                      ...selectedPrograms.map((program) => _buildValueCell(_getAttributeValue(program, attr), programWidth)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.myWhite,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildAttributeCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      color: AppColors.lightBlue.withOpacity(0.1),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.myWhite,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildValueCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.myWhite,
          fontSize: 14,
        ),
      ),
    );
  }

  String _getAttributeValue(Program program, String attribute) {
    switch (attribute) {
      case 'Program Title':
        return program.programTitle;
      case 'University':
        return program.universityTitle;
      case 'Duration':
        return program.durationInSemesters;
      case 'Total Fee':
        return program.formattedTotalFee;
      case 'Credit Hours':
        return program.creditHours;
      case 'Location':
        return program.location;
      default:
        return '';
    }
  }

  void _showComparisonPopup(List<Program> selectedPrograms) {
    final double tableHeight = 60 + (6 * 50).toDouble(); // 6 attributes

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: tableHeight + 100, // Add space for header
            maxWidth: MediaQuery.of(context).size.width,
          ),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.myBlack,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Program Comparison',
                      style: TextStyle(
                        color: AppColors.myWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.myWhite),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      width: constraints.maxWidth,
                      child: _buildComparisonTable(selectedPrograms),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}