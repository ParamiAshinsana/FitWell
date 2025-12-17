class Meal {
  final String name;
  final int calories;
  final DateTime date;

  Meal({
    required this.name,
    required this.calories,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'date': date.toIso8601String(),
    };
  }

  /// Create Meal object from Map
  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      name: map['name'] ?? '',
      calories: map['calories'] ?? 0,
      date: DateTime.parse(map['date']),
    );
  }
}
