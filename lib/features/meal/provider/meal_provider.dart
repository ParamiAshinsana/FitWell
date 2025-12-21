import 'package:flutter/material.dart';
import '../data/meal_service.dart';
import '../data/meal_model.dart';

class MealProvider with ChangeNotifier {
  final MealService _mealService = MealService();

  List<Meal> _meals = [];
  List<Meal> get meals => _meals;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  MealProvider() {
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _meals = await _mealService.getMeals();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addMeal(Meal meal) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final id = await _mealService.addMeal(meal);
      await _loadMeals();

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

  Future<bool> updateMeal(String mealId, Meal meal) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _mealService.updateMeal(mealId, meal);
      await _loadMeals();

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

  Future<bool> deleteMeal(String mealId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _mealService.deleteMeal(mealId);
      await _loadMeals();

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
    _loadMeals();
  }
}

