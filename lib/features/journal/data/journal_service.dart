import 'package:hive_flutter/hive_flutter.dart';
import 'journal_model.dart';

class JournalService {
  Future<Box> get _box async {
    if (Hive.isBoxOpen('journalBox')) {
      return Hive.box('journalBox');
    }
    return await Hive.openBox('journalBox');
  }

  Future<List<Journal>> getJournals() async {
    try {
      final box = await _box;
      final journals = box.values.toList();
      return journals.map((item) {
        final map = item as Map;
        return Journal.fromMap(map['id'] as String, {
          'date': map['date'],
          'description': map['description'],
        });
      }).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      print('Error getting journals: $e');
      return [];
    }
  }

  Future<String> addJournal(DateTime date, String description) async {
    try {
      final box = await _box;
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await box.put(id, {
        'id': id,
        'date': date.toIso8601String(),
        'description': description,
      });
      return id;
    } catch (e) {
      print('Error adding journal: $e');
      rethrow;
    }
  }

  Future<void> deleteJournal(String journalId) async {
    try {
      final box = await _box;
      await box.delete(journalId);
    } catch (e) {
      print('Error deleting journal: $e');
      rethrow;
    }
  }
}

