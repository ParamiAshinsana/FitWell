import 'package:flutter/material.dart';
import '../data/journal_model.dart';
import '../data/journal_service.dart';

class JournalProvider with ChangeNotifier {
  final JournalService _service = JournalService();
  List<Journal> _journals = [];
  bool _isLoading = false;

  List<Journal> get journals => _journals;
  bool get isLoading => _isLoading;

  Future<void> loadJournals() async {
    _isLoading = true;
    notifyListeners();
    try {
      _journals = await _service.getJournals();
    } catch (e) {
      print('Error loading journals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addJournal(DateTime date, String description) async {
    try {
      if (description.trim().isEmpty) {
        return false;
      }
      await _service.addJournal(date, description.trim());
      await loadJournals();
      return true;
    } catch (e) {
      print('Error adding journal: $e');
      return false;
    }
  }

  Future<bool> deleteJournal(String journalId) async {
    try {
      await _service.deleteJournal(journalId);
      await loadJournals();
      return true;
    } catch (e) {
      print('Error deleting journal: $e');
      return false;
    }
  }
}

