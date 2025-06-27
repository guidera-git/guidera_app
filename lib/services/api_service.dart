import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const _baseUrl = 'http://192.168.1.77:3000/api';
  final _storage = const FlutterSecureStorage();

  // ───────────────────────────────────────────────────────────────────
  // Generic HTTP helpers

  Future<http.Response> post(String path, Map body, { bool auth = false }) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _storage.read(key: 'token');
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return http.post(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String path, { bool auth = false }) async {
    final headers = <String, String>{};
    if (auth) {
      final token = await _storage.read(key: 'token');
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return http.get(Uri.parse('$_baseUrl$path'), headers: headers);
  }

  Future<http.Response> patch(String path, Map body, { bool auth = false }) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _storage.read(key: 'token');
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return http.patch(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String path, { bool auth = false }) async {
    final headers = <String, String>{};
    if (auth) {
      final token = await _storage.read(key: 'token');
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return http.delete(Uri.parse('$_baseUrl$path'), headers: headers);
  }

  // ───────────────────────────────────────────────────────────────────
  // Profile-specific methods

  /// Fetch current user's profile
  Future<http.Response> getProfile() {
    return get('/user/profile', auth: true);
  }

  /// Update one or more profile fields.
  /// body can contain any of:
  ///   fullName, profilePhoto, backgroundPhoto, gender, birthdate, aboutMe
  Future<http.Response> updateProfile(Map body) {
    return patch('/user/profile', body, auth: true);
  }

  /// Remove the profile photo only
  Future<http.Response> deleteProfilePhoto() {
    return delete('/user/profile/photo', auth: true);
  }

  /// Remove the background photo only
  Future<http.Response> deleteBackgroundPhoto() {
    return delete('/user/profile/background-photo', auth: true);
  }

  // ───────────────────────────────────────────────────────────────────
  // Multipart uploads for photos

  /// Upload a new profile photo via multipart/form-data
  Future<http.Response> uploadProfilePhoto(File file) async {
    final uri = Uri.parse('$_baseUrl/user/profile/photo');
    final request = http.MultipartRequest('PATCH', uri);
    final token = await _storage.read(key: 'token');
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath(
      'profilephoto',
      file.path,
    ));
    final streamed = await request.send();
    return http.Response.fromStream(streamed);
  }

  /// Upload a new background photo via multipart/form-data
  Future<http.Response> uploadBackgroundPhoto(File file) async {
    final uri = Uri.parse('$_baseUrl/user/profile/background');
    final request = http.MultipartRequest('PATCH', uri);
    final token = await _storage.read(key: 'token');
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath(
      'backgroundphoto',
      file.path,
    ));
    final streamed = await request.send();
    return http.Response.fromStream(streamed);
  }

  //───────────────────────────────────────────────────────────────────
  // Degree recommendation

  /// Call degree recommendation endpoint
  Future<http.Response> predictDegree(Map<String, dynamic> body) {
    return post(
      '/degree/predict',
      body,
      auth: true,
    );
  }

  // ───────────────────────────────────────────────────────────────────
  // Chatbot message

  /// Sends a user message to the chatbot endpoint and returns the assistant's reply
  Future<String> sendMessage(String message) async {
    final response = await post(
      '/chatbot',
      {'message': message},
      auth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['reply'] as String;
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }

  // ───────────────────────────────────────────────────────────────────
  // Test-specific methods

  /// Start a new test attempt and fetch random questions for a subject
  /// Returns the response containing attemptId, startedAt, and questions list
  Future<http.Response> startTest(String subject) async {
    return get(
      '/tests/$subject',
      auth: true,
    );
  }

  /// Submit answers for a test attempt
  /// [answers] should be a Map<QuestionId, SelectedOption>
  Future<http.Response> submitTest(
      String attemptId,
      Map<String, String> answers,
      ) async {
    return post(
      '/tests/$attemptId/submit',
      {'answers': answers},
      auth: true,
    );
  }

  /// Retrieve test results including explanations and user's answers
  Future<http.Response> getTestResult(String attemptId) async {
    return get(
      '/tests/$attemptId/result',
      auth: true,
    );
  }

  // ───────────────────────────────────────────────────────────────────
  // University & Program APIs

  /// Fetch all programs with their university info
  Future<http.Response> getAllPrograms() async {
    return get('/programs', auth: true);
  }

  /// Fetch all universities with program counts
  Future<http.Response> getAllUniversities() async {
    return get('/universities', auth: true);
  }

  /// Fuzzy search universities by name
  Future<http.Response> searchUniversities(String name) async {
    return get('/universities/search/$name', auth: true);
  }

  /// Fetch all programs for a specific university
  Future<http.Response> getUniversityPrograms(String universityId) async {
    return get('/programs/byUniversity/$universityId', auth: true);
  }

  /// Fuzzy search programs by title
  Future<http.Response> searchPrograms(String programTitle) async {
    return get('/programs/search/$programTitle', auth: true);
  }

  /// Get detailed program and its university info by program ID
  Future<http.Response> getProgramDetails(String programId) async {
    return get('/programs/specific/$programId', auth: true);
  }

  /// Filter programs across universities with optional parameters
  Future<http.Response> filterPrograms({
    String? location,
    String? universityTitle,
    String? programTitle,
    String? standardizedTitle,
    int? qsRanking,
    int? minTotalFee,
    int? maxTotalFee,
  }) async {
    final params = <String, String>{};
    if (location != null) params['location'] = location;
    if (universityTitle != null) params['university_title'] = universityTitle;
    if (programTitle != null) params['program_title'] = programTitle;
    if (standardizedTitle != null) params['standardized_title'] = standardizedTitle;
    if (qsRanking != null) params['qs_ranking'] = qsRanking.toString();
    if (minTotalFee != null) params['min_total_fee'] = minTotalFee.toString();
    if (maxTotalFee != null) params['max_total_fee'] = maxTotalFee.toString();

    final uri = Uri.parse('$_baseUrl/programs/filter').replace(queryParameters: params);
    final headers = <String, String>{};
    final token = await _storage.read(key: 'token');
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return http.get(uri, headers: headers);
  }

  /// Get unique locations from database
  Future<List<String>> getLocations() async {
    try {
      final response = await get('/locations', auth: true);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((location) => location.toString()).toList();
      }
    } catch (e) {
      print('Error fetching locations: $e');
    }
    return [];
  }

  /// Get unique university names from database
  Future<List<String>> getUniversityNames() async {
    try {
      final response = await get('/university-names', auth: true);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((name) => name.toString()).toList();
      }
    } catch (e) {
      print('Error fetching university names: $e');
    }
    return [];
  }

  /// Get unique program names from database
  Future<List<String>> getProgramNames() async {
    try {
      final response = await get('/program-names', auth: true);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((name) => name.toString()).toList();
      }
    } catch (e) {
      print('Error fetching program names: $e');
    }
    return [];
  }


  // ───────────────────────────────────────────────────────────────────
  // Saved Programs APIs

  /// Save a program
  Future<http.Response> saveProgram(String programId, String universityId) async {
    return post('/saved-programs', {
      'program_id': programId,
      'university_id': universityId,
    }, auth: true);
  }

  /// Get all saved programs
  Future<http.Response> getSavedPrograms() async {
    return get('/saved-programs', auth: true);
  }

  /// Unsave a program by saved_id
  Future<http.Response> unsaveProgram(String savedId) async {
    return delete('/saved-programs/$savedId', auth: true);
  }

  /// Check if program is saved
  Future<http.Response> checkProgramSaved(String programId) async {
    return get('/saved-programs/check/$programId', auth: true);
  }


// ───────────────────────────────────────────────────────────────────
  // APPLICATION APIs

  /// Start a new application
  Future<http.Response> startApplication({
    required String programId,
    required String universityId,
  }) async {
    return post('/applications', {
      'program_id': programId,
      'university_id': universityId,
    }, auth: true);
  }

  /// Get all applications for the current user
  Future<http.Response> getApplications() async {
    return get('/applications', auth: true);
  }

  /// Get specific application details
  Future<http.Response> getApplication(String applicationId) async {
    return get('/applications/$applicationId', auth: true);
  }

  /// Check application status for a specific program and university
  Future<http.Response> checkApplicationStatus({
    required String programId,
    required String universityId,
  }) async {
    return get('/applications/check/$programId/$universityId', auth: true);
  }

  /// Update application phase
  Future<http.Response> updateApplicationPhase({
    required String applicationId,
    required String phase,
    required bool completed,
    String? note,
  }) async {
    final body = {
      'phase': phase,
      'completed': completed,
    };
    if (note != null) body['note'] = note;

    return patch('/applications/$applicationId/phase', body, auth: true);
  }

  /// Delete application
  Future<http.Response> deleteApplication(String applicationId) async {
    return delete('/applications/$applicationId', auth: true);
  }


  // ───────────────────────────────────────────────────────────────────
  // NOTIFICATION APIs

  /// Create a manual notification
  Future<http.Response> createNotification({
    required String title,
    required String message,
    required String type,
    String? relatedId,
    DateTime? scheduledFor,
  }) async {
    final body = {
      'title': title,
      'message': message,
      'type': type,
    };
    if (relatedId != null) body['related_id'] = relatedId;
    if (scheduledFor != null) body['scheduled_for'] = scheduledFor.toIso8601String();

    return post('/notifications', body, auth: true);
  }

  /// Get all notifications for the current user
  Future<http.Response> getNotifications({
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
      'unread_only': unreadOnly.toString(),
    };

    final uri = Uri.parse('$_baseUrl/notifications').replace(queryParameters: params);
    final headers = <String, String>{};
    final token = await _storage.read(key: 'token');
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return http.get(uri, headers: headers);
  }

  /// Mark notification as read
  Future<http.Response> markNotificationAsRead(String notificationId) async {
    return patch('/notifications/$notificationId/read', {}, auth: true);
  }

  /// Mark all notifications as read
  Future<http.Response> markAllNotificationsAsRead() async {
    return patch('/notifications/mark-all-read', {}, auth: true);
  }

  /// Get notification summary
  Future<http.Response> getNotificationSummary() async {
    return get('/notifications/summary', auth: true);
  }

  /// Get deadline notifications
  Future<http.Response> getDeadlines() async {
    return get('/deadlines', auth: true);
  }

  /// Delete notification
  Future<http.Response> deleteNotification(String notificationId) async {
    return delete('/notifications/$notificationId', auth: true);
  }


  // ───────────────────────────────────────────────────────────────────
  // ANALYTICS APIs

  /// Get applications analytics summary
  Future<http.Response> getApplicationsAnalytics({int period = 30}) async {
    final params = {'period': period.toString()};
    final uri = Uri.parse('$_baseUrl/analytics/applications/summary')
        .replace(queryParameters: params);
    final headers = <String, String>{};
    final token = await _storage.read(key: 'token');
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return http.get(uri, headers: headers);
  }

  /// Get notifications analytics summary
  Future<http.Response> getNotificationsAnalytics({int period = 30}) async {
    final params = {'period': period.toString()};
    final uri = Uri.parse('$_baseUrl/analytics/notifications/summary')
        .replace(queryParameters: params);
    final headers = <String, String>{};
    final token = await _storage.read(key: 'token');
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return http.get(uri, headers: headers);
  }

  /// Get system analytics summary
  Future<http.Response> getSystemAnalytics({int period = 30}) async {
    final params = {'period': period.toString()};
    final uri = Uri.parse('$_baseUrl/analytics/system/summary')
        .replace(queryParameters: params);
    final headers = <String, String>{};
    final token = await _storage.read(key: 'token');
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return http.get(uri, headers: headers);
  }

  /// Log custom analytics event
  Future<http.Response> logAnalyticsEvent({
    required String eventType,
    Map<String, dynamic>? eventData,
  }) async {
    return post('/analytics/event', {
      'event_type': eventType,
      'event_data': eventData ?? {},
    }, auth: true);
  }

  /// Get raw analytics events
  Future<http.Response> getAnalyticsEvents({
    int limit = 100,
    int offset = 0,
    String? eventTypeFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (eventTypeFilter != null) params['event_type_filter'] = eventTypeFilter;
    if (startDate != null) params['start_date'] = startDate.toIso8601String();
    if (endDate != null) params['end_date'] = endDate.toIso8601String();

    final uri = Uri.parse('$_baseUrl/analytics/events').replace(queryParameters: params);
    final headers = <String, String>{};
    final token = await _storage.read(key: 'token');
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return http.get(uri, headers: headers);
  }
}