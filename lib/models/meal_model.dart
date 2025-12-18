class Meal {
  final String id;        // 🔹 Firestore document ID
  final String name;
  final int calories;
  final DateTime date;

  Meal({
    required this.id,
    required this.name,
    required this.calories,
    required this.date,
  });

  /// For Firestore / Hive → App
  factory Meal.fromMap(String id, Map<String, dynamic> map) {
    return Meal(
      id: id,
      name: map['name'] ?? '',
      calories: map['calories'] ?? 0,
      date: map['date'] != null
          ? DateTime.parse(map['date'].toString())
          : DateTime.now(),
    );
  }

  /// For App → Firestore / Hive
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'date': date.toIso8601String(),
    };
  }
}
