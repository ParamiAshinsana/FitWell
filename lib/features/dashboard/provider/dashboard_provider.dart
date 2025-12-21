import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardProvider with ChangeNotifier {
  String? _userName;
  String? get userName => _userName;

  int _todayWaterIntake = 0;
  int get todayWaterIntake => _todayWaterIntake;
  static const int dailyWaterGoal = 2000; // ml
  double get waterProgress => _todayWaterIntake / dailyWaterGoal;
  int get waterRemaining => (dailyWaterGoal - _todayWaterIntake).clamp(0, dailyWaterGoal);

  List<Map<String, dynamic>> _weeklyCalories = [];
  List<Map<String, dynamic>> get weeklyCalories => _weeklyCalories;

  Map<String, dynamic>? _nextMedicine;
  Map<String, dynamic>? get nextMedicine => _nextMedicine;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DashboardProvider() {
    _loadUserEmail();
    // Listen to auth state changes to update name when user logs in
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _loadUserEmail();
    });
  }

  void _loadUserEmail() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user?.email != null) {
        final email = user!.email!;
        _userName = email.split('@').first;
      } else {
        _userName = 'User';
      }
      notifyListeners();
    } catch (e) {
      _userName = 'User';
      notifyListeners();
    }
  }

  void updateWaterIntake(int amount) {
    _todayWaterIntake = amount;
    notifyListeners();
  }

  void updateWeeklyCalories(List<Map<String, dynamic>> calories) {
    _weeklyCalories = calories;
    notifyListeners();
  }

  void updateNextMedicine(Map<String, dynamic>? medicine) {
    _nextMedicine = medicine;
    notifyListeners();
  }

  void refresh() {
    _loadUserEmail();
  }
}
