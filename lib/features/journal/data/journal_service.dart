import 'package:hive_flutter/hive_flutter.dart';
import 'journal_model.dart';

class JournalService {
  Box get _box => Hive.box('journalBox');

  Future<List<Journal>> getJournals() async {
    final journals = _box.values.toList();
    return journals.map((item) {
      final map = item as Map;
      return Journal.fromMap(map['id'] as String, {
        'date': map['date'],
        'description': map['description'],
      });
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<String> addJournal(DateTime date, String description) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _box.put(id, {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
    });
    return id;
  }

  Future<void> deleteJournal(String journalId) async {
    await _box.delete(journalId);
  }
}

