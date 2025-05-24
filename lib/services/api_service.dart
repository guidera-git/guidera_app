import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const _baseUrl = 'http://192.168.1.3:3000/api';
  final _storage = const FlutterSecureStorage();

  // ───────────────────────────────────────────────────────────────────
  // Generic HTTP helpers

  Future<http.Response> post(String path, Map body, { bool auth = false }) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _storage.read(key: 'token');
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return http.post(Uri.parse('$_baseUrl$path'),
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
    return http.patch(Uri.parse('$_baseUrl$path'),
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
  // New: Multipart uploads for photos

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
      // optionally: contentType: MediaType('image', 'jpeg'),
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
      // optionally: contentType: MediaType('image', 'png'),
    ));
    final streamed = await request.send();
    return http.Response.fromStream(streamed);
  }
}
