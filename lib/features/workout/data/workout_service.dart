import 'package:hive_flutter/hive_flutter.dart';
import 'workout_model.dart';

class WorkoutService {
  Future<Box> get _box async {
    if (Hive.isBoxOpen('workoutBox')) {
      return Hive.box('workoutBox');
    }
    return await Hive.openBox('workoutBox');
  }

  Future<List<Workout>> getWorkouts() async {
    try {
      final box = await _box;
      final workouts = box.values.toList();
      return workouts.map((item) {
        final map = item as Map;
        return Workout.fromMap(map['id'] as String, {
          'name': map['name'],
          'type': map['type'],
          'duration': map['duration'],
          'caloriesBurned': map['caloriesBurned'],
          'date': map['date'],
        });
      }).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      print('Error getting workouts: $e');
      return [];
    }
  }

  Future<String> addWorkout(Workout workout) async {
    try {
      final box = await _box;
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await box.put(id, {
        'id': id,
        'name': workout.name,
        'type': workout.type,
        'duration': workout.duration,
        'caloriesBurned': workout.caloriesBurned,
        'date': workout.date.toIso8601String(),
      });
      return id;
    } catch (e) {
      print('Error adding workout: $e');
      rethrow;
    }
  }

  Future<void> updateWorkout(String workoutId, Workout workout) async {
    try {
      final box = await _box;
      await box.put(workoutId, {
        'id': workoutId,
        'name': workout.name,
        'type': workout.type,
        'duration': workout.duration,
        'caloriesBurned': workout.caloriesBurned,
        'date': workout.date.toIso8601String(),
      });
    } catch (e) {
      print('Error updating workout: $e');
      rethrow;
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    try {
      final box = await _box;
      await box.delete(workoutId);
    } catch (e) {
      print('Error deleting workout: $e');
      rethrow;
    }
  }
}

