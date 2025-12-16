import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/meal_model.dart';

class MealProvider with ChangeNotifier {
  final Box _mealBox = Hive.box('meals');

  /// Get all meals from Hive
  List<Meal> get meals {
    return _mealBox.values
        .map((e) => Meal.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  void addMeal(Meal meal) {
    _mealBox.add(meal.toMap());
    notifyListeners();
  }

  void updateMeal(int index, Meal updatedMeal) {
    _mealBox.putAt(index, updatedMeal.toMap());
    notifyListeners();
  }

  void deleteMeal(int index) {
    _mealBox.deleteAt(index);
    notifyListeners();
  }
}

