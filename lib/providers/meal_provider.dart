import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../models/meal_model.dart';

class MealProvider with ChangeNotifier {
  final Box _mealBox = Hive.box('meals');
  final CollectionReference _mealRef =
  FirebaseFirestore.instance.collection('meals');

  List<Meal> get meals {
    return _mealBox.values
        .map((e) => Meal.fromMap(
      e['id'],
      Map<String, dynamic>.from(e),
    ))
        .toList();
  }

  Future<void> fetchMealsFromFirestore() async {
    final snapshot = await _mealRef.get();
    _mealBox.clear();

    for (var doc in snapshot.docs) {
      _mealBox.add({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    }
    notifyListeners();
  }

  Future<void> addMeal(Meal meal) async {
    final doc = await _mealRef.add(meal.toMap());

    _mealBox.add({
      'id': doc.id,
      ...meal.toMap(),
    });

    notifyListeners();
  }

  Future<void> updateMeal(String docId, int index, Meal meal) async {
    await _mealRef.doc(docId).update(meal.toMap());

    _mealBox.putAt(index, {
      'id': docId,
      ...meal.toMap(),
    });

    notifyListeners();
  }

  Future<void> deleteMeal(String docId, int index) async {
    await _mealRef.doc(docId).delete();
    await _mealBox.deleteAt(index);

    notifyListeners();
  }
}


