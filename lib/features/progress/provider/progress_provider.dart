import 'package:flutter/material.dart';
import '../../meal/provider/meal_provider.dart';
import '../../water/provider/water_provider.dart';
import '../../workout/provider/workout_provider.dart';

class ProgressProvider with ChangeNotifier {
  final MealProvider _mealProvider;
  final WaterProvider _waterProvider;
  final WorkoutProvider _workoutProvider;

  ProgressProvider({
    required MealProvider mealProvider,
    required WaterProvider waterProvider,
    required WorkoutProvider workoutProvider,
  })  : _mealProvider = mealProvider,
        _waterProvider = waterProvider,
        _workoutProvider = workoutProvider;

  int get totalCaloriesConsumed {
    return _mealProvider.meals.fold(0, (sum, meal) => sum + meal.calories);
  }

  int get totalWaterConsumed => _waterProvider.total;

  int get totalCaloriesBurned {
    return _workoutProvider.workouts.fold(
        0, (sum, workout) => sum + workout.caloriesBurned);
  }

  int get netCalories => totalCaloriesConsumed - totalCaloriesBurned;

  int get totalWorkoutDuration {
    return _workoutProvider.workouts.fold(
        0, (sum, workout) => sum + workout.duration);
  }
}

