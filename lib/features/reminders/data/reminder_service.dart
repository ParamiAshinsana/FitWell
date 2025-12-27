import 'package:hive_flutter/hive_flutter.dart';
import 'reminder_model.dart';

class ReminderService {
  Box<ReminderModel> get _box => Hive.box<ReminderModel>('reminderBox');

  Future<List<ReminderModel>> getReminders() async {
    final reminders = <ReminderModel>[];
    for (var key in _box.keys) {
      final reminder = _box.get(key) as ReminderModel?;
      if (reminder != null) {
        reminder.id = key.toString();
        reminders.add(reminder);
      }
    }
    return reminders;
  }

  Future<String> addReminder(ReminderModel reminder) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    reminder.id = id;
    await _box.put(id, reminder);
    return id;
  }

  Future<void> updateReminder(String reminderId, ReminderModel reminder) async {
    reminder.id = reminderId;
    await _box.put(reminderId, reminder);
  }

  Future<void> deleteReminder(String reminderId) async {
    await _box.delete(reminderId);
  }
}

