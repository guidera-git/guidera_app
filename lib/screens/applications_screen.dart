import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/widgets/header.dart';
import 'package:guidera_app/services/application_service.dart';
import 'dart:convert';

class ApplicationScreen extends StatefulWidget {
  final Map<String, dynamic> application;

  const ApplicationScreen({Key? key, required this.application}) : super(key: key);

  @override
  State<ApplicationScreen> createState() => _ApplicationScreenState();
}

class _ApplicationScreenState extends State<ApplicationScreen> {
  final ApplicationService _applicationService = ApplicationService();
  List<Map<String, dynamic>> _phases = [];
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadApplicationDetails();
  }

  Future<void> _loadApplicationDetails() async {
    setState(() => _isLoading = true);

    try {
      // 1️⃣ Call returns a Map<String, dynamic>, not Response
      final Map<String, dynamic>? data = await _applicationService
          .getApplication(widget.application['id'].toString());

      if (data != null) {
        // 2️⃣ Pull phases directly out of the decoded map
        setState(() {
          _phases = List<Map<String, dynamic>>.from(data['phases'] ?? []);
          _isLoading = false;
        });
      } else {
        // 3️⃣ Handle unexpected null
        throw Exception('No data returned from server');
      }
    } catch (e) {
      print('Error loading application details: $e');
      // Fallback to default phases if API fails
      setState(() {
        _phases = _getDefaultPhases();
        _isLoading = false;
      });
    }
  }


  List<Map<String, dynamic>> _getDefaultPhases() {
    return [
      {
        'phase': 'application_submitted',
        'description': 'Submit your online application to the university.',
        'completed': false,
        'note': null,
      },
      {
        'phase': 'test_scheduled',
        'description': 'Schedule your admission test.',
        'completed': false,
        'note': null,
      },
      {
        'phase': 'test_taken',
        'description': 'Take the admission test on the scheduled date.',
        'completed': false,
        'note': null,
      },
      {
        'phase': 'interview_scheduled',
        'description': 'Book your interview slot with the admission panel.',
        'completed': false,
        'note': null,
      },
      {
        'phase': 'interview_completed',
        'description': 'Attend and complete your interview successfully.',
        'completed': false,
        'note': null,
      },
      {
        'phase': 'admission_offer_received',
        'description': 'Receive an admission offer from the university.',
        'completed': false,
        'note': null,
      },
      {
        'phase': 'offer_accepted',
        'description': 'Confirm and accept the admission offer.',
        'completed': false,
        'note': null,
      },
    ];
  }

  double get progressPercent {
    if (_phases.isEmpty) return 0.0;
    int completedCount = _phases.where((phase) => phase['completed'] == true).length;
    return completedCount / _phases.length;
  }

  Future<void> _togglePhase(int index) async {
    if (_isUpdating) return;

    setState(() => _isUpdating = true);

    try {
      final phase = _phases[index];
      final newCompleted = !phase['completed'];

      final success = await _applicationService.updateApplicationPhase(
        widget.application['id'].toString(),
        phase['phase'],
        newCompleted,
        note: phase['note'],
      );

      if (success) {
        setState(() {
          _phases[index]['completed'] = newCompleted;
        });

        // Update application status based on progress
        final newProgress = progressPercent;
        String newStatus = 'started';
        if (newProgress == 1.0) {
          newStatus = 'completed';
        } else if (newProgress > 0.0) {
          newStatus = 'in_progress';
        }

        await _applicationService.updateApplicationStatus(
          widget.application['id'].toString(),
          newStatus,
        );

        Fluttertoast.showToast(
          msg: newCompleted ? "Phase Completed!" : "Phase Unmarked!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppColors.darkBlue,
          textColor: AppColors.myWhite,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error updating phase: $e",
        backgroundColor: Colors.red,
        textColor: AppColors.myWhite,
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _addOrEditNote(int index) async {
    TextEditingController noteController =
    TextEditingController(text: _phases[index]['note']);

    showDialog(
      context: context,
      barrierColor: AppColors.darkBlack.withOpacity(0.8),
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.surfaceColor(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Add Note for ${_getPhaseTitle(_phases[index]['phase'])}",
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: noteController,
                  maxLines: 4,
                  style: TextStyle(color: AppColors.textPrimary(context)),
                  decoration: InputDecoration(
                    hintText: "Enter your note here...",
                    hintStyle: TextStyle(color: AppColors.textSecondary(context)),
                    filled: true,
                    fillColor: AppColors.backgroundColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final success = await _applicationService.updateApplicationPhase(
                      widget.application['id'].toString(),
                      _phases[index]['phase'],
                      _phases[index]['completed'],
                      note: noteController.text,
                    );

                    if (success) {
                      setState(() {
                        _phases[index]['note'] = noteController.text;
                      });
                    }
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
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.myWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getPhaseTitle(String phase) {
    switch (phase) {
      case 'application_submitted':
        return 'Application Submitted';
      case 'test_scheduled':
        return 'Test Scheduled';
      case 'test_taken':
        return 'Test Taken';
      case 'interview_scheduled':
        return 'Interview Scheduled';
      case 'interview_completed':
        return 'Interview Completed';
      case 'admission_offer_received':
        return 'Admission Offer Received';
      case 'offer_accepted':
        return 'Offer Accepted';
      default:
        return phase.replaceAll('_', ' ').toUpperCase();
    }
  }

  Widget _buildPhaseCard(int index) {
    final phase = _phases[index];
    final isCompleted = phase['completed'] ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.lightBlue.withOpacity(0.3) : AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? AppColors.lightBlue : AppColors.borderColor(context),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  key: ValueKey<bool>(isCompleted),
                  color: isCompleted ? AppColors.lightBlue : AppColors.textSecondary(context),
                  size: 28,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _getPhaseTitle(phase['phase']),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                      "Completed",
                      style: TextStyle(color: AppColors.myWhite, fontSize: 12)
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            phase['description'] ?? '',
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => _addOrEditNote(index),
                icon: SvgPicture.asset(
                  "assets/images/note_filled.svg",
                  color: AppColors.textPrimary(context),
                  height: 25,
                ),
                label: Text(
                    "Add Note",
                    style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14)
                ),
              ),
              TextButton(
                onPressed: _isUpdating ? null : () => _togglePhase(index),
                child: Text(
                  isCompleted ? "Undo" : "Mark Complete",
                  style: TextStyle(
                      color: _isUpdating ? AppColors.textSecondary(context) : AppColors.lightBlue,
                      fontSize: 14
                  ),
                ),
              ),
            ],
          ),
          if (phase['note'] != null && phase['note']!.toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Note: ${phase['note']}",
                style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontStyle: FontStyle.italic
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsDashboard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.application['university_title'] ?? 'Application Progress',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.application['program_title'] ?? '',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Overall Progress: ${(progressPercent * 100).toStringAsFixed(0)}%",
                  style: TextStyle(color: AppColors.textPrimary(context), fontSize: 16),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    minHeight: 6,
                    backgroundColor: AppColors.backgroundColor(context).withOpacity(0.5),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.lightBlue),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SvgPicture.asset(
            "assets/images/visual_2.svg",
            height: 100,
            width: 100,
          ),
        ],
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
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildAnalyticsDashboard(),
          Expanded(
            child: ListView.builder(
              itemCount: _phases.length,
              itemBuilder: (context, index) {
                return _buildPhaseCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }
}