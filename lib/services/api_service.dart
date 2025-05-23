import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const _baseUrl = 'http://192.168.1.108:3000/api';
  final _storage = const FlutterSecureStorage();

  // Existing POST
  Future<http.Response> post(String path, Map body, { bool auth = false }) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _storage.read(key: 'token');
      headers['Authorization'] = 'Bearer $token';
    }
    return http.post(Uri.parse('$_baseUrl$path'),
        headers: headers, body: jsonEncode(body));
  }

  // Existing GET
  Future<http.Response> get(String path, { bool auth = false }) async {
    final headers = <String, String>{};
    if (auth) {
      final token = await _storage.read(key: 'token');
      headers['Authorization'] = 'Bearer $token';
    }
    return http.get(Uri.parse('$_baseUrl$path'), headers: headers);
  }

  // ───────────────────────────────────────────────────────────────────
  // New PATCH helper
  Future<http.Response> patch(String path, Map body, { bool auth = false }) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _storage.read(key: 'token');
      headers['Authorization'] = 'Bearer $token';
    }
    return http.patch(Uri.parse('$_baseUrl$path'),
        headers: headers, body: jsonEncode(body));
  }

  // New DELETE helper
  Future<http.Response> delete(String path, { bool auth = false }) async {
    final headers = <String, String>{};
    if (auth) {
      final token = await _storage.read(key: 'token');
      headers['Authorization'] = 'Bearer $token';
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
}
