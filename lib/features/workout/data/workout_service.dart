import 'package:hive_flutter/hive_flutter.dart';
import 'workout_model.dart';

class WorkoutService {
  Box get _box => Hive.box('workoutBox');

  Future<List<Workout>> getWorkouts() async {
    final workouts = _box.values.toList();
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
  }

  Future<String> addWorkout(Workout workout) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _box.put(id, {
      'id': id,
      'name': workout.name,
      'type': workout.type,
      'duration': workout.duration,
      'caloriesBurned': workout.caloriesBurned,
      'date': workout.date.toIso8601String(),
    });
    return id;
  }

  Future<void> updateWorkout(String workoutId, Workout workout) async {
    await _box.put(workoutId, {
      'id': workoutId,
      'name': workout.name,
      'type': workout.type,
      'duration': workout.duration,
      'caloriesBurned': workout.caloriesBurned,
      'date': workout.date.toIso8601String(),
    });
  }

  Future<void> deleteWorkout(String workoutId) async {
    await _box.delete(workoutId);
  }
}

