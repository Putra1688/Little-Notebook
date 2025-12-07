import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notebook.dart';
import '../models/idea.dart';

class NotebookRepository {
  static const String _notebooksKey = 'notebooks_data';

  // Simpan semua notebooks ke SharedPreferences
  static Future<void> saveNotebooks(List<Notebook> notebooks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert notebooks ke JSON format
      final List<Map<String, dynamic>> notebooksJson = notebooks.map((notebook) {
        return {
          'title': notebook.title,
          'ideas': notebook.ideas.map((idea) {
            return {
              'text': idea.text,
              'createdAt': idea.createdAt.toIso8601String(),
            };
          }).toList(),
        };
      }).toList();
      
      // Convert ke JSON string
      final String jsonString = jsonEncode(notebooksJson);
      
      // Simpan ke SharedPreferences
      await prefs.setString(_notebooksKey, jsonString);
      print('Notebooks saved successfully: ${notebooks.length} notebooks');
    } catch (e) {
      print('Error saving notebooks: $e');
    }
  }

  // Load semua notebooks dari SharedPreferences
  static Future<List<Notebook>> loadNotebooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_notebooksKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return []; // Return empty list jika tidak ada data
      }
      
      // Parse JSON string
      final List<dynamic> notebooksJson = jsonDecode(jsonString);
      
      // Convert kembali ke List<Notebook>
      final List<Notebook> notebooks = notebooksJson.map((notebookJson) {
        final List<dynamic> ideasJson = notebookJson['ideas'] ?? [];
        final List<Idea> ideas = ideasJson.map((ideaJson) {
          return Idea(
            text: ideaJson['text'] ?? '',
            createdAt: DateTime.parse(ideaJson['createdAt']),
          );
        }).toList();
        
        return Notebook(
          title: notebookJson['title'] ?? '',
          ideas: ideas,
        );
      }).toList();
      
      print('Notebooks loaded successfully: ${notebooks.length} notebooks');
      return notebooks;
    } catch (e) {
      print('Error loading notebooks: $e');
      return [];
    }
  }
}