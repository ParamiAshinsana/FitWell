class Meal {
  final String id;
  final String name;
  final int calories;
  final DateTime date;

  Meal({
    required this.id,
    required this.name,
    required this.calories,
    required this.date,
  });

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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'date': date.toIso8601String(),
    };
  }
}
