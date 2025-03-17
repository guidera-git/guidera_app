import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/Widgets/header.dart';
import 'package:guidera_app/models/university.dart';
import 'package:guidera_app/screens/recommendation_loading_screen.dart';
import 'package:guidera_app/screens/save_uni.dart';
import 'package:guidera_app/screens/university_information.dart';
import 'package:guidera_app/theme/app_colors.dart';

import 'home_screen.dart';

class UniversitySearchScreen extends StatefulWidget {
  const UniversitySearchScreen({super.key});

  @override
  State<UniversitySearchScreen> createState() => _UniversitySearchScreenState();
}

class _UniversitySearchScreenState extends State<UniversitySearchScreen> {
  // Track selected universities by their id.
  final Set<String> _selectedForComparison = {};
  final List<University> _universities = [
    University(
      id: 'ucp',
      name: 'UCP',
      degree: 'BSSE',
      beginning: 'Summer 2025',
      feePerSem: 180000,
      duration: 8,
      location: 'Lahore',
      rating: 4.5,
    ),
    University(
      id: 'fast',
      name: 'FAST NUCES',
      degree: 'BSSE',
      beginning: 'Summer 2025',
      feePerSem: 140000,
      duration: 8,
      location: 'Abbottabad',
      rating: 4.0,
    ),
    University(
      id: 'comsats',
      name: 'COMSATS',
      degree: 'BSSE',
      beginning: 'Summer 2025',
      feePerSem: 110000,
      duration: 8,
      location: 'Islamabad',
      rating: 4.2,
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  FilterOptions _currentFilters = FilterOptions();

  // Initial offset for the draggable compare button.
  Offset _compareButtonOffset = const Offset(20, 500);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.myBlack,
      // Custom AppBar using GuideraHeader with a back button.
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
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    // Fallback: navigate to a default screen (e.g., HomeScreen)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _buildBody(),
          // Draggable Compare Button – appears only when at least 2 universities are selected.
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
                    final selectedUniversities = _universities
                        .where((uni) => _selectedForComparison.contains(uni.id))
                        .toList();
                    _showComparisonPopup(selectedUniversities);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(65),
      child: Container(
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
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  // Fallback: navigate to a default screen (e.g., HomeScreen)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                }
              },
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
                        hintText: 'Software Engineering',
                        hintStyle: TextStyle(
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.normal,
                          color: AppColors.lightBlack,
                          fontSize: 15,
                        ),
                      ),
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
                              onPressed: () {},
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
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomScrollView(
            slivers: [
              // History section.
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 8),
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
                  ],
                ),
              ),
              // University cards list.
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final uni = _universities[index];
                    final isSelected = _selectedForComparison.contains(uni.id);
                    return _buildUniversityCard(
                      context, // Pass the context here
                      university: uni,
                      isSelected: isSelected,
                      onCompareToggle: () {
                        setState(() {
                          if (isSelected) {
                            _selectedForComparison.remove(uni.id);
                          } else {
                            _selectedForComparison.add(uni.id);
                          }
                        });
                      },
                    );
                  },
                  childCount: _universities.length,
                ),
              ),

            ],
          ),
        ),
        // "Recommend Me" button.
        Positioned(
          bottom: 20,
          right: 20,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>RecommendationLoadingScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
    );
  }

  void _showFilters() {
    final List<String> pakistaniCities = [
      'Islamabad',
      'Karachi',
      'Lahore',
      'Faisalabad',
      'Rawalpindi',
      'Multan',
      'Gujranwala',
      'Peshawar',
      'Quetta',
      'Sialkot',
      'Bahawalpur',
      'Sargodha',
      'Sukkur',
      'Larkana',
      'Hyderabad'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          StatefulBuilder(
            builder: (context, setState) =>
                Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.88,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30)),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filters',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          IconButton(
                            icon: SvgPicture.asset(
                              'assets/images/close.svg',
                              color: Colors.black,
                              width: 24,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFilterSection(
                                title: 'Location',
                                child: Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ListView.separated(
                                    padding: const EdgeInsets.all(12),
                                    itemCount: pakistaniCities.length,
                                    separatorBuilder: (_, __) =>
                                        Divider(color: Colors.black.withOpacity(
                                            0.1)),
                                    itemBuilder: (context, index) =>
                                        InkWell(
                                          onTap: () =>
                                              setState(() =>
                                              _currentFilters.location =
                                              pakistaniCities[index]),
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/images/location.svg',
                                                width: 18,
                                                color: _currentFilters
                                                    .location ==
                                                    pakistaniCities[index]
                                                    ? AppColors.lightBlue
                                                    : Colors.black,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                pakistaniCities[index],
                                                style: TextStyle(
                                                  color: _currentFilters
                                                      .location ==
                                                      pakistaniCities[index]
                                                      ? AppColors.lightBlue
                                                      : Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: _currentFilters
                                                      .location ==
                                                      pakistaniCities[index]
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                              _buildFilterSection(
                                title: 'Minimum Rating',
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    5,
                                        (index) =>
                                        GestureDetector(
                                          onTap: () =>
                                              setState(() =>
                                              _currentFilters.minRating =
                                                  (index + 1).toDouble()),
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            child: Icon(
                                              index < _currentFilters.minRating
                                                  ? Icons.star_rounded
                                                  : Icons.star_border_rounded,
                                              color: AppColors.lightBlue,
                                              size: 36,
                                            ),
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                              _buildFilterSection(
                                title: 'Fee Range (PKR)',
                                child: Column(
                                  children: [
                                    RangeSlider(
                                      values: RangeValues(
                                          _currentFilters.minFee,
                                          _currentFilters.maxFee),
                                      min: 0,
                                      max: 300000,
                                      divisions: 6,
                                      activeColor: AppColors.lightBlue,
                                      inactiveColor: Colors.grey[300],
                                      labels: RangeLabels(
                                        '${(_currentFilters.minFee / 1000)
                                            .toStringAsFixed(0)}k',
                                        '${(_currentFilters.maxFee / 1000)
                                            .toStringAsFixed(0)}k',
                                      ),
                                      onChanged: (values) =>
                                          setState(() {
                                            _currentFilters.minFee =
                                                values.start;
                                            _currentFilters.maxFee = values.end;
                                          }),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Text('0 PKR', style: TextStyle(
                                            color: Colors.black)),
                                        Text('300,000 PKR', style: TextStyle(
                                            color: Colors.black)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              _buildFilterSection(
                                title: 'Duration (Semesters)',
                                child: Column(
                                  children: [
                                    Slider(
                                      value: _currentFilters.minDuration
                                          .toDouble(),
                                      min: 1,
                                      max: 10,
                                      divisions: 9,
                                      label: '${_currentFilters
                                          .minDuration} Sem',
                                      activeColor: AppColors.lightBlue,
                                      inactiveColor: Colors.grey[300],
                                      onChanged: (value) =>
                                          setState(
                                                  () =>
                                              _currentFilters.minDuration =
                                                  value.toInt()),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Text('1 Sem', style: TextStyle(
                                              color: Colors.black)),
                                          Text('10 Sem', style: TextStyle(
                                              color: Colors.black)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildFilterSection(
                                title: 'Scholarship',
                                child: SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('Available Scholarship',
                                      style: TextStyle(color: Colors.black)),
                                  value: _currentFilters.hasScholarship,
                                  onChanged: (value) =>
                                      setState(() =>
                                      _currentFilters.hasScholarship = value),
                                  activeColor: AppColors.lightBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () =>
                                    setState(() =>
                                    _currentFilters = FilterOptions()),
                                child: const Text('Reset Filters'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.lightBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Apply Filters'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

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

  // University card with compare toggle.
  Widget _buildUniversityCard(
      BuildContext context, { // Added context parameter
        required University university,
        required bool isSelected,
        required VoidCallback onCompareToggle,
      }) {
    return InkWell(
      onTap: () {
        // Navigate to the dedicated UniversityInformation screen.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UniversityInformation(),
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
              // Top row with university name and icons.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      university.name,
                      style: TextStyle(
                        fontFamily: 'Product Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.myBlack,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SavedUniversitiesScreen()),
                      );
                    },
                    child: Transform.translate(
                      offset: const Offset(20, 0),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          // Save functionality placeholder.
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
              // University details.
              Row(
                children: [
                  _buildLabelValue('Degree', university.degree),
                  const SizedBox(width: 116),
                  _buildLabelValue('Duration', '${university.duration} Semesters'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildLabelValue('Beginning', university.beginning),
                  const SizedBox(width: 60),
                  _buildLabelValue('Tuition Fee Per Sem', '${university.feePerSem} PKR'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(children: _buildStarIconsBlack(university.rating)),
                  const SizedBox(width: 75),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        university.location,
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
                ],
              ),
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
        ),
      ],
    );
  }

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

  Widget _buildComparisonTable(List<University> selectedUniversities) {
    final List<String> attributes = [
      'Degree',
      'Rating',
      'Duration',
      'Beginning',
      'Tuition Fee Per Sem',
      'Location'
    ];

    // Calculate total width needed for all columns
    final double criteriaWidth = 150;
    final double universityWidth = 200;
    final double totalWidth = criteriaWidth + (selectedUniversities.length * universityWidth);

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
                  ...selectedUniversities.map((uni) => _buildHeaderCell(uni.name, universityWidth)),
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
                      ...selectedUniversities.map((uni) => _buildValueCell(_getAttributeValue(uni, attr), universityWidth)),
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

  String _getAttributeValue(University uni, String attribute) {
    switch (attribute) {
      case 'Degree':
        return uni.degree;
      case 'Rating':
        return '${uni.rating}/5.0';
      case 'Duration':
        return '${uni.duration} Sem';
      case 'Beginning':
        return uni.beginning;
      case 'Tuition Fee Per Sem':
        return '${uni.feePerSem} PKR';
      case 'Location':
        return uni.location;
      default:
        return '';
    }
  }

  void _showComparisonPopup(List<University> selectedUniversities) {
    final double tableHeight = 60 + (6 * 50).toDouble(); // 6 attributes

    showDialog(
      context: context,
      builder: (context) =>
          Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: tableHeight + 100, // Add space for header
                maxWidth: MediaQuery
                    .of(context)
                    .size
                    .width,
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
                          'University Comparison',
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
                          child: _buildComparisonTable(selectedUniversities),
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
class FilterOptions {
  String? location;
  List<String> degreeTypes = [];
  double minFee = 0;
  double maxFee = 300000;
  int minDuration = 1;
  double minRating = 0;
  bool hasScholarship = false;
}