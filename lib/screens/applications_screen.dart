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
      final Map<String, dynamic>? data = await _applicationService
          .getApplication(widget.application['id'].toString());

      if (data != null) {
        setState(() {
          _phases = List<Map<String, dynamic>>.from(data['phases'] ?? []);
          _isLoading = false;
        });
      } else {
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
        'phase': 'document_gathering',
        'description': 'Start gathering all required documents for your application. Get your transcripts, certificates, and other necessary paperwork ready.',
        'completed': false,
        'note': null,
      },
      {
        'phase': 'application_submission',
        'description': 'Submit your completed application form with all required documents to the university.',
        'completed': false,
        'note': null,
      },
      {
        'phase': 'application_fee_submission',
        'description': 'Pay the application fee as required by the university. Check deadlines to avoid missing the payment window.',
        'completed': false,
        'note': null,
      },
      {
        'phase': 'entry_test_and_result',
        'description': 'Complete your entry test, attend interview if required, and receive your admission result.',
        'completed': false,
        'note': null,
      }
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
          msg: newCompleted ? "Stage Completed! 🎉" : "Stage Unmarked!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppColors.darkBlue,
          textColor: AppColors.myWhite,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error updating stage: $e",
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
      case 'document_gathering':
        return '1. Document Gathering';
      case 'application_submission':
        return '2. Application Submission';
      case 'application_fee_submission':
        return '3. Application Fee Submission';
      case 'entry_test_and_result':
        return '4. Entry Test & Result';
      default:
        return phase.replaceAll('_', ' ').toUpperCase();
    }
  }

  IconData _getPhaseIcon(String phase) {
    switch (phase) {
      case 'document_gathering':
        return Icons.folder_outlined;
      case 'application_submission':
        return Icons.send_outlined;
      case 'application_fee_submission':
        return Icons.payment_outlined;
      case 'entry_test_and_result':
        return Icons.school_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  Color _getPhaseColor(String phase, bool isCompleted) {
    if (isCompleted) return Colors.green;

    switch (phase) {
      case 'document_gathering':
        return Colors.blue;
      case 'application_submission':
        return Colors.orange;
      case 'application_fee_submission':
        return Colors.purple;
      case 'entry_test_and_result':
        return Colors.teal;
      default:
        return AppColors.lightBlue;
    }
  }

  Widget _buildPhaseCard(int index) {
    final phase = _phases[index];
    final isCompleted = phase['completed'] ?? false;
    final phaseColor = _getPhaseColor(phase['phase'], isCompleted);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? phaseColor.withOpacity(0.1)
            : AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? phaseColor : AppColors.borderColor(context),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: phaseColor.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: phaseColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : _getPhaseIcon(phase['phase']),
                  color: phaseColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getPhaseTitle(phase['phase']),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: phaseColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "✓ Completed",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            phase['description'] ?? '',
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => _addOrEditNote(index),
                icon: Icon(
                  Icons.note_add_outlined,
                  color: AppColors.textPrimary(context),
                  size: 20,
                ),
                label: Text(
                  phase['note'] != null && phase['note'].toString().isNotEmpty
                      ? "Edit Note"
                      : "Add Note",
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _isUpdating ? null : () => _togglePhase(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? Colors.grey : phaseColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  isCompleted ? "Completed" : "Mark Complete",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (phase['note'] != null && phase['note']!.toString().isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.borderColor(context),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.sticky_note_2_outlined,
                    color: AppColors.textSecondary(context),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      phase['note'],
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkBlue,
            AppColors.lightBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.application['university_title'] ?? 'Application Progress',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.application['program_title'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      "${(progressPercent * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Complete",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${_phases.where((p) => p['completed'] == true).length} of ${_phases.length} stages completed",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
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
          _buildProgressHeader(),
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