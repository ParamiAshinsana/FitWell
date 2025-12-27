import 'package:hive_flutter/hive_flutter.dart';
import 'reminder_model.dart';

class ReminderService {
  Future<Box<ReminderModel>> get _box async {
    if (Hive.isBoxOpen('reminderBox')) {
      return Hive.box<ReminderModel>('reminderBox');
    }
    return await Hive.openBox<ReminderModel>('reminderBox');
  }

  Future<List<ReminderModel>> getReminders() async {
    try {
      final box = await _box;
      final reminders = <ReminderModel>[];
      for (var key in box.keys) {
        try {
          final reminder = box.get(key) as ReminderModel?;
          if (reminder != null) {
            reminder.id = key.toString();
            reminders.add(reminder);
          }
        } catch (e) {
          // Skip invalid reminders and continue loading others
          print('Error loading reminder with key $key: $e');
          // Optionally delete the corrupted reminder
          try {
            await box.delete(key);
            print('Deleted corrupted reminder with key $key');
          } catch (deleteError) {
            print('Error deleting corrupted reminder: $deleteError');
          }
        }
      }
      return reminders;
    } catch (e) {
      print('Error getting reminders: $e');
      return [];
    }
  }

  Future<String> addReminder(ReminderModel reminder) async {
    try {
      final box = await _box;
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      reminder.id = id;
      await box.put(id, reminder);
      return id;
    } catch (e) {
      print('Error adding reminder: $e');
      rethrow;
    }
  }

  Future<void> updateReminder(String reminderId, ReminderModel reminder) async {
    try {
      final box = await _box;
      reminder.id = reminderId;
      await box.put(reminderId, reminder);
    } catch (e) {
      print('Error updating reminder: $e');
      rethrow;
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      final box = await _box;
      await box.delete(reminderId);
    } catch (e) {
      print('Error deleting reminder: $e');
      rethrow;
    }
  }
}

