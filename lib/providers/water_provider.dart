import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class WaterProvider with ChangeNotifier {
  final Box waterBox = Hive.box('water');

  List<Map<String, dynamic>> get entries =>
      List<Map<String, dynamic>>.from(
        waterBox.get('entries', defaultValue: []),
      );

  int get total =>
      entries.fold(0, (sum, item) => sum + (item['amount'] as int));

  void addWater(int amount, DateTime date) {
    final updated = [...entries, {'amount': amount, 'date': date}];
    waterBox.put('entries', updated);
    notifyListeners();
  }

  void editWater(int index, int amount, DateTime date) {
    final updated = [...entries];
    updated[index] = {'amount': amount, 'date': date};
    waterBox.put('entries', updated);
    notifyListeners();
  }

  void deleteWater(int index) {
    final updated = [...entries];
    updated.removeAt(index);
    waterBox.put('entries', updated);
    notifyListeners();
  }
}
