import 'dart:convert';
import 'package:guidera_app/services/api_service.dart';
import 'package:guidera_app/models/saved_program.dart';

class SavedProgramsService {
  final ApiService _apiService = ApiService();

  Future<List<SavedProgramModel>> getSavedPrograms() async {
    try {
      final response = await _apiService.get('/saved-programs', auth: true);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SavedProgramModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load saved programs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading saved programs: $e');
    }
  }

  Future<bool> saveProgram(String programId, String universityId) async {
    try {
      final response = await _apiService.post('/saved-programs', {
        'program_id': programId,
        'university_id': universityId,
      }, auth: true);

      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to save program: $e');
    }
  }

  Future<bool> unsaveProgram(String savedId) async {
    try {
      final response = await _apiService.delete('/saved-programs/$savedId', auth: true);
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to unsave program: $e');
    }
  }

  Future<bool> isProgramSaved(String programId) async {
    try {
      final response = await _apiService.get('/saved-programs/check/$programId', auth: true);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_saved'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}