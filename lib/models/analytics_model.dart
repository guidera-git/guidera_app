class ApplicationsAnalytics {
  final ApplicationsSummary summary;
  final List<PhaseAnalytics> phaseAnalytics;
  final List<UniversityStats> universityStats;
  final DateTime generatedAt;

  const ApplicationsAnalytics({
    required this.summary,
    required this.phaseAnalytics,
    required this.universityStats,
    required this.generatedAt,
  });

  factory ApplicationsAnalytics.fromJson(Map<String, dynamic> json) {
    return ApplicationsAnalytics(
      summary: ApplicationsSummary.fromJson(json['summary'] as Map<String, dynamic>),
      phaseAnalytics: (json['phase_analytics'] as List<dynamic>)
          .map((item) => PhaseAnalytics.fromJson(item as Map<String, dynamic>))
          .toList(),
      universityStats: (json['university_stats'] as List<dynamic>)
          .map((item) => UniversityStats.fromJson(item as Map<String, dynamic>))
          .toList(),
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }
}

class ApplicationsSummary {
  final int totalApplications;
  final int completedApplications;
  final int inProgressApplications;
  final int submittedApplications;
  final double averageProgress;
  final int recentApplications;
  final DateTime? firstApplicationDate;
  final DateTime? lastActivityDate;

  const ApplicationsSummary({
    required this.totalApplications,
    required this.completedApplications,
    required this.inProgressApplications,
    required this.submittedApplications,
    required this.averageProgress,
    required this.recentApplications,
    this.firstApplicationDate,
    this.lastActivityDate,
  });

  factory ApplicationsSummary.fromJson(Map<String, dynamic> json) {
    return ApplicationsSummary(
      totalApplications: int.parse(json['total_applications'].toString()),
      completedApplications: int.parse(json['completed_applications'].toString()),
      inProgressApplications: int.parse(json['in_progress_applications'].toString()),
      submittedApplications: int.parse(json['submitted_applications'].toString()),
      averageProgress: double.parse(json['average_progress']?.toString() ?? '0'),
      recentApplications: int.parse(json['recent_applications'].toString()),
      firstApplicationDate: json['first_application_date'] != null
          ? DateTime.parse(json['first_application_date'] as String)
          : null,
      lastActivityDate: json['last_activity_date'] != null
          ? DateTime.parse(json['last_activity_date'] as String)
          : null,
    );
  }
}

class PhaseAnalytics {
  final String phase;
  final int totalCount;
  final int completedCount;
  final double? avgDurationDays;

  const PhaseAnalytics({
    required this.phase,
    required this.totalCount,
    required this.completedCount,
    this.avgDurationDays,
  });

  factory PhaseAnalytics.fromJson(Map<String, dynamic> json) {
    return PhaseAnalytics(
      phase: json['phase'] as String? ?? '',
      totalCount: int.parse(json['total_count'].toString()),
      completedCount: int.parse(json['completed_count'].toString()),
      avgDurationDays: json['avg_duration_days'] != null
          ? double.parse(json['avg_duration_days'].toString())
          : null,
    );
  }
}

class UniversityStats {
  final String universityTitle;
  final int applicationCount;
  final double avgProgress;
  final int completedCount;

  const UniversityStats({
    required this.universityTitle,
    required this.applicationCount,
    required this.avgProgress,
    required this.completedCount,
  });

  factory UniversityStats.fromJson(Map<String, dynamic> json) {
    return UniversityStats(
      universityTitle: json['university_title'] as String? ?? '',
      applicationCount: int.parse(json['application_count'].toString()),
      avgProgress: double.parse(json['avg_progress']?.toString() ?? '0'),
      completedCount: int.parse(json['completed_count'].toString()),
    );
  }
}

class NotificationsAnalytics {
  final NotificationsSummary summary;
  final List<NotificationTypeBreakdown> typeBreakdown;
  final List<NotificationTimeline> timeline;
  final DateTime generatedAt;

  const NotificationsAnalytics({
    required this.summary,
    required this.typeBreakdown,
    required this.timeline,
    required this.generatedAt,
  });

  factory NotificationsAnalytics.fromJson(Map<String, dynamic> json) {
    return NotificationsAnalytics(
      summary: NotificationsSummary.fromJson(json['summary'] as Map<String, dynamic>),
      typeBreakdown: (json['type_breakdown'] as List<dynamic>)
          .map((item) => NotificationTypeBreakdown.fromJson(item as Map<String, dynamic>))
          .toList(),
      timeline: (json['timeline'] as List<dynamic>)
          .map((item) => NotificationTimeline.fromJson(item as Map<String, dynamic>))
          .toList(),
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }
}

class NotificationsSummary {
  final int totalNotifications;
  final int readNotifications;
  final int unreadNotifications;
  final int recentNotifications;
  final double readRatePercentage;

  const NotificationsSummary({
    required this.totalNotifications,
    required this.readNotifications,
    required this.unreadNotifications,
    required this.recentNotifications,
    required this.readRatePercentage,
  });

  factory NotificationsSummary.fromJson(Map<String, dynamic> json) {
    return NotificationsSummary(
      totalNotifications: int.parse(json['total_notifications'].toString()),
      readNotifications: int.parse(json['read_notifications'].toString()),
      unreadNotifications: int.parse(json['unread_notifications'].toString()),
      recentNotifications: int.parse(json['recent_notifications'].toString()),
      readRatePercentage: double.parse(json['read_rate_percentage']?.toString() ?? '0'),
    );
  }
}

class NotificationTypeBreakdown {
  final String type;
  final int totalCount;
  final int readCount;
  final double readRatePercentage;
  final double? avgReadTimeHours;

  const NotificationTypeBreakdown({
    required this.type,
    required this.totalCount,
    required this.readCount,
    required this.readRatePercentage,
    this.avgReadTimeHours,
  });

  factory NotificationTypeBreakdown.fromJson(Map<String, dynamic> json) {
    return NotificationTypeBreakdown(
      type: json['type'] as String? ?? '',
      totalCount: int.parse(json['total_count'].toString()),
      readCount: int.parse(json['read_count'].toString()),
      readRatePercentage: double.parse(json['read_rate_percentage']?.toString() ?? '0'),
      avgReadTimeHours: json['avg_read_time_hours'] != null
          ? double.parse(json['avg_read_time_hours'].toString())
          : null,
    );
  }
}

class NotificationTimeline {
  final DateTime date;
  final int notificationsSent;
  final int notificationsRead;

  const NotificationTimeline({
    required this.date,
    required this.notificationsSent,
    required this.notificationsRead,
  });

  factory NotificationTimeline.fromJson(Map<String, dynamic> json) {
    return NotificationTimeline(
      date: DateTime.parse(json['date'] as String),
      notificationsSent: int.parse(json['notifications_sent'].toString()),
      notificationsRead: int.parse(json['notifications_read'].toString()),
    );
  }
}

class SystemAnalytics {
  final SystemKPIs kpis;
  final List<EventBreakdown> eventBreakdown;
  final List<UserActivity> userActivity;
  final int periodDays;
  final DateTime generatedAt;

  const SystemAnalytics({
    required this.kpis,
    required this.eventBreakdown,
    required this.userActivity,
    required this.periodDays,
    required this.generatedAt,
  });

  factory SystemAnalytics.fromJson(Map<String, dynamic> json) {
    return SystemAnalytics(
      kpis: SystemKPIs.fromJson(json['kpis'] as Map<String, dynamic>),
      eventBreakdown: (json['event_breakdown'] as List<dynamic>)
          .map((item) => EventBreakdown.fromJson(item as Map<String, dynamic>))
          .toList(),
      userActivity: (json['user_activity'] as List<dynamic>)
          .map((item) => UserActivity.fromJson(item as Map<String, dynamic>))
          .toList(),
      periodDays: json['period_days'] as int? ?? 30,
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }
}

class SystemKPIs {
  final int activeApplications;
  final int notificationsThisWeek;
  final int eventsToday;
  final double avgApplicationProgress;

  const SystemKPIs({
    required this.activeApplications,
    required this.notificationsThisWeek,
    required this.eventsToday,
    required this.avgApplicationProgress,
  });

  factory SystemKPIs.fromJson(Map<String, dynamic> json) {
    return SystemKPIs(
      activeApplications: int.parse(json['active_applications'].toString()),
      notificationsThisWeek: int.parse(json['notifications_this_week'].toString()),
      eventsToday: int.parse(json['events_today'].toString()),
      avgApplicationProgress: double.parse(json['avg_application_progress']?.toString() ?? '0'),
    );
  }
}

class EventBreakdown {
  final String eventType;
  final int eventCount;
  final DateTime date;

  const EventBreakdown({
    required this.eventType,
    required this.eventCount,
    required this.date,
  });

  factory EventBreakdown.fromJson(Map<String, dynamic> json) {
    return EventBreakdown(
      eventType: json['event_type'] as String? ?? '',
      eventCount: int.parse(json['event_count'].toString()),
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class UserActivity {
  final DateTime date;
  final int uiInteractions;
  final int systemEvents;
  final int uniqueEventTypes;

  const UserActivity({
    required this.date,
    required this.uiInteractions,
    required this.systemEvents,
    required this.uniqueEventTypes,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      date: DateTime.parse(json['date'] as String),
      uiInteractions: int.parse(json['ui_interactions'].toString()),
      systemEvents: int.parse(json['system_events'].toString()),
      uniqueEventTypes: int.parse(json['unique_event_types'].toString()),
    );
  }
}
