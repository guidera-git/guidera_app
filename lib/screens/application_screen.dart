import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/widgets/header.dart';

/// Data model representing a milestone in the admission journey.
class Milestone {
  String title;
  String description;
  bool completed;
  String? note;

  Milestone({
    required this.title,
    required this.description,
    this.completed = false,
    this.note,
  });
}

/// An interactive Admission Journey screen that shows the user’s roadmap.
class AdmissionJourneyScreen extends StatefulWidget {
  const AdmissionJourneyScreen({Key? key}) : super(key: key);

  @override
  State<AdmissionJourneyScreen> createState() => _AdmissionJourneyScreenState();
}

class _AdmissionJourneyScreenState extends State<AdmissionJourneyScreen> {
  // List of sample milestones.
  List<Milestone> milestones = [
    Milestone(
      title: "Application Submitted",
      description: "Submit your online application to the university.",
    ),
    Milestone(
      title: "Test Scheduled",
      description: "Schedule your admission test.",
    ),
    Milestone(
      title: "Test Taken",
      description: "Take the admission test on the scheduled date.",
    ),
    Milestone(
      title: "Interview Scheduled",
      description: "Book your interview slot with the admission panel.",
    ),
    Milestone(
      title: "Interview Completed",
      description: "Attend and complete your interview successfully.",
    ),
    Milestone(
      title: "Admission Offer Received",
      description: "Receive an admission offer from the university.",
    ),
    Milestone(
      title: "Accepted Offer",
      description: "Confirm and accept the admission offer.",
    ),
  ];

  // Calculate overall progress based on completed milestones.
  double get progressPercent {
    int completedCount = milestones.where((m) => m.completed).length;
    return completedCount / milestones.length;
  }

  /// Toggles the completion state of a milestone.
  void toggleMilestone(int index) {
    setState(() {
      milestones[index].completed = !milestones[index].completed;
    });
    Fluttertoast.showToast(
      msg: milestones[index].completed ? "Milestone Completed!" : "Milestone Unmarked!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.darkBlue,
      textColor: AppColors.myWhite,
      fontSize: 16.0,
    );
  }

  /// Allows the user to add or edit a personal note for the milestone.
  void addOrEditNote(int index) {
    TextEditingController noteController =
    TextEditingController(text: milestones[index].note);
    showDialog(
      context: context,
      barrierColor: AppColors.darkBlack.withOpacity(0.8),
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.lightBlack,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Add Note for ${milestones[index].title}",
                  style: const TextStyle(
                    color: AppColors.myWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: noteController,
                  maxLines: 4,
                  style: const TextStyle(color: AppColors.myWhite),
                  decoration: InputDecoration(
                    hintText: "Enter your note here...",
                    hintStyle: TextStyle(color: AppColors.myWhite.withOpacity(0.6)),
                    filled: true,
                    fillColor: AppColors.darkBlack,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      milestones[index].note = noteController.text;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    "Save Note",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds a card widget for a single milestone.
  Widget buildMilestoneCard(int index) {
    final milestone = milestones[index];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: milestone.completed ? AppColors.lightBlue.withOpacity(0.3) : AppColors.lightBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: milestone.completed ? AppColors.lightBlue : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row: animated icon, title text, and achievement badge.
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  milestone.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                  key: ValueKey<bool>(milestone.completed),
                  color: milestone.completed ? AppColors.lightBlue : Colors.grey,
                  size: 28,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  milestone.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: milestone.completed ? FontWeight.bold : FontWeight.normal,
                    color: AppColors.myWhite,
                  ),
                ),
              ),
              if (milestone.completed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text("Badge", style: TextStyle(color: AppColors.myWhite, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            milestone.description,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => addOrEditNote(index),
                icon:  SvgPicture.asset(
                  "assets/images/note_filled.svg",
                  color: AppColors.myWhite,
                  height: 25,
                ),
                label: const Text("Add Note", style: TextStyle(color: AppColors.myWhite, fontSize: 14)),
              ),
              TextButton(
                onPressed: () => toggleMilestone(index),
                child: Text(
                  milestone.completed ? "Undo" : "Mark Complete",
                  style: const TextStyle(color: AppColors.lightBlue, fontSize: 14),
                ),
              ),
            ],
          ),
          if (milestone.note != null && milestone.note!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Note: ${milestone.note}",
                style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds an enhanced analytics dashboard at the top.
  Widget buildAnalyticsDashboard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBlack,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Left side: Text and progress indicator.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Journey Analytics",
                  style: TextStyle(
                    color: AppColors.myWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Overall Progress: ${(progressPercent * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(color: AppColors.myWhite, fontSize: 16),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    minHeight: 6, // Reduced height for a slimmer progress bar.
                    backgroundColor: AppColors.darkBlack.withOpacity(0.5),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.lightBlue),
                  ),
                ),
                const SizedBox(height: 10),

              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right side: Custom SVG illustration.
          SvgPicture.asset(
            "assets/images/visual_2.svg",
            height: 100,
            width: 100,
          ),
        ],
      ),
    );
  }

  /// Main build method.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.myBlack,
      // Custom AppBar using GuideraHeader with back and notification icons.
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

          ],
        ),
      ),
      body: Column(
        children: [
          // Enhanced Analytics Dashboard at the top.
          buildAnalyticsDashboard(),
          // Expanded timeline of milestones.
          Expanded(
            child: ListView.builder(
              itemCount: milestones.length,
              itemBuilder: (context, index) {
                return buildMilestoneCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
