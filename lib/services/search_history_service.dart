import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const String _historyKey = 'search_history';
  static const int _maxHistoryItems = 10;
  static const int _minSearchLength = 3; // FIXED: Only meaningful searches

  // FIXED: Add search term only if meaningful (3+ characters)
  static Future<void> addSearchTerm(String searchTerm) async {
    final trimmed = searchTerm.trim();

    // FIXED: Only add meaningful search terms
    if (trimmed.isEmpty || trimmed.length < _minSearchLength) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> history = await getSearchHistory();

    // Remove if already exists to avoid duplicates
    history.remove(trimmed);

    // Add to beginning
    history.insert(0, trimmed);

    // Keep only the latest items
    if (history.length > _maxHistoryItems) {
      history = history.take(_maxHistoryItems).toList();
    }

    await prefs.setStringList(_historyKey, history);
  }

  // Get search history
  static Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [];
  }

  // Clear search history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // Remove specific item from history
  static Future<void> removeFromHistory(String searchTerm) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = await getSearchHistory();
    history.remove(searchTerm);
    await prefs.setStringList(_historyKey, history);
  }

  // FIXED: Check if search term is meaningful
  static bool isMeaningfulSearch(String searchTerm) {
    return searchTerm.trim().length >= _minSearchLength;
  }
}