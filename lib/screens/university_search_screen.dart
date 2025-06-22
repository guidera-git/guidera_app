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
import 'package:guidera_app/services/saved_programs_service.dart';
import 'package:guidera_app/services/search_history_service.dart';
import 'package:guidera_app/models/filter_options.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'home_screen.dart';

class UniversitySearchScreen extends StatefulWidget {
  const UniversitySearchScreen({super.key, this.initialSearchQuery});

  final String? initialSearchQuery;

  @override
  State<UniversitySearchScreen> createState() => _UniversitySearchScreenState();
}

class _UniversitySearchScreenState extends State<UniversitySearchScreen> {
  // Track selected programs by their id for comparison
  final Set<String> _selectedForComparison = {};
  // Track saved programs by their id
  final Set<String> _savedPrograms = {};
  List<Program> _programs = [];
  List<Program> _filteredPrograms = [];
  List<String> _searchHistory = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Timer? _searchTimer;

  final TextEditingController _searchController = TextEditingController();
  FilterOptions _currentFilters = FilterOptions();
  final ApiService _apiService = ApiService();
  final SavedProgramsService _savedProgramsService = SavedProgramsService();

  // Initial offset for the draggable compare button
  Offset _compareButtonOffset = const Offset(20, 500);

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchQuery != null) {
      _searchController.text = widget.initialSearchQuery!;
    }
    _loadPrograms();
    _loadSearchHistory();
    _loadSavedPrograms();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _searchTimer?.cancel();

    // Set new timer for debounced search
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

  Future<void> _loadSavedPrograms() async {
    try {
      final savedPrograms = await _savedProgramsService.getSavedPrograms();
      setState(() {
        _savedPrograms.clear();
        _savedPrograms.addAll(savedPrograms.map((sp) => sp.programId));
      });
    } catch (e) {
      print('Error loading saved programs: $e');
    }
  }

  Future<void> _toggleSaveProgram(Program program) async {
    try {
      final isSaved = _savedPrograms.contains(program.id);

      if (isSaved) {
        // Find the saved program to get the saved_id
        final savedPrograms = await _savedProgramsService.getSavedPrograms();
        final savedProgram = savedPrograms.firstWhere(
              (sp) => sp.programId == program.id,
          orElse: () => throw Exception('Saved program not found'),
        );

        final success = await _savedProgramsService.unsaveProgram(savedProgram.savedId);
        if (success) {
          setState(() {
            _savedPrograms.remove(program.id);
          });
          Fluttertoast.showToast(
            msg: "Program removed from saved",
            backgroundColor: AppColors.darkBlue,
            textColor: AppColors.myWhite,
          );
        }
      } else {
        final success = await _savedProgramsService.saveProgram(
          program.id,
          program.universityId,
        );
        if (success) {
          setState(() {
            _savedPrograms.add(program.id);
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
    }
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

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

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
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadProgramsWithoutAuth();
              },
              child: const Text('Continue as Guest'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadProgramsWithoutAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _apiService.getAllPrograms();

      if (response.statusCode == 200) {
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
        _programs = _createSamplePrograms();
        _filteredPrograms = List.from(_programs);
        _isLoading = false;
      });
    }
  }

  List<Program> _createSamplePrograms() {
    return [
      Program(
        id: '1',
        programTitle: 'Bachelor of Software Engineering',
        programDescription: 'A comprehensive program in software engineering with scholarship opportunities.',
        programDuration: '4 years',
        creditHours: '133',
        fee: [Fee(totalTutionFee: '1,440,000 PKR', perCreditHourFee: '10,000 PKR')],
        calculatedTotalFee: '1,440,000 PKR',
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
        calculatedTotalFee: '1,120,000 PKR',
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
        calculatedTotalFee: '880,000 PKR',
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

    setState(() {
      _filteredPrograms = _programs.where((program) {
        return program.programTitle.toLowerCase().contains(query) ||
            program.displayTitle.toLowerCase().contains(query) ||
            program.universityTitle.toLowerCase().contains(query) ||
            program.location.toLowerCase().contains(query);
      }).toList();
    });
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
            // Back button positioned at top left
            Positioned(
              top: 45,
              left: 16,
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/images/back.svg',
                  width: 30,
                  color: AppColors.textPrimary(context),
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
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
          // Draggable Compare Button
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
      color: AppColors.backgroundColor(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(70),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor(context),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            TextField(
              controller: _searchController,
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(color: AppColors.textPrimary(context)),
              decoration: InputDecoration(
                border: InputBorder.none,
                fillColor: Colors.black,
                contentPadding: const EdgeInsets.only(
                  left: 15,
                  top: 4,
                  bottom: 8,
                  right: 70,
                ),
                hintText: 'Search programs or universities...',
                hintStyle: TextStyle(
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.normal,
                  color: AppColors.textSecondary(context),
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
                      color: AppColors.lightBlue,
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
                            color: AppColors.textSecondary(context),
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
                          color: AppColors.textSecondary(context).withOpacity(0.7),
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
                            color: AppColors.textSecondary(context),
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No programs found matching your criteria.',
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
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
                      final isSaved = _savedPrograms.contains(program.id);
                      return _buildProgramCard(
                        context,
                        program: program,
                        isSelected: isSelected,
                        isSaved: isSaved,
                        onCompareToggle: () {
                          setState(() {
                            if (isSelected) {
                              _selectedForComparison.remove(program.id);
                            } else {
                              _selectedForComparison.add(program.id);
                            }
                          });
                        },
                        onSaveToggle: () => _toggleSaveProgram(program),
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
              elevation: 4,
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
      _loadPrograms();
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
          color: AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderColor(context),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: AppColors.textPrimary(context),
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
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Program card with compare toggle and save toggle (removed start application)
  Widget _buildProgramCard(
      BuildContext context, {
        required Program program,
        required bool isSelected,
        required bool isSaved,
        required VoidCallback onCompareToggle,
        required VoidCallback onSaveToggle,
      }) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
          color: isDarkMode
              ? AppColors.surfaceColor(context)
              : AppColors.lightSurface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode
                ? AppColors.borderColor(context).withOpacity(0.3)
                : AppColors.lightBorder.withOpacity(0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor(context),
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
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
                            color: AppColors.textPrimary(context),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          program.displayTitle, // Use displayTitle for standardized names
                          style: TextStyle(
                            fontFamily: 'Product Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightBlue,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Icons positioned at top right
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: onSaveToggle,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: SvgPicture.asset(
                              isSaved ? 'assets/images/filledsave.svg' : 'assets/images/save.svg',
                              width: 20,
                              height: 20,
                              color: isSaved ? AppColors.lightBlue : AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onCompareToggle,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: SvgPicture.asset(
                              'assets/images/compare.svg',
                              width: 20,
                              height: 20,
                              color: isSelected ? AppColors.lightBlue : AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Program details
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location',
                                style: TextStyle(
                                  fontFamily: 'Product Sans',
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.textSecondary(context),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      program.location,
                                      style: TextStyle(
                                        fontFamily: 'Product Sans',
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary(context),
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
            color: AppColors.textSecondary(context),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
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

    final double criteriaWidth = 150;
    final double programWidth = 200;
    final double totalWidth = criteriaWidth + (selectedPrograms.length * programWidth);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderColor(context),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
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
                  gradient: LinearGradient(
                    colors: [AppColors.lightBlue, AppColors.darkBlue],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
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
                      color: index % 2 == 0
                          ? AppColors.surfaceColor(context)
                          : AppColors.backgroundColor(context),
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.borderColor(context),
                          width: 0.5,
                        ),
                      ),
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
        textAlign: TextAlign.center,
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
          color: AppColors.textPrimary(context),
          fontSize: 14,
          fontWeight: FontWeight.w600,
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
          color: AppColors.textPrimary(context),
          fontSize: 14,
        ),
      ),
    );
  }

  String _getAttributeValue(Program program, String attribute) {
    switch (attribute) {
      case 'Program Title':
        return program.displayTitle;
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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor(context),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor(context),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Program Comparison',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.textPrimary(context)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildComparisonTable(selectedPrograms),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}