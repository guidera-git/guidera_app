import 'dart:convert';
import 'package:guidera_app/services/api_service.dart';

class ApplicationService {
  final ApiService _apiService = ApiService();

  // Get all user applications
  Future<List<Map<String, dynamic>>> getApplications() async {
    try {
      final response = await _apiService.getApplications();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load applications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching applications: $e');
      return [];
    }
  }

  // Get specific application details with status and deadlines
  Future<Map<String, dynamic>?> getApplicationWithStatus(String applicationId) async {
    try {
      final response = await _apiService.get('/applications/$applicationId/status', auth: true);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load application: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching application details: $e');
      return null;
    }
  }

  // Get specific application details with phases
  Future<Map<String, dynamic>?> getApplication(String applicationId) async {
    try {
      final response = await _apiService.getApplication(applicationId);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load application: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching application details: $e');
      return null;
    }
  }

  // Check if user can apply (deadline validation)
  Future<Map<String, dynamic>?> checkApplicationDeadline(String programId, String universityId) async {
    try {
      final response = await _apiService.get('/programs/$programId/$universityId/deadline-check', auth: true);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to check deadline: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking deadline: $e');
      return null;
    }
  }

  // Start a new application with deadline validation
  Future<bool> startApplication(String programId, String universityId) async {
    try {
      final response = await _apiService.startApplication(
        programId: programId,
        universityId: universityId,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to start application');
      }
    } catch (e) {
      print('Error starting application: $e');
      throw e;
    }
  }

  // Update application stage status with smart deadline management
  Future<bool> updateApplicationStage(
      String applicationId,
      String stage,
      bool completed,
      {String? note}
      ) async {
    try {
      final response = await _apiService.patch('/applications/$applicationId/stage', {
        'stage': stage,
        'completed': completed,
        if (note != null) 'note': note,
      }, auth: true);

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to update stage');
      }
    } catch (e) {
      print('Error updating application stage: $e');
      throw e;
    }
  }

  // Update application phase status (legacy support)
  Future<bool> updateApplicationPhase(
      String applicationId,
      String phase,
      bool completed,
      {String? note}
      ) async {
    try {
      final response = await _apiService.updateApplicationPhase(
        applicationId: applicationId,
        phase: phase,
        completed: completed,
        note: note,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to update phase');
      }
    } catch (e) {
      print('Error updating application phase: $e');
      throw e;
    }
  }

  // Update application status
  Future<bool> updateApplicationStatus(String applicationId, String status) async {
    try {
      // This would need to be implemented in your API service
      // For now, we'll return true as a placeholder
      return true;
    } catch (e) {
      print('Error updating application status: $e');
      return false;
    }
  }

  // Calculate application progress based on completed phases
  Future<double> calculateApplicationProgress(String applicationId) async {
    try {
      final application = await getApplication(applicationId);
      if (application != null && application['phases'] != null) {
        final List<dynamic> phases = application['phases'];
        if (phases.isEmpty) return 0.0;

        int completedCount = phases.where((phase) => phase['completed'] == true).length;
        return completedCount / phases.length;
      }
      return 0.0;
    } catch (e) {
      print('Error calculating progress: $e');
      return 0.0;
    }
  }

  // Get applications by status
  Future<List<Map<String, dynamic>>> getApplicationsByStatus(String status) async {
    try {
      final applications = await getApplications();
      return applications.where((app) =>
      app['status']?.toString().toLowerCase() == status.toLowerCase()).toList();
    } catch (e) {
      print('Error filtering applications by status: $e');
      return [];
    }
  }

  // Delete application
  Future<bool> deleteApplication(String applicationId) async {
    try {
      final response = await _apiService.deleteApplication(applicationId);
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to delete application');
      }
    } catch (e) {
      print('Error deleting application: $e');
      throw e;
    }
  }

  // Get application analytics
  Future<Map<String, dynamic>> getApplicationAnalytics() async {
    try {
      final applications = await getApplications();

      final totalApps = applications.length;
      final completedApps = applications.where((app) =>
      app['status']?.toLowerCase() == 'completed').length;
      final inProgressApps = applications.where((app) =>
      app['status']?.toLowerCase() == 'in_progress' ||
          app['status']?.toLowerCase() == 'submitted').length;
      final startedApps = applications.where((app) =>
      app['status']?.toLowerCase() == 'started').length;

      // Calculate average progress
      double avgProgress = 0.0;
      if (applications.isNotEmpty) {
        final totalProgress = applications.fold<double>(0.0, (sum, app) {
          return sum + (double.tryParse(app['progress_percentage']?.toString() ?? '0') ?? 0.0);
        });
        avgProgress = totalProgress / applications.length;
      }

      return {
        'total_applications': totalApps,
        'completed_applications': completedApps,
        'in_progress_applications': inProgressApps,
        'started_applications': startedApps,
        'average_progress': avgProgress,
        'completion_rate': totalApps > 0 ? (completedApps / totalApps * 100) : 0.0,
      };
    } catch (e) {
      print('Error getting application analytics: $e');
      return {
        'total_applications': 0,
        'completed_applications': 0,
        'in_progress_applications': 0,
        'started_applications': 0,
        'average_progress': 0.0,
        'completion_rate': 0.0,
      };
    }
  }
}