import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/services/api_service.dart';

class FilterOptions {
  String? location;
  String? universityTitle;
  String? programTitle;
  double minTotalFee;
  double maxTotalFee;

  FilterOptions({
    this.location,
    this.universityTitle,
    this.programTitle,
    this.minTotalFee = 0,
    this.maxTotalFee = 5000000,
  });

  void reset() {
    location = null;
    universityTitle = null;
    programTitle = null;
    minTotalFee = 0;
    maxTotalFee = 5000000;
  }

  bool get hasActiveFilters {
    return location != null ||
        universityTitle != null ||
        programTitle != null ||
        minTotalFee > 0 ||
        maxTotalFee < 5000000;
  }

  FilterOptions copyWith({
    String? location,
    String? universityTitle,
    String? programTitle,
    double? minTotalFee,
    double? maxTotalFee,
  }) {
    return FilterOptions(
      location: location ?? this.location,
      universityTitle: universityTitle ?? this.universityTitle,
      programTitle: programTitle ?? this.programTitle,
      minTotalFee: minTotalFee ?? this.minTotalFee,
      maxTotalFee: maxTotalFee ?? this.maxTotalFee,
    );
  }
}

void showFilters(BuildContext context, FilterOptions currentFilters, Function(FilterOptions) onFilterUpdate) {
  FilterOptions _currentFilters = FilterOptions(
    location: currentFilters.location,
    universityTitle: currentFilters.universityTitle,
    programTitle: currentFilters.programTitle,
    minTotalFee: currentFilters.minTotalFee,
    maxTotalFee: currentFilters.maxTotalFee,
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                    // Location Filter
                    buildFilterSection(
                      title: 'Location',
                      child: FutureBuilder<List<String>>(
                        future: ApiService().getLocations(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              height: 50,
                              child: Center(child: CircularProgressIndicator(color: AppColors.lightBlue)),
                            );
                          }

                          final locations = snapshot.data ?? [];
                          return Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: locations.length,
                              separatorBuilder: (_, __) => Divider(color: Colors.black.withOpacity(0.1)),
                              itemBuilder: (context, index) => InkWell(
                                onTap: () => setState(() =>
                                _currentFilters.location = _currentFilters.location == locations[index]
                                    ? null : locations[index]
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/location.svg',
                                      width: 18,
                                      color: _currentFilters.location == locations[index]
                                          ? AppColors.lightBlue
                                          : Colors.black,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      locations[index],
                                      style: TextStyle(
                                        color: _currentFilters.location == locations[index]
                                            ? AppColors.lightBlue
                                            : Colors.black,
                                        fontSize: 16,
                                        fontWeight: _currentFilters.location == locations[index]
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // University Filter
                    buildFilterSection(
                      title: 'University',
                      child: FutureBuilder<List<String>>(
                        future: ApiService().getUniversityNames(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              height: 50,
                              child: Center(child: CircularProgressIndicator(color: AppColors.lightBlue)),
                            );
                          }

                          final universities = snapshot.data ?? [];
                          return Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: universities.length + 1,
                              separatorBuilder: (_, __) => Divider(color: Colors.black.withOpacity(0.1)),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return InkWell(
                                    onTap: () => setState(() => _currentFilters.universityTitle = null),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.school,
                                          size: 18,
                                          color: _currentFilters.universityTitle == null
                                              ? AppColors.lightBlue
                                              : Colors.black,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'All Universities',
                                          style: TextStyle(
                                            color: _currentFilters.universityTitle == null
                                                ? AppColors.lightBlue
                                                : Colors.black,
                                            fontSize: 16,
                                            fontWeight: _currentFilters.universityTitle == null
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                final university = universities[index - 1];
                                return InkWell(
                                  onTap: () => setState(() =>
                                  _currentFilters.universityTitle = _currentFilters.universityTitle == university
                                      ? null : university
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.school,
                                        size: 18,
                                        color: _currentFilters.universityTitle == university
                                            ? AppColors.lightBlue
                                            : Colors.black,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          university,
                                          style: TextStyle(
                                            color: _currentFilters.universityTitle == university
                                                ? AppColors.lightBlue
                                                : Colors.black,
                                            fontSize: 14,
                                            fontWeight: _currentFilters.universityTitle == university
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // Program Filter
                    buildFilterSection(
                      title: 'Program',
                      child: FutureBuilder<List<String>>(
                        future: ApiService().getProgramNames(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              height: 50,
                              child: Center(child: CircularProgressIndicator(color: AppColors.lightBlue)),
                            );
                          }

                          final programs = snapshot.data ?? [];
                          return Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: programs.length + 1,
                              separatorBuilder: (_, __) => Divider(color: Colors.black.withOpacity(0.1)),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return InkWell(
                                    onTap: () => setState(() => _currentFilters.programTitle = null),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.book,
                                          size: 18,
                                          color: _currentFilters.programTitle == null
                                              ? AppColors.lightBlue
                                              : Colors.black,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'All Programs',
                                          style: TextStyle(
                                            color: _currentFilters.programTitle == null
                                                ? AppColors.lightBlue
                                                : Colors.black,
                                            fontSize: 16,
                                            fontWeight: _currentFilters.programTitle == null
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                final program = programs[index - 1];
                                return InkWell(
                                  onTap: () => setState(() =>
                                  _currentFilters.programTitle = _currentFilters.programTitle == program
                                      ? null : program
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.book,
                                        size: 18,
                                        color: _currentFilters.programTitle == program
                                            ? AppColors.lightBlue
                                            : Colors.black,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          program,
                                          style: TextStyle(
                                            color: _currentFilters.programTitle == program
                                                ? AppColors.lightBlue
                                                : Colors.black,
                                            fontSize: 14,
                                            fontWeight: _currentFilters.programTitle == program
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // Total Fee Range Filter
                    buildFilterSection(
                      title: 'Total Fee Range (PKR)',
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Min: ${_currentFilters.minTotalFee.toInt().toString()}'),
                              Text('Max: ${_currentFilters.maxTotalFee.toInt().toString()}'),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.lightBlue,
                              inactiveTrackColor: AppColors.lightBlue.withOpacity(0.3),
                              thumbColor: AppColors.lightBlue,
                              overlayColor: AppColors.lightBlue.withOpacity(0.2),
                              valueIndicatorColor: AppColors.lightBlue,
                            ),
                            child: RangeSlider(
                              values: RangeValues(_currentFilters.minTotalFee, _currentFilters.maxTotalFee),
                              min: 0,
                              max: 5000000,
                              divisions: 100,
                              labels: RangeLabels(
                                _currentFilters.minTotalFee.toInt().toString(),
                                _currentFilters.maxTotalFee.toInt().toString(),
                              ),
                              onChanged: (RangeValues values) {
                                setState(() {
                                  _currentFilters.minTotalFee = values.start;
                                  _currentFilters.maxTotalFee = values.end;
                                });
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
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => setState(() => _currentFilters.reset()),
                      child: const Text('Reset Filters'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        onFilterUpdate(_currentFilters);
                        Navigator.pop(context);
                      },
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

Widget buildFilterSection({required String title, required Widget child}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}