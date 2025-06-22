class SavedProgramModel {
  final String savedId;
  final DateTime savedAt;
  final String programId;
  final String programTitle;
  final String? standardizedTitle;
  final String? programDuration;
  final String? creditHours;
  final String? calculatedTotalFee;
  final List<dynamic>? importantDates;
  final String universityId;
  final String universityTitle;
  final String location;
  final String? qsRanking;

  SavedProgramModel({
    required this.savedId,
    required this.savedAt,
    required this.programId,
    required this.programTitle,
    this.standardizedTitle,
    this.programDuration,
    this.creditHours,
    this.calculatedTotalFee,
    this.importantDates,
    required this.universityId,
    required this.universityTitle,
    required this.location,
    this.qsRanking,
  });

  factory SavedProgramModel.fromJson(Map<String, dynamic> json) {
    return SavedProgramModel(
      savedId: json['saved_id'].toString(),
      savedAt: DateTime.parse(json['saved_at']),
      programId: json['program_id'].toString(),
      programTitle: json['program_title'] ?? '',
      standardizedTitle: json['standardized_title'],
      programDuration: json['program_duration'],
      creditHours: json['credit_hours']?.toString(),
      calculatedTotalFee: json['calculated_total_fee'],
      importantDates: json['important_dates'],
      universityId: json['university_id'].toString(),
      universityTitle: json['university_title'] ?? '',
      location: json['location'] ?? '',
      qsRanking: json['qs_ranking']?.toString(),
    );
  }

  String get formattedFee {
    if (calculatedTotalFee == null) return 'N/A';
    return calculatedTotalFee!;
  }

  String get displayTitle {
    return standardizedTitle ?? programTitle;
  }

  String get durationInSemesters {
    if (programDuration == null) return 'N/A';
    return programDuration!;
  }

  // Get next deadline from important dates
  DateTime? get nextDeadline {
    if (importantDates == null || importantDates!.isEmpty) return null;

    try {
      final dates = importantDates!.first as Map<String, dynamic>;
      final deadlineStr = dates['deadline_application_submission'] ??
          dates['deadline_admission_test_ecat'] ??
          dates['deadline_sat'];

      if (deadlineStr != null) {
        return DateTime.parse(deadlineStr);
      }
    } catch (e) {
      print('Error parsing deadline: $e');
    }
    return null;
  }

  String get statusMessage {
    final deadline = nextDeadline;
    if (deadline == null) return 'Check university website for dates';

    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return 'Deadline passed';
    } else if (difference.inDays == 0) {
      return 'Closing in ${difference.inHours} hours';
    } else if (difference.inDays <= 7) {
      return 'Closing in ${difference.inDays} days';
    } else {
      return 'Opening soon';
    }
  }
}