import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/theme/app_colors.dart';
import '../Widgets/header.dart';

/// Custom scroll behavior to remove the scrollbar.
class NoScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({Key? key}) : super(key: key);

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  // Global keys for each section.
  final GlobalKey _personalKey = GlobalKey();
  final GlobalKey _academicKey = GlobalKey();
  final GlobalKey _personalityKey = GlobalKey();

  // Current section index: 0 = Personal, 1 = Academic, 2 = Personality.
  int _currentSectionIndex = 0;

  // Main scroll controller.
  final ScrollController _scrollController = ScrollController();

  // ---------------- PERSONAL SECTION FIELDS ----------------
  final TextEditingController _fullNameController = TextEditingController();
  DateTime? _dob;
  String _gender = "Male"; // Options: Male, Female, Other
  String _location = ""; // New: Location dropdown

  // ---------------- ACADEMIC SECTION FIELDS ----------------
  String _studentType = "Board"; // "Board" or "Cambridge"
  // Board-specific
  final TextEditingController _matricMarksController = TextEditingController();
  final TextEditingController _intermediateMarksController = TextEditingController();
  // Cambridge-specific
  String _oLevelGrade = "A+";
  String _aLevelGrade = "A+";
  // Common academic dropdowns
  String _studyStream = "";
  // Removed: Degree Program and University

  // ---------------- PERSONALITY SECTION FIELDS ----------------
  // Likert scale responses (0: Strongly Disagree ... 4: Strongly Agree)
  int? _p1, _p2, _p3, _p4, _p5, _p6;
  // Multiple-choice questions for personality
  String _personalityQ7 = "";
  String _personalityQ8 = "";

  // Dummy question lists for slider (not displayed to user)
  final List<String> _personalQuestions = List.generate(10, (i) => "Personal Q${i + 1}");
  final List<String> _academicQuestions = List.generate(10, (i) => "Academic Q${i + 1}");
  final List<String> _personalityQuestions = List.generate(10, (i) => "Personality Q${i + 1}");

  // Getter for current section's dummy questions.
  List<String> get _currentQuestions {
    if (_currentSectionIndex == 0) return _personalQuestions;
    if (_currentSectionIndex == 1) return _academicQuestions;
    return _personalityQuestions;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fullNameController.dispose();
    _matricMarksController.dispose();
    _intermediateMarksController.dispose();
    super.dispose();
  }

  // Update current section index based on scroll position.
  void _updateCurrentSection() {
    double minDistance = double.infinity;
    int newIndex = _currentSectionIndex;

    List<GlobalKey> keys = [_personalKey, _academicKey, _personalityKey];
    for (int i = 0; i < keys.length; i++) {
      final context = keys[i].currentContext;
      if (context != null) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        // Distance from top of viewport.
        final double distance = box.localToGlobal(Offset.zero).dy.abs();
        if (distance < minDistance) {
          minDistance = distance;
          newIndex = i;
        }
      }
    }
    if (newIndex != _currentSectionIndex) {
      setState(() {
        _currentSectionIndex = newIndex;
      });
    }
  }

  // Called on scroll.
  void _onScroll() {
    _updateCurrentSection();
  }

  // Helper: Scroll to a section.
  void _scrollToSection(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // Navigation: Forward and Backward.
  void _goForward() {
    if (_currentSectionIndex < 2) {
      _currentSectionIndex++;
      _scrollToSection(_getKeyForSection(_currentSectionIndex));
    }
  }

  void _goBackward() {
    if (_currentSectionIndex > 0) {
      _currentSectionIndex--;
      _scrollToSection(_getKeyForSection(_currentSectionIndex));
    }
  }

  GlobalKey _getKeyForSection(int index) {
    if (index == 0) return _personalKey;
    if (index == 1) return _academicKey;
    return _personalityKey;
  }

  // Dummy progress calculations.
  double get _personalProgress {
    int total = 4; // Full Name, DOB, Gender, Location.
    int answered = 0;
    if (_fullNameController.text.isNotEmpty) answered++;
    if (_dob != null) answered++;
    if (_gender.isNotEmpty) answered++;
    if (_location.isNotEmpty) answered++;
    return answered / total;
  }

  double get _academicProgress {
    int total = 1; // Only Study Stream remains.
    int answered = 0;
    if (_studyStream.isNotEmpty) answered++;
    return answered / total;
  }

  double get _personalityProgress {
    int total = 8; // 6 Likert + 2 multiple-choice.
    int answered = 0;
    if (_p1 != null) answered++;
    if (_p2 != null) answered++;
    if (_p3 != null) answered++;
    if (_p4 != null) answered++;
    if (_p5 != null) answered++;
    if (_p6 != null) answered++;
    if (_personalityQ7.isNotEmpty) answered++;
    if (_personalityQ8.isNotEmpty) answered++;
    return answered / total;
  }

  // ---------------- HELPER WIDGETS ----------------

  // Modern Dropdown Helper.
  Widget buildModernDropdown({
    required String? value,
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
    double verticalPadding = 6, // Reduced vertical padding.
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.myWhite, fontSize: 14, fontWeight: FontWeight.normal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBlue, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBlue, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBlue, width: 2),
        ),
        filled: true,
        fillColor: AppColors.lightBlack,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: verticalPadding),
      ),
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.myWhite),
      dropdownColor: AppColors.lightBlack,
      style: const TextStyle(color: AppColors.myWhite, fontSize: 14),
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item, style: TextStyle(color: AppColors.myWhite)),
      )).toList(),
      onChanged: onChanged,
    );
  }

  // Modern Text Field Helper.
  Widget buildModernTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
    double verticalPadding = 0, // Reduced vertical padding.
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      cursorColor: AppColors.lightBlue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.myWhite,fontSize: 14, fontWeight: FontWeight.normal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBlue, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBlue, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBlue, width: 2),
        ),
        filled: true,
        fillColor: AppColors.lightBlack,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: const TextStyle(color: AppColors.darkGray, fontSize: 14, fontWeight: FontWeight.normal),
      onChanged: onChanged,
    );
  }

  // Modern Progress Column Helper.
  Widget buildProgressColumn(String label, double progress, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(color: isActive ? AppColors.darkBlue : AppColors.myGray, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: 100,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.lightBlack,
            borderRadius: BorderRadius.circular(5),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: isActive ? AppColors.darkBlue : AppColors.myGray,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Likert Question Helper.
  Widget _buildLikertQuestion(String question, int? currentValue, Function(int?) onChanged, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question,
            style: const TextStyle(color: AppColors.myWhite, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(options.length, (index) {
            return ChoiceChip(
              label: Text(options[index], style: const TextStyle(fontSize: 12)),
              selected: currentValue == index,
              selectedColor: AppColors.darkBlue,
              onSelected: (selected) { onChanged(selected ? index : null); },
            );
          }),
        ),
      ],
    );
  }

  // Multiple Choice Question Helper.
  Widget _buildMultipleChoiceQuestion(String question, List<String> options, String currentValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question,
            style: const TextStyle(color: AppColors.myWhite, fontSize: 14, fontWeight: FontWeight.normal)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((option) {
            return ChoiceChip(
              label: Text(option, style: const TextStyle(fontSize: 12)),
              selected: currentValue == option,
              selectedColor: AppColors.darkBlue,
              onSelected: (selected) { onChanged(option); },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Percentage Display Helper.
  Widget _buildPercentageDisplay(String marksText) {
    if (marksText.isEmpty) return Container();
    int? marks = int.tryParse(marksText);
    if (marks == null) return Container();
    double percentage = (marks / 1200) * 100;
    Color displayColor;
    if (percentage >= 80) {
      displayColor = Colors.green;
    } else if (percentage >= 60) {
      displayColor = Colors.yellow;
    } else {
      displayColor = Colors.red;
    }
    return Row(
      children: [
        const SizedBox(width: 8),
        Text("${percentage.toStringAsFixed(1)}%",
            style: TextStyle(color: displayColor, fontSize: 14, fontWeight: FontWeight.normal)),
      ],
    );
  }

  // ---------------- SECTION BUILDERS ----------------

  // Personal Section UI.
  Widget _buildPersonalSection() {
    return Container(
      key: _personalKey,
      child: Padding(
        padding: const EdgeInsets.all(36.0),
        child: Column(
          children: [
            buildModernTextField(
              controller: _fullNameController,
              label: "Full Name",
              verticalPadding: 6,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _dob ?? DateTime(2000, 1, 1),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _dob = picked;
                  });
                }
              },
              child: AbsorbPointer(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    textSelectionTheme: const TextSelectionThemeData(
                      cursorColor: AppColors.lightBlue, // Cursor color
                      selectionColor: AppColors.lightBlue, // Highlight color for selected text
                      selectionHandleColor: AppColors.lightBlue, // Handle color for selection
                    ),
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: _dob == null
                          ? "Date of Birth"
                          : "${_dob!.toLocal().toString().split(' ')[0]}",
                      labelStyle: const TextStyle(color: AppColors.myWhite, fontSize: 14,fontWeight: FontWeight.normal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.darkBlue, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.darkBlue, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.darkBlue, width: 2),
                      ),
                      filled: true,
                      fillColor: AppColors.lightBlack,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    ),
                    style: const TextStyle(color: AppColors.myWhite, fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            buildModernDropdown(
              value: _gender,
              label: "Gender",
              items: ["Male", "Female", "Other"],
              onChanged: (val) { setState(() { _gender = val!; }); },
              verticalPadding: 6,
            ),
            const SizedBox(height: 16),
            // New Location Dropdown.
            buildModernDropdown(
              value: _location.isEmpty ? null : _location,
              label: "Location",
              items: ["Location 1", "Location 2", "Location 3"],
              onChanged: (val) { setState(() { _location = val!; }); },
              verticalPadding: 6,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Academic Section UI.
  Widget _buildAcademicSection() {
    return Container(
      key: _academicKey,
      child: Padding(
        padding: const EdgeInsets.all(36.0),
        child: Column(
          children: [
            buildModernDropdown(
              value: _studentType,
              label: "Student Type",
              items: ["Board", "Cambridge"],
              onChanged: (val) { setState(() { _studentType = val!; }); },
              verticalPadding: 6,
            ),
            const SizedBox(height: 16),
            if (_studentType == "Board") ...[
              buildModernTextField(
                controller: _matricMarksController,
                label: "Matriculation Marks",
                keyboardType: TextInputType.number,
                verticalPadding: 6,
              ),
              const SizedBox(height: 8),
              _buildPercentageDisplay(_matricMarksController.text),
              const SizedBox(height: 16),
              buildModernTextField(
                controller: _intermediateMarksController,
                label: "Intermediate Marks",
                keyboardType: TextInputType.number,
                verticalPadding: 6,
              ),
              const SizedBox(height: 8),
              _buildPercentageDisplay(_intermediateMarksController.text),
            ] else ...[
              buildModernDropdown(
                value: _oLevelGrade,
                label: "O-Level Grade",
                items: ["A+", "A", "B", "C", "D"],
                onChanged: (val) { setState(() { _oLevelGrade = val!; }); },
                verticalPadding: 6,
              ),
              const SizedBox(height: 16),
              buildModernDropdown(
                value: _aLevelGrade,
                label: "A-Level Grade",
                items: ["A+", "A", "B", "C", "D"],
                onChanged: (val) { setState(() { _aLevelGrade = val!; }); },
                verticalPadding: 6,
              ),
            ],
            const SizedBox(height: 16),
            buildModernDropdown(
              value: _studyStream.isEmpty ? null : _studyStream,
              label: "Study Stream",
              items: ["Pre-Medical", "Pre-Engineering", "Computer Science", "Arts", "Commerce", "Other"],
              onChanged: (val) { setState(() { _studyStream = val!; }); },
              verticalPadding: 6,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Personality Section UI.
  Widget _buildPersonalitySection() {
    final List<String> likertOptions = ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"];
    return Container(
      key: _personalityKey,
      child: Padding(
        padding: const EdgeInsets.all(36.0),
        child: Column(
          children: [
            _buildLikertQuestion(
              "I enjoy analyzing data and identifying patterns to solve problems.",
              _p1,
                  (val) { setState(() { _p1 = val; }); },
              likertOptions,
            ),
            const SizedBox(height: 16),
            _buildLikertQuestion(
              "I prefer tasks that require logical thinking and structured solutions.",
              _p2,
                  (val) { setState(() { _p2 = val; }); },
              likertOptions,
            ),
            const SizedBox(height: 16),
            _buildLikertQuestion(
              "I can explain complex topics to others in an engaging way.",
              _p3,
                  (val) { setState(() { _p3 = val; }); },
              likertOptions,
            ),
            const SizedBox(height: 16),
            _buildLikertQuestion(
              "I enjoy brainstorming innovative ideas to solve challenges.",
              _p4,
                  (val) { setState(() { _p4 = val; }); },
              likertOptions,
            ),
            const SizedBox(height: 16),
            _buildLikertQuestion(
              "I pay close attention to details to ensure accuracy in my work.",
              _p5,
                  (val) { setState(() { _p5 = val; }); },
              likertOptions,
            ),
            const SizedBox(height: 16),
            _buildLikertQuestion(
              "I feel fulfilled when helping others overcome challenges.",
              _p6,
                  (val) { setState(() { _p6 = val; }); },
              likertOptions,
            ),
            const SizedBox(height: 16),
            _buildMultipleChoiceQuestion(
              "Which activity excites you the most?",
              ["Analyzing data to make predictions", "Designing and building systems", "Understanding and improving human health"],
              _personalityQ7,
                  (val) { setState(() { _personalityQ7 = val; }); },
            ),
            const SizedBox(height: 16),
            _buildMultipleChoiceQuestion(
              "Which type of project would you prefer?",
              ["Developing innovative software solutions", "Researching solutions for medical issues", "Designing a new mechanical or electrical system"],
              _personalityQ8,
                  (val) { setState(() { _personalityQ8 = val; }); },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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
            Positioned(
              top: 70,
              left: 10,
              child: IconButton(
                icon: SvgPicture.asset("assets/images/back.svg", color: AppColors.myWhite, height: 30),
                onPressed: () { Navigator.pop(context); },
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Main scrollable content area with all three sections.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 150, // Reserve space for the bottom container.
            child: ScrollConfiguration(
              behavior: NoScrollBehavior(),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPersonalSection(),
                    _buildAcademicSection(),
                    _buildPersonalitySection(),
                  ],
                ),
              ),
            ),
          ),
          // Bottom container with rounded top corners containing progress bars and navigation.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              decoration: const BoxDecoration(
                color: AppColors.darkBlack,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress bars row.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () => _scrollToSection(_getKeyForSection(0)),
                        child: buildProgressColumn("Personal", _personalProgress, _currentSectionIndex == 0),
                      ),
                      InkWell(
                        onTap: () => _scrollToSection(_getKeyForSection(1)),
                        child: buildProgressColumn("Academic", _academicProgress, _currentSectionIndex == 1),
                      ),
                      InkWell(
                        onTap: () => _scrollToSection(_getKeyForSection(2)),
                        child: buildProgressColumn("Personality", _personalityProgress, _currentSectionIndex == 2),
                      ),
                    ],
                  ),


                  const SizedBox(height: 8),
                  // Navigation row with text labels.
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     TextButton(
                  //       style: TextButton.styleFrom(
                  //         backgroundColor: Colors.grey.withOpacity(0.3), // Transparent gray background.
                  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  //       ),
                  //       onPressed: _goBackward,
                  //       child: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           SvgPicture.asset("assets/images/backward.svg", color: AppColors.myWhite, height: 20),
                  //           const SizedBox(width: 2),
                  //           const Text("Previous", style: TextStyle(color: AppColors.myWhite, fontSize: 14)),
                  //         ],
                  //       ),
                  //     ),
                  //     TextButton(
                  //       style: TextButton.styleFrom(
                  //         backgroundColor: Colors.grey.withOpacity(0.3), // Transparent gray background.
                  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  //       ),
                  //       onPressed: _goForward,
                  //       child: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           const Text("Next", style: TextStyle(color: AppColors.myWhite, fontSize: 14)),
                  //           const SizedBox(width: 10),
                  //           SvgPicture.asset("assets/images/right_arrow.svg", color: AppColors.myWhite, height: 20),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
