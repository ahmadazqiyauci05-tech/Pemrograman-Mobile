import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NoteService {
  static const _notesKey = 'student_notes';
  static const _darkModeKey = 'is_dark_mode';

  // --- CRUD Catatan ---

  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getStringList(_notesKey) ?? [];
    
    // Konversi List<String> JSON kembali menjadi List<Note>
    return notesString.map((s) => Note.fromJson(jsonDecode(s))).toList();
  }

  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Konversi List<Note> menjadi List<String> JSON
    final notesString = notes.map((note) => jsonEncode(note.toJson())).toList();
    await prefs.setStringList(_notesKey, notesString);
  }
  
  // --- Dark Mode Toggle ---
  
  Future<bool> loadDarkModeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false; // Default: Light Mode
  }

  Future<void> saveDarkModeStatus(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDarkMode);
  }
}