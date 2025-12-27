import 'package:flutter/material.dart';
import '../data/reminder_service.dart';
import '../data/reminder_model.dart';

class ReminderProvider with ChangeNotifier {
  final ReminderService _reminderService = ReminderService();

  List<ReminderModel> _reminders = [];
  List<ReminderModel> get reminders => _reminders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ReminderProvider() {
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _reminders = await _reminderService.getReminders();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addReminder(ReminderModel reminder) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final id = await _reminderService.addReminder(reminder);
      await _loadReminders();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateReminder(String reminderId, ReminderModel reminder) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _reminderService.updateReminder(reminderId, reminder);
      await _loadReminders();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReminder(String reminderId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _reminderService.deleteReminder(reminderId);
      await _loadReminders();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void refresh() {
    _loadReminders();
  }
}

