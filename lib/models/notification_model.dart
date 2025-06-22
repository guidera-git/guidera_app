class NotificationModel {
  final String id;
  final String studentId;
  final String title;
  final String message;
  final String type;
  final String? relatedId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? scheduledFor;
  final DateTime createdAt;
  final String? universityTitle;

  const NotificationModel({
    required this.id,
    required this.studentId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    required this.isRead,
    this.readAt,
    this.scheduledFor,
    required this.createdAt,
    this.universityTitle,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      studentId: json['student_id'].toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      relatedId: json['related_id']?.toString(),
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      scheduledFor: json['scheduled_for'] != null
          ? DateTime.parse(json['scheduled_for'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      universityTitle: json['university_title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'title': title,
      'message': message,
      'type': type,
      'related_id': relatedId,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'scheduled_for': scheduledFor?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'university_title': universityTitle,
    };
  }
}

class NotificationSummary {
  final int totalNotifications;
  final int unreadCount;
  final int deadlineNotifications;
  final int milestoneNotifications;
  final int welcomeNotifications;
  final int recentNotifications;

  const NotificationSummary({
    required this.totalNotifications,
    required this.unreadCount,
    required this.deadlineNotifications,
    required this.milestoneNotifications,
    required this.welcomeNotifications,
    required this.recentNotifications,
  });

  factory NotificationSummary.fromJson(Map<String, dynamic> json) {
    return NotificationSummary(
      totalNotifications: int.parse(json['total_notifications'].toString()),
      unreadCount: int.parse(json['unread_count'].toString()),
      deadlineNotifications: int.parse(json['deadline_notifications'].toString()),
      milestoneNotifications: int.parse(json['milestone_notifications'].toString()),
      welcomeNotifications: int.parse(json['welcome_notifications'].toString()),
      recentNotifications: int.parse(json['recent_notifications'].toString()),
    );
  }
}

class DeadlineModel {
  final String applicationId;
  final String university;
  final String program;
  final DateTime deadline;
  final String deadlineType;
  final int daysUntil;
  final bool isUrgent;

  const DeadlineModel({
    required this.applicationId,
    required this.university,
    required this.program,
    required this.deadline,
    required this.deadlineType,
    required this.daysUntil,
    required this.isUrgent,
  });

  factory DeadlineModel.fromJson(Map<String, dynamic> json) {
    return DeadlineModel(
      applicationId: json['application_id'].toString(),
      university: json['university'] ?? '',
      program: json['program'] ?? '',
      deadline: DateTime.parse(json['deadline']),
      deadlineType: json['deadline_type'] ?? '',
      daysUntil: json['days_until'] ?? 0,
      isUrgent: json['is_urgent'] ?? false,
    );
  }
}