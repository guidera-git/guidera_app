import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/application_service.dart';
import '../models/notification_model.dart';
import '../theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  final ApplicationService _applicationService = ApplicationService();
  late TabController _tabController;

  List<NotificationModel> _notifications = [];
  List<DeadlineModel> _deadlines = [];
  List<Map<String, dynamic>> _applications = [];
  NotificationSummary? _summary;

  bool _loading = true;
  String? _error;
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _api.getNotifications(unreadOnly: _showUnreadOnly),
        _api.getDeadlines(),
        _api.getNotificationSummary(),
        _applicationService.getApplications(),
      ]);

      final notificationsResponse = results[0] as http.Response;
      final deadlinesResponse = results[1] as http.Response;
      final summaryResponse = results[2] as http.Response;
      final applicationsData = results[3] as List<Map<String, dynamic>>;

      if (notificationsResponse.statusCode == 200 &&
          deadlinesResponse.statusCode == 200 &&
          summaryResponse.statusCode == 200) {
        final notificationsData = jsonDecode(notificationsResponse.body) as List<dynamic>;
        final deadlinesData = jsonDecode(deadlinesResponse.body) as List<dynamic>;
        final summaryData = jsonDecode(summaryResponse.body) as Map<String, dynamic>;

        // Show all deadlines (don't filter based on completion status)
        List<DeadlineModel> allDeadlines = [];

        for (var deadlineJson in deadlinesData) {
          final deadline = _parseDeadlineFromJson(deadlineJson);
          if (deadline != null) {
            allDeadlines.add(deadline);
          }
        }

        setState(() {
          _notifications = notificationsData
              .map((json) => NotificationModel.fromJson(json))
              .toList();
          _deadlines = allDeadlines;
          _applications = applicationsData;
          _summary = NotificationSummary.fromJson(summaryData);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load data';
          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _error = 'Error loading data: $e';
        _loading = false;
      });
    }
  }

  DeadlineModel? _parseDeadlineFromJson(Map<String, dynamic> json) {
    try {
      DateTime deadline;
      String deadlineString = json['deadline']?.toString() ?? '';

      if (deadlineString.contains(' - ')) {
        List<String> parts = deadlineString.split(' - ');
        if (parts.length >= 2) {
          String endDateString = parts[1].trim();
          deadline = _parseFlexibleDate(endDateString);
        } else {
          deadline = _parseFlexibleDate(parts[0].trim());
        }
      } else {
        deadline = _parseFlexibleDate(deadlineString);
      }

      return DeadlineModel(
        applicationId: json['application_id']?.toString() ?? '',
        university: json['university']?.toString() ?? '',
        program: json['program']?.toString() ?? '',
        deadline: deadline,
        deadlineType: json['deadline_type']?.toString() ?? 'Application',
        daysUntil: json['days_until'] ?? _calculateDaysUntil(deadline),
        isUrgent: json['is_urgent'] ?? _calculateDaysUntil(deadline) <= 7,
        progressPercentage: double.tryParse(json['progress_percentage']?.toString() ?? '0') ?? 0.0,
      );
    } catch (e) {
      print('Error parsing deadline: $e');
      print('Raw deadline data: ${json['deadline']}');
      return null;
    }
  }

  DateTime _parseFlexibleDate(String dateString) {
    try {
      String cleanDate = dateString.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();

      List<DateFormat> formats = [
        DateFormat('MMM dd'),
        DateFormat('MMM d'),
        DateFormat('MMM dd, yyyy'),
        DateFormat('dd/MM/yyyy'),
        DateFormat('yyyy-MM-dd'),
        DateFormat('dd-MM-yyyy'),
      ];

      DateTime? parsedDate;
      for (DateFormat format in formats) {
        try {
          parsedDate = format.parse(cleanDate);

          if (format.pattern == 'MMM dd' || format.pattern == 'MMM d') {
            int currentYear = DateTime.now().year;
            parsedDate = DateTime(currentYear, parsedDate.month, parsedDate.day);

            if (parsedDate.isBefore(DateTime.now())) {
              parsedDate = DateTime(currentYear + 1, parsedDate.month, parsedDate.day);
            }
          }

          break;
        } catch (e) {
          continue;
        }
      }

      if (parsedDate != null) {
        return parsedDate;
      }

      RegExp dateRegex = RegExp(r'(\w+)\s+(\d+)');
      Match? match = dateRegex.firstMatch(cleanDate);

      if (match != null) {
        String monthStr = match.group(1)!;
        int day = int.parse(match.group(2)!);

        Map<String, int> months = {
          'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
          'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
          'January': 1, 'February': 2, 'March': 3, 'April': 4, 'May': 5, 'June': 6,
          'July': 7, 'August': 8, 'September': 9, 'October': 10, 'November': 11, 'December': 12
        };

        int? month = months[monthStr];
        if (month != null) {
          int currentYear = DateTime.now().year;
          DateTime result = DateTime(currentYear, month, day);

          if (result.isBefore(DateTime.now())) {
            result = DateTime(currentYear + 1, month, day);
          }

          return result;
        }
      }

      return DateTime.now().add(Duration(days: 30));

    } catch (e) {
      print('Error in _parseFlexibleDate: $e for input: $dateString');
      return DateTime.now().add(Duration(days: 30));
    }
  }

  int _calculateDaysUntil(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      final response = await _api.markNotificationAsRead(notification.id);
      if (response.statusCode == 200) {
        _loadData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking as read: $e')),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final response = await _api.markAllNotificationsAsRead();
      if (response.statusCode == 200) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications marked as read')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking all as read: $e')),
      );
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    try {
      final response = await _api.deleteNotification(notification.id);
      if (response.statusCode == 200) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting notification: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.surfaceColor(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary(context),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          // Mark all as read button
          if (_summary != null && _summary!.unreadCount > 0)
            IconButton(
              icon: Icon(
                Icons.done_all,
                color: AppColors.textPrimary(context),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Mark All as Read'),
                      content: Text('Mark all ${_summary!.unreadCount} notifications as read?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _markAllAsRead();
                          },
                          child: const Text('Mark All Read'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          IconButton(
            icon: Icon(
              _showUnreadOnly ? Icons.mark_email_read : Icons.mark_email_unread,
              color: AppColors.textPrimary(context),
            ),
            onPressed: () {
              setState(() {
                _showUnreadOnly = !_showUnreadOnly;
              });
              _loadData();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Notifications'),
                  if (_summary != null && _summary!.unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_summary!.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Deadlines'),
                  if (_deadlines.where((d) => d.isUrgent).isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_deadlines.where((d) => d.isUrgent).length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          labelColor: AppColors.primary(context),
          unselectedLabelColor: AppColors.textSecondary(context),
          indicatorColor: AppColors.primary(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: TextStyle(color: AppColors.textPrimary(context))),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsTab(),
          _buildDeadlinesTab(),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: AppColors.textSecondary(context),
            ),
            const SizedBox(height: 16),
            Text(
              _showUnreadOnly ? 'No Unread Notifications' : 'No Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _showUnreadOnly
                  ? 'All caught up! No unread notifications.'
                  : 'You\'ll see notifications here when they arrive.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildDeadlinesTab() {
    if (_deadlines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: AppColors.textSecondary(context),
            ),
            const SizedBox(height: 16),
            Text(
              'No Upcoming Deadlines',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All your application deadlines will appear here.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _deadlines.length,
        itemBuilder: (context, index) {
          final deadline = _deadlines[index];
          return _buildDeadlineCard(deadline);
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: notification.isRead
          ? AppColors.surfaceColor(context)
          : AppColors.primary(context).withOpacity(0.05),
      child: InkWell(
        onTap: () => _markAsRead(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getNotificationTypeColor(notification.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      notification.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getNotificationTypeColor(notification.type),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary(context),
                        shape: BoxShape.circle,
                      ),
                    ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 16,
                      color: AppColors.textSecondary(context),
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteNotification(notification);
                      } else if (value == 'mark_read' && !notification.isRead) {
                        _markAsRead(notification);
                      }
                    },
                    itemBuilder: (context) => [
                      if (!notification.isRead)
                        const PopupMenuItem(
                          value: 'mark_read',
                          child: Text('Mark as Read'),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                notification.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                notification.message,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  if (notification.universityTitle != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.school,
                      size: 14,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        notification.universityTitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeadlineCard(DeadlineModel deadline) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: deadline.isUrgent
          ? Colors.red.withOpacity(0.05)
          : AppColors.surfaceColor(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (deadline.isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: deadline.isUrgent
                        ? Colors.red.withOpacity(0.1)
                        : AppColors.primary(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${deadline.daysUntil} days left',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: deadline.isUrgent
                          ? Colors.red
                          : AppColors.primary(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              deadline.university,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              deadline.program,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.event,
                  size: 16,
                  color: deadline.isUrgent ? Colors.red : AppColors.primary(context),
                ),
                const SizedBox(width: 8),
                Text(
                  '${deadline.deadlineType}: ${_formatDate(deadline.deadline)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: deadline.isUrgent ? Colors.red : AppColors.primary(context),
                  ),
                ),
              ],
            ),
            if (deadline.progressPercentage > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    size: 16,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Application Progress: ${deadline.progressPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getNotificationTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'deadline':
        return Colors.red;
      case 'milestone':
        return Colors.green;
      case 'welcome':
        return Colors.blue;
      default:
        return AppColors.primary(context);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

// Updated DeadlineModel to include progress percentage
class DeadlineModel {
  final String applicationId;
  final String university;
  final String program;
  final DateTime deadline;
  final String deadlineType;
  final int daysUntil;
  final bool isUrgent;
  final double progressPercentage;

  DeadlineModel({
    required this.applicationId,
    required this.university,
    required this.program,
    required this.deadline,
    required this.deadlineType,
    required this.daysUntil,
    required this.isUrgent,
    this.progressPercentage = 0.0,
  });
}
