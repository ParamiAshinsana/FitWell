import 'package:cloud_firestore/cloud_firestore.dart';

class Workout {
  final String id;
  final String name;
  final String type;
  final int duration;
  final int caloriesBurned;
  final DateTime date;

  Workout({
    required this.id,
    required this.name,
    required this.type,
    required this.duration,
    required this.caloriesBurned,
    required this.date,
  });

  factory Workout.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      }
      
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return DateTime.now();
        }
      }
      
      return DateTime.now();
    }

    return Workout(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      duration: map['duration'] ?? 0,
      caloriesBurned: map['caloriesBurned'] ?? 0,
      date: parseDate(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'date': date.toIso8601String(),
    };
  }
}

