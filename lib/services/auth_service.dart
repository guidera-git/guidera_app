import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final _apiService = ApiService();
  final _firebaseAuth = FirebaseAuth.instance;

  // FIXED: Use serverClientId for Android instead of clientId
  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Use serverClientId instead of clientId for Android
    serverClientId: '558758078608-7elqqv90534omkqskhpf538381bhs857.apps.googleusercontent.com',
  );

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null && token.isNotEmpty;
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userData = await _storage.read(key: 'user_data');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Store user data
  Future<void> _storeUserData(String token, Map<String, dynamic> userData) async {
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'user_data', value: jsonEncode(userData));
  }

  // Regular login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _storeUserData(data['token'], data['user']);
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Login failed'};
      }
    } catch (error) {
      return {'success': false, 'error': 'Network error: $error'};
    }
  }

  // FIXED: Enhanced Google Sign-In with better error handling
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Ensure we start fresh
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();

      // Add a small delay to ensure cleanup
      await Future.delayed(const Duration(milliseconds: 500));

      print('Starting Google Sign-In process...');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Google Sign-In cancelled by user');
        return {'success': false, 'error': 'Google sign-in cancelled'};
      }

      print('Google user obtained: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        print('Failed to get Google ID token');
        return {'success': false, 'error': 'Failed to get Google ID token'};
      }

      print('Google ID token obtained');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Firebase credential created');

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      print('Firebase sign-in successful');

      // Get the ID token for backend
      final String? idToken = await userCredential.user?.getIdToken(true); // Force refresh
      if (idToken == null) {
        print('Failed to get Firebase ID token');
        return {'success': false, 'error': 'Failed to get Firebase ID token'};
      }

      print('Sending ID token to backend...');

      // Send to backend
      final response = await _apiService.googleSignIn(idToken);
      final data = jsonDecode(response.body);

      print('Backend response: ${response.statusCode}');

      if (response.statusCode == 200 && data['success'] == true) {
        await _storeUserData(data['token'], data['user']);
        print('Google Sign-In successful');
        return {'success': true, 'user': data['user']};
      } else {
        print('Backend error: ${data['error']}');
        return {'success': false, 'error': data['error'] ?? 'Google sign-in failed'};
      }
    } catch (error) {
      print('Google Sign-In Error Details: $error');

      // More specific error handling
      if (error.toString().contains('PlatformException')) {
        if (error.toString().contains('sign_in_failed')) {
          return {'success': false, 'error': 'Google sign-in failed. Please check your Google Play Services and try again.'};
        } else if (error.toString().contains('network_error')) {
          return {'success': false, 'error': 'Network error. Please check your internet connection.'};
        } else if (error.toString().contains('sign_in_canceled')) {
          return {'success': false, 'error': 'Sign-in cancelled'};
        }
      }

      return {'success': false, 'error': 'Google sign-in error. Please try again later.'};
    }
  }

  // Send OTP
  Future<Map<String, dynamic>> sendOTP(String email) async {
    try {
      final response = await _apiService.sendOTP(email);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to send OTP'};
      }
    } catch (error) {
      return {'success': false, 'error': 'Network error: $error'};
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    try {
      final response = await _apiService.verifyOTP(email, otp);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _storeUserData(data['token'], data['user']);
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Invalid OTP'};
      }
    } catch (error) {
      return {'success': false, 'error': 'Network error: $error'};
    }
  }

  // Enhanced forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _apiService.forgotPassword(email);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to send reset email'};
      }
    } catch (error) {
      return {'success': false, 'error': 'Network error: $error'};
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String token, String password) async {
    try {
      final response = await _apiService.resetPassword(token, password);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Password reset failed'};
      }
    } catch (error) {
      return {'success': false, 'error': 'Network error: $error'};
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error signing out from Google/Firebase: $e');
    }

    await _storage.delete(key: 'token');
    await _storage.delete(key: 'user_data');
  }
}
