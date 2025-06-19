import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/theme/app_colors.dart';
import '../Widgets/header.dart';
import '../services/api_service.dart';
import 'package:guidera_app/screens/recommendation_loading_screen.dart';

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
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  // Global keys for each section.
  final GlobalKey _academicKey = GlobalKey();
  final GlobalKey _personalityKey = GlobalKey();
  final ApiService _api = ApiService();

  // Current section index: 0 = Academic, 1 = Personality.
  int _currentSectionIndex = 0;

  // Main scroll controller.
  final ScrollController _scrollController = ScrollController();

  // ---------------- PERSONAL SECTION FIELDS ----------------

  String _gender = "Male"; // Options: Male, Female, Other

  // ---------------- ACADEMIC SECTION FIELDS ----------------
  String _studentType = "Board"; // "Board" or "Cambridge"
  // Board-specific
  final TextEditingController _matricMarksController = TextEditingController();

  final TextEditingController _intermediateMarksController =
  TextEditingController();
  // Cambridge-specific
  String _oLevelGrade = "A+";
  String _aLevelGrade = "A+";
  // Common academic dropdowns
  String _studyStream = "";

  // ---------------- PERSONALITY SECTION FIELDS ----------------
  // Likert scale responses (0: Strongly Disagree ... 4: Strongly Agree)
  int? _p1, _p2, _p3, _p4, _p5, _p6;
  // Multiple-choice questions for personality
  int? _p7;
  int? _p8;

  // Dummy question lists for slider (not displayed to user)
  final List<String> _academicQuestions =
  List.generate(10, (i) => "Academic Q${i + 1}");
  final List<String> _personalityQuestions =
  List.generate(10, (i) => "Personality Q${i + 1}");

  // Getter for current section's dummy questions.
  List<String> get _currentQuestions {
    if (_currentSectionIndex == 0) return _academicQuestions;
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
    super.dispose();
  }

  bool get _isFormComplete {
    return _academicProgress == 1.0 &&
        _personalityProgress == 1.0;
  }

  // Map grades to percentages for Cambridge students
  static const Map<String, double> _gradeToPct = {
    "A+": 95.0,
    "A" : 90.0,
    "B" : 80.0,
    "C" : 70.0,
    "D" : 60.0,
  };
  void _saveProfile() async {
    // Compute academic percentage correctly
    double academicPct;
    if (_studentType == "Board") {
      final matric    = double.tryParse(_matricMarksController.text) ?? 0.0;
      final intermediate =
          double.tryParse(_intermediateMarksController.text) ?? 0.0;
      // Assuming full marks of 1100 each (matric + intermediate = 2200)
      academicPct = ((matric + intermediate) / 2200) * 100;
    } else {
      // Cambridge: map grades to percentages and average
      final oPct = _gradeToPct[_oLevelGrade] ?? 0.0;
      final aPct = _gradeToPct[_aLevelGrade] ?? 0.0;
      academicPct = (oPct + aPct) / 2;
    }

    final body = {
      "Gender": _gender.toLowerCase() == "male" ? 1 : 0,
      "Academic Percentage": academicPct,    // now 0–100
      "Study Stream": _studyStream,
      "Analytical": _p1! + 1,
      "Logical": _p2! + 1,
      "Explaining": _p3! + 1,
      "Creative": _p4! + 1,
      "Detail-Oriented": _p5! + 1,
      "Helping": _p6! + 1,
      "Activity Preference": _p7! + 1,
      "Project Preference": _p8! + 1,
    };

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RecommendationLoadingScreen(
          payload: body,
        ),
      ),
    );
  }

  // Update current section index based on scroll position.
  void _updateCurrentSection() {
    double minDistance = double.infinity;
    int newIndex = _currentSectionIndex;

    List<GlobalKey> keys = [_academicKey, _personalityKey];
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

  GlobalKey _getKeyForSection(int index) {
    if (index == 0) return _academicKey;
    return _personalityKey;
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
    if (_p7 != null) answered++;
    if (_p8 != null) answered++;
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
        labelStyle: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 14,
            fontWeight: FontWeight.normal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: AppColors.borderColor(context), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: AppColors.borderColor(context), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: AppColors.lightBlue, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceColor(context),
        contentPadding:
        EdgeInsets.symmetric(horizontal: 16, vertical: verticalPadding),
      ),
      icon: Icon(Icons.arrow_drop_down, color: AppColors.textPrimary(context)),
      dropdownColor: AppColors.surfaceColor(context),
      style: TextStyle(
          color: AppColors.textPrimary(context), fontSize: 14),
      items: items
          .map((item) => DropdownMenuItem(
        value: item,
        child: Text(item,
            style: TextStyle(color: AppColors.textPrimary(context))),
      ))
          .toList(),
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
        labelStyle: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 14,
            fontWeight: FontWeight.normal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: AppColors.borderColor(context), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: AppColors.borderColor(context), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: AppColors.lightBlue, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceColor(context),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: TextStyle(
          color: AppColors.textPrimary(context),
          fontSize: 14,
          fontWeight: FontWeight.normal),
      onChanged: onChanged,
    );
  }

  // Modern Progress Column Helper.
  Widget buildProgressColumn(String label, double progress, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(
                color: isActive ? AppColors.lightBlue : AppColors.textSecondary(context),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: 100,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.borderColor(context),
            borderRadius: BorderRadius.circular(5),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: isActive ? AppColors.lightBlue : AppColors.textSecondary(context),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Likert Question Helper.
  Widget _buildLikertQuestion(String question, int? currentValue,
      Function(int?) onChanged, List<String> options) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question,
              style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(options.length, (index) {
              return ChoiceChip(
                label: Text(options[index],
                    style: const TextStyle(fontSize: 12)),
                selected: currentValue == index,
                selectedColor: AppColors.lightBlue,
                backgroundColor: AppColors.backgroundColor(context),
                labelStyle: TextStyle(
                  color: currentValue == index
                      ? AppColors.myWhite
                      : AppColors.textPrimary(context),
                ),
                onSelected: (selected) {
                  onChanged(selected ? index : null);
                },
              );
            }),
          ),
        ],
      ),
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
            style: TextStyle(
                color: displayColor,
                fontSize: 14,
                fontWeight: FontWeight.normal)),
      ],
    );
  }

  // ---------------- SECTION BUILDERS ----------------

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
              onChanged: (val) {
                setState(() {
                  _studentType = val!;
                });
              },
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
                onChanged: (val) {
                  setState(() {
                    _oLevelGrade = val!;
                  });
                },
                verticalPadding: 6,
              ),
              const SizedBox(height: 16),
              buildModernDropdown(
                value: _aLevelGrade,
                label: "A-Level Grade",
                items: ["A+", "A", "B", "C", "D"],
                onChanged: (val) {
                  setState(() {
                    _aLevelGrade = val!;
                  });
                },
                verticalPadding: 6,
              ),
            ],
            const SizedBox(height: 16),
            buildModernDropdown(
              value: _studyStream.isEmpty ? null : _studyStream,
              label: "Study Stream",
              items: [
                "Pre-Medical",
                "Pre-Engineering",
                "Computer Science",
              ],
              onChanged: (val) {
                setState(() {
                  _studyStream = val!;
                });
              },
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
    final List<String> likertOptions = [
      "Strongly Disagree",
      "Disagree",
      "Neutral",
      "Agree",
      "Strongly Agree"
    ];

    const threeOption7 = [
      "Analyzing data to make predictions",   // → 1
      "Designing and building systems",       // → 2
      "Understanding and improving human health" // → 3
    ];
    const threeOption8 = [
      "Developing innovative software solutions",    // → 1
      "Researching solutions for medical issues",    // → 2
      "Designing a new mechanical or electrical system" // → 3
    ];

    return Container(
      key: _personalityKey,
      child: Padding(
        padding: const EdgeInsets.all(36.0),
        child: Column(
          children: [
            _buildLikertQuestion(
              "I enjoy analyzing data and identifying patterns to solve problems.",
              _p1,
                  (val) {
                setState(() {
                  _p1 = val;
                });
              },
              likertOptions,
            ),
            _buildLikertQuestion(
              "I prefer tasks that require logical thinking and structured solutions.",
              _p2,
                  (val) {
                setState(() {
                  _p2 = val;
                });
              },
              likertOptions,
            ),
            _buildLikertQuestion(
              "I can explain complex topics to others in an engaging way.",
              _p3,
                  (val) {
                setState(() {
                  _p3 = val;
                });
              },
              likertOptions,
            ),
            _buildLikertQuestion(
              "I enjoy brainstorming innovative ideas to solve challenges.",
              _p4,
                  (val) {
                setState(() {
                  _p4 = val;
                });
              },
              likertOptions,
            ),
            _buildLikertQuestion(
              "I pay close attention to details to ensure accuracy in my work.",
              _p5,
                  (val) {
                setState(() {
                  _p5 = val;
                });
              },
              likertOptions,
            ),
            _buildLikertQuestion(
              "I feel fulfilled when helping others overcome challenges.",
              _p6,
                  (val) {
                setState(() {
                  _p6 = val;
                });
              },
              likertOptions,
            ),
            _buildLikertQuestion(
              "Which activity excites you the most?",
              _p7,
                  (val) => setState(() => _p7 = val),
              threeOption7,
            ),
            _buildLikertQuestion(
              "Which type of project would you prefer?",
              _p8,
                  (val) => setState(() => _p8 = val),
              threeOption8,
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isFormComplete ? _saveProfile : null,
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled))
                        return AppColors.textSecondary(context).withOpacity(0.5);
                      return AppColors.lightBlue; // Enabled color.
                    },
                  ),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  shape:
                  MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  elevation:
                  MaterialStateProperty.resolveWith<double>(
                        (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled))
                        return 0;
                      return 4;
                    },
                  ),
                ),
                child: Text(
                  "Proceed",
                  style: TextStyle(
                    color: _isFormComplete
                        ? AppColors.myWhite
                        : AppColors.textSecondary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                icon: SvgPicture.asset("assets/images/back.svg",
                    color: AppColors.textPrimary(context), height: 30),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Main scrollable content area with all sections.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 120, // Reserve space for the bottom container.
            child: ScrollConfiguration(
              behavior: NoScrollBehavior(),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 32),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.lightBlack
                    : AppColors.lightSurface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor(context),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress bars row.
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () =>
                            _scrollToSection(_getKeyForSection(0)),
                        child: buildProgressColumn("Academic",
                            _academicProgress, _currentSectionIndex == 0),
                      ),
                      InkWell(
                        onTap: () =>
                            _scrollToSection(_getKeyForSection(1)),
                        child: buildProgressColumn("Personality",
                            _personalityProgress,
                            _currentSectionIndex == 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}