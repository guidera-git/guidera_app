import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/Widgets/drawer.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:guidera_app/screens/application_screen.dart';

import '../Widgets/header.dart';
import '../Widgets/sort_providers.dart';
import '../Widgets/sort_utilities.dart';

/// Model for a saved program.
class SavedProgram {
  final String id;
  final String university;
  final String program;
  final String startDate;
  final int fee;
  final String status; // Status info.
  bool saved;

  SavedProgram({
    required this.id,
    required this.university,
    required this.program,
    required this.startDate,
    required this.fee,
    required this.status,
    this.saved = true,
  });
}

/// Updated screen as a ConsumerStatefulWidget to integrate Riverpod.
class SavedProgramsScreen extends ConsumerStatefulWidget {
  const SavedProgramsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SavedProgramsScreen> createState() => _SavedProgramsScreenState();
}

class _SavedProgramsScreenState extends ConsumerState<SavedProgramsScreen> {
  // Initial dummy saved programs list.
  List<SavedProgram> _savedPrograms = [
    SavedProgram(
      id: 'prog1',
      university: 'UCP',
      program: 'BS Computer Science',
      startDate: 'Fall 2025',
      fee: 200000,
      status: 'Admission is open', // Green status.
    ),
    SavedProgram(
      id: 'prog2',
      university: 'FAST NUCES',
      program: 'BS Electrical Engineering',
      startDate: 'Spring 2025',
      fee: 180000,
      status: 'Opening in 2 days', // Blue status.
    ),
    SavedProgram(
      id: 'prog3',
      university: 'COMSATS',
      program: 'BS Software Engineering',
      startDate: 'Fall 2025',
      fee: 150000,
      status: 'Closing in 3 hours', // Red status.
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Returns the filtered and sorted list.
  List<SavedProgram> get _filteredPrograms {
    final filtered = _savedPrograms.where((program) =>
    program.university.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        program.program.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    // Use the current sort order from the sortProvider.
    return sortPrograms(filtered, ref.watch(sortProvider));
  }

  // Refresh logic simulating a data fetch.
  Future<void> _refreshPrograms() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Optionally re-fetch or update your list.
    });
  }

  // Remove the saved program from the list.
  void _removeProgram(String id) {
    setState(() {
      _savedPrograms.removeWhere((prog) => prog.id == id);
    });
  }

  // Navigate to the dedicated ApplicationScreen.
  void _startApplication(SavedProgram program) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdmissionJourneyScreen(),
      ),
    );
  }

  // Toggle saved state for a program.
  // If already saved (filled icon), remove the card and show toast.
  void _toggleSave(SavedProgram program) {
    if (program.saved) {
      _removeProgram(program.id);
      Fluttertoast.showToast(
        msg: "Card removed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.darkBlue,
        textColor: AppColors.myWhite,
        fontSize: 16.0,
      );
    } else {
      setState(() {
        program.saved = true;
      });
      Fluttertoast.showToast(
        msg: "Program saved",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.darkBlue,
        textColor: AppColors.myWhite,
        fontSize: 16.0,
      );
    }
  }

  // Map program status to a color.
  Color _getStatusColor(String status) {
    if (status == 'Admission is open') return Colors.greenAccent;
    if (status == 'Opening in 2 days') return Colors.blueAccent;
    if (status == 'Closing in 3 hours') return Colors.redAccent;
    return AppColors.myWhite;
  }

  // Show sorting options via a bottom sheet.
  void _showSortOptions() {
    final currentSort = ref.read(sortProvider.notifier).state;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.myWhite,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: SortBy.values.map((sort) => ListTile(
              leading: Icon(
                sort.icon,
                color: currentSort == sort ? AppColors.darkBlue : AppColors.myGray,
              ),
              title: Text(
                sort.label,
                style: TextStyle(
                  color: currentSort == sort ? AppColors.darkBlue : AppColors.myBlack,
                  fontWeight: currentSort == sort ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: currentSort == sort
                  ? Icon(Icons.check, color: AppColors.darkBlue)
                  : null,
              onTap: () {
                ref.read(sortProvider.notifier).changeSorting(sort);
                Navigator.pop(context);
              },
            )).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.myBlack,
      drawer: const GuideraDrawer(selectedIndex: 6),
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
                  "assets/images/sort.svg",
                  color: AppColors.myWhite,
                  height: 30,
                ),
                onPressed: () {
                  _showSortOptions();
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar.
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.myWhite),
              decoration: InputDecoration(
                hintText: 'Search programs...',
                hintStyle: TextStyle(color: AppColors.myGray.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search, color: AppColors.myGray),
                filled: true,
                fillColor: AppColors.lightBlack.withOpacity(0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // List of saved programs with pull-to-refresh.
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshPrograms,
              child: _filteredPrograms.isEmpty
                  ? const Center(
                child: Text(
                  "No saved programs found.",
                  style: TextStyle(color: AppColors.myWhite, fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: _filteredPrograms.length,
                itemBuilder: (context, index) {
                  final program = _filteredPrograms[index];
                  return Dismissible(
                    key: Key(program.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.redAccent,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      _removeProgram(program.id);
                      Fluttertoast.showToast(
                        msg: "Card removed",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: AppColors.darkBlue,
                        textColor: AppColors.myWhite,
                        fontSize: 16.0,
                      );
                    },
                    child: SavedProgramCard(
                      program: program,
                      getStatusColor: _getStatusColor,
                      onApply: _startApplication,
                      onToggleSave: _toggleSave,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A separate widget for the SavedProgram card for clarity and reusability.
class SavedProgramCard extends StatelessWidget {
  final SavedProgram program;
  final Color Function(String) getStatusColor;
  final void Function(SavedProgram) onApply;
  final void Function(SavedProgram) onToggleSave;

  const SavedProgramCard({
    Key? key,
    required this.program,
    required this.getStatusColor,
    required this.onApply,
    required this.onToggleSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.lightBlack,
              AppColors.lightBlack.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onApply(program),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with university title and save icon.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        program.university,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.myWhite,
                        ),
                      ),
                      // Save/Unsave icon with animated switcher.
                      GestureDetector(
                        onTap: () => onToggleSave(program),
                        child: Transform.translate(
                          offset: const Offset(8, 1),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return ScaleTransition(scale: animation, child: child);
                            },
                            child: SvgPicture.asset(
                              program.saved
                                  ? "assets/images/filledsaved.svg"
                                  : "assets/images/save.svg",
                              key: ValueKey<bool>(program.saved),
                              height: 30,
                              colorFilter: const ColorFilter.mode(
                                AppColors.myWhite,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    program.program,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Start: ${program.startDate}",
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Fee: PKR ${program.fee}",
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  // Status message.
                  Text(
                    program.status,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: getStatusColor(program.status),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () => onApply(program),
                      child: const Text(
                        "Start Application",
                        style: TextStyle(fontSize: 14, color: AppColors.myWhite),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
