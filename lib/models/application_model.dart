class ApplicationModel {
  final String id;
  final String studentId;
  final String programId;
  final String universityId;
  final String status;
  final double progressPercentage;
  final List<ApplicationPhase> phases;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Additional fields from JOIN queries
  final String? programTitle;
  final String? standardizedTitle;
  final String? programDuration;
  final List<dynamic>? importantDates;
  final String? universityTitle;
  final String? location;

  const ApplicationModel({
    required this.id,
    required this.studentId,
    required this.programId,
    required this.universityId,
    required this.status,
    required this.progressPercentage,
    required this.phases,
    required this.createdAt,
    this.updatedAt,
    this.programTitle,
    this.standardizedTitle,
    this.programDuration,
    this.importantDates,
    this.universityTitle,
    this.location,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'].toString(),
      studentId: json['student_id'].toString(),
      programId: json['program_id'].toString(),
      universityId: json['university_id'].toString(),
      status: json['status'] ?? '',
      progressPercentage: double.tryParse(json['progress_percentage']?.toString() ?? '0') ?? 0.0,
      phases: (json['phases'] as List<dynamic>?)
          ?.map((phase) => ApplicationPhase.fromJson(phase))
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      programTitle: json['program_title'],
      standardizedTitle: json['standardized_title'],
      programDuration: json['program_duration'],
      importantDates: json['important_dates'],
      universityTitle: json['university_title'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'program_id': programId,
      'university_id': universityId,
      'status': status,
      'progress_percentage': progressPercentage,
      'phases': phases.map((phase) => phase.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'program_title': programTitle,
      'standardized_title': standardizedTitle,
      'program_duration': programDuration,
      'important_dates': importantDates,
      'university_title': universityTitle,
      'location': location,
    };
  }
}

class ApplicationPhase {
  final String phase;
  final bool completed;
  final DateTime? completedAt;
  final String description;
  final String? note;

  const ApplicationPhase({
    required this.phase,
    required this.completed,
    this.completedAt,
    required this.description,
    this.note,
  });

  factory ApplicationPhase.fromJson(Map<String, dynamic> json) {
    return ApplicationPhase(
      phase: json['phase'] ?? '',
      completed: json['completed'] ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      description: json['description'] ?? '',
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phase': phase,
      'completed': completed,
      'completed_at': completedAt?.toIso8601String(),
      'description': description,
      'note': note,
    };
  }
}