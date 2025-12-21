import 'package:flutter/material.dart';
import '../data/workout_service.dart';
import '../data/workout_model.dart';

class WorkoutProvider with ChangeNotifier {
  final WorkoutService _workoutService = WorkoutService();

  List<Workout> _workouts = [];
  List<Workout> get workouts => _workouts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  WorkoutProvider() {
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _workouts = await _workoutService.getWorkouts();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addWorkout(Workout workout) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final id = await _workoutService.addWorkout(workout);
      await _loadWorkouts();

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

  Future<bool> updateWorkout(String workoutId, Workout workout) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _workoutService.updateWorkout(workoutId, workout);
      await _loadWorkouts();

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

  Future<bool> deleteWorkout(String workoutId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _workoutService.deleteWorkout(workoutId);
      await _loadWorkouts();

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
    _loadWorkouts();
  }
}

