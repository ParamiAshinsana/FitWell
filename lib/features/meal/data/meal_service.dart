import 'package:hive_flutter/hive_flutter.dart';
import 'meal_model.dart';

class MealService {
  Box get _box => Hive.box('mealsBox');

  Future<List<Meal>> getMeals() async {
    final meals = _box.values.toList();
    return meals.map((item) {
      final map = item as Map;
      return Meal.fromMap(map['id'] as String, {
        'name': map['name'],
        'calories': map['calories'],
        'date': map['date'],
      });
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
  }

  Future<String> addMeal(Meal meal) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _box.put(id, {
      'id': id,
      'name': meal.name,
      'calories': meal.calories,
      'date': meal.date.toIso8601String(),
    });
    return id;
  }

  Future<void> updateMeal(String mealId, Meal meal) async {
    await _box.put(mealId, {
      'id': mealId,
      'name': meal.name,
      'calories': meal.calories,
      'date': meal.date.toIso8601String(),
    });
  }

  Future<void> deleteMeal(String mealId) async {
    await _box.delete(mealId);
  }
}
