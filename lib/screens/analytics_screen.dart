import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/widgets/header.dart';
import 'package:guidera_app/services/application_service.dart';
import 'package:guidera_app/services/api_service.dart';
import 'package:guidera_app/screens/applications_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final ApplicationService _applicationService = ApplicationService();
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? _analytics;
  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      // Load applications analytics and user applications
      final analyticsResponse = await _apiService.getApplicationsAnalytics();
      final applicationsResponse = await _applicationService.getApplications();

      if (analyticsResponse.statusCode == 200) {
        final analyticsData = jsonDecode(analyticsResponse.body);
        setState(() {
          _analytics = analyticsData;
          _applications = applicationsResponse;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load analytics');
      }
    } catch (e) {
      print('Error loading analytics: $e');
      // Use local analytics calculation as fallback
      final applications = await _applicationService.getApplications();
      final analytics = _calculateLocalAnalytics(applications);
      setState(() {
        _analytics = analytics;
        _applications = applications;
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _calculateLocalAnalytics(List<Map<String, dynamic>> applications) {
    int totalApps = applications.length;
    int completedApps = 0;
    int inProgressApps = 0;
    double totalProgress = 0.0;

    for (var app in applications) {
      final progress = double.tryParse(app['progress_percentage']?.toString() ?? '0') ?? 0.0;
      final status = app['status']?.toString().toLowerCase() ?? '';

      totalProgress += progress;

      if (progress >= 100.0 || status == 'completed') {
        completedApps++;
      } else if (progress > 0 || status == 'in_progress' || status == 'submitted') {
        inProgressApps++;
      }
    }

    double avgProgress = totalApps > 0 ? totalProgress / totalApps : 0.0;

    return {
      'summary': {
        'total_applications': totalApps,
        'completed_applications': completedApps,
        'in_progress_applications': inProgressApps,
        'average_progress': avgProgress,
        'recent_applications': totalApps,
      }
    };
  }

  Future<void> _editApplication(Map<String, dynamic> application) async {
    // Navigate to application screen for editing
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicationScreen(
          application: application,
        ),
      ),
    ).then((_) {
      // Refresh data when returning from edit screen
      _loadAnalytics();
    });
  }

  Future<void> _deleteApplication(Map<String, dynamic> application) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceColor(context),
        title: Text(
          'Delete Application',
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        content: Text(
          'Are you sure you want to delete this application? This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary(context))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await _applicationService.deleteApplication(application['id'].toString());
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Application deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadAnalytics(); // Refresh data
        } else {
          throw Exception('Failed to delete application');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting application: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadAnalytics,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Application Analytics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                  fontFamily: 'Product Sans',
                ),
              ),
              const SizedBox(height: 20),

              // Overview Cards
              _buildOverviewCards(),
              const SizedBox(height: 24),

              // Progress Chart
              _buildProgressChart(),
              const SizedBox(height: 24),

              // Active Applications
              _buildActiveApplications(),
              const SizedBox(height: 24),

              // Status Distribution
              _buildStatusDistribution(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    if (_analytics == null) {
      return const SizedBox.shrink();
    }

    // Use actual analytics data with proper application status counting
    int totalApps = 0;
    int completedApps = 0;
    int inProgressApps = 0;
    double totalProgress = 0.0;

    for (var app in _applications) {
      totalApps++;
      final progress = double.tryParse(app['progress_percentage']?.toString() ?? '0') ?? 0.0;
      final status = app['status']?.toString().toLowerCase() ?? '';

      totalProgress += progress;

      if (progress >= 100.0 || status == 'completed') {
        completedApps++;
      } else if (progress > 0 || status == 'in_progress' || status == 'submitted') {
        inProgressApps++;
      }
    }

    double avgProgress = totalApps > 0 ? totalProgress / totalApps : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                'Total Applications',
                totalApps.toString(),
                Icons.assignment,
                AppColors.lightBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                'Completed',
                completedApps.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                'In Progress',
                inProgressApps.toString(),
                Icons.pending,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                'Avg Progress',
                '${avgProgress.toStringAsFixed(1)}%',
                Icons.trending_up,
                AppColors.darkBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                  fontFamily: 'Product Sans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(context),
              fontFamily: 'Product Sans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    if (_applications.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No applications to show progress',
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontFamily: 'Product Sans',
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
              fontFamily: 'Product Sans',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < _applications.length) {
                          final app = _applications[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              (app['university_title']?.toString() ?? 'App ${value.toInt() + 1}')
                                  .substring(0, 8),
                              style: TextStyle(
                                color: AppColors.textSecondary(context),
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _applications.asMap().entries.map((entry) {
                  final progress = double.tryParse(
                      entry.value['progress_percentage']?.toString() ?? '0') ?? 0.0;
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: progress,
                        color: _getProgressColor(progress.toInt()),
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(int progress) {
    if (progress >= 80) return Colors.green;
    if (progress >= 50) return Colors.orange;
    return Colors.red;
  }

  Widget _buildActiveApplications() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Active Applications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
              fontFamily: 'Product Sans',
            ),
          ),
          const SizedBox(height: 16),
          if (_applications.isEmpty)
            Center(
              child: Text(
                'No applications yet',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontFamily: 'Product Sans',
                ),
              ),
            )
          else
            ..._applications.map((app) => _buildApplicationTile(app)),
        ],
      ),
    );
  }

  Widget _buildApplicationTile(Map<String, dynamic> app) {
    final progress = double.tryParse(app['progress_percentage']?.toString() ?? '0') ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderColor(context),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: _getProgressColor(progress.toInt()),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app['university_title']?.toString() ?? 'Unknown University',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                    fontFamily: 'Product Sans',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  app['program_title']?.toString() ?? 'Unknown Program',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary(context),
                    fontFamily: 'Product Sans',
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${progress.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getProgressColor(progress.toInt()),
              fontFamily: 'Product Sans',
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: AppColors.textSecondary(context),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                _editApplication(app);
              } else if (value == 'delete') {
                _deleteApplication(app);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: AppColors.textPrimary(context)),
                    const SizedBox(width: 8),
                    Text(
                      'Edit',
                      style: TextStyle(color: AppColors.textPrimary(context)),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDistribution() {
    if (_applications.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate status distribution properly
    final statusCounts = <String, int>{};
    for (final app in _applications) {
      final progress = double.tryParse(app['progress_percentage']?.toString() ?? '0') ?? 0.0;
      final status = app['status']?.toString().toLowerCase() ?? '';

      String displayStatus;
      if (progress >= 100.0 || status == 'completed') {
        displayStatus = 'completed';
      } else if (progress > 0 || status == 'in_progress' || status == 'submitted') {
        displayStatus = 'in_progress';
      } else {
        displayStatus = 'started';
      }

      statusCounts[displayStatus] = (statusCounts[displayStatus] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
              fontFamily: 'Product Sans',
            ),
          ),
          const SizedBox(height: 16),
          ...statusCounts.entries.map((entry) => _buildStatusItem(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String status, int count) {
    final total = _applications.length;
    final percentage = (count / total * 100).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary(context),
                fontFamily: 'Product Sans',
              ),
            ),
          ),
          Text(
            '$count ($percentage%)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
              fontFamily: 'Product Sans',
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'started':
        return AppColors.lightBlue;
      default:
        return AppColors.textSecondary(context);
    }
  }
}