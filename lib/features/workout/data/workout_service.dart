import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/constants/firestore_paths.dart';
import 'workout_model.dart';

class WorkoutService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  String get _userId {
    final userId = FirebaseService.currentUserId;
    if (userId == null || userId.isEmpty) {
      throw Exception('User not authenticated. Please login again.');
    }
    return userId;
  }

  Future<List<Workout>> getWorkouts() async {
    final snapshot = await _firestore
        .collection(FirestorePaths.workouts(_userId))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Workout.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<String> addWorkout(Workout workout) async {
    final data = workout.toMap();
    data['date'] = Timestamp.fromDate(workout.date);
    final doc = await _firestore
        .collection(FirestorePaths.workouts(_userId))
        .add(data);
    return doc.id;
  }

  Future<void> updateWorkout(String workoutId, Workout workout) async {
    final data = workout.toMap();
    data['date'] = Timestamp.fromDate(workout.date);
    await _firestore
        .collection(FirestorePaths.workouts(_userId))
        .doc(workoutId)
        .update(data);
  }

  Future<void> deleteWorkout(String workoutId) async {
    await _firestore
        .collection(FirestorePaths.workouts(_userId))
        .doc(workoutId)
        .delete();
  }
}

