import 'package:hive_flutter/hive_flutter.dart';
import 'water_model.dart';

class WaterService {
  Box get _box => Hive.box('waterBox');

  Future<List<WaterLog>> getWaterEntries() async {
    final entries = _box.values.toList();
    return entries.map((item) {
      final map = item as Map;
      return WaterLog.fromMap(map['id'] as String, {
        'amount': map['amount'],
        'date': map['date'],
      });
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<String> addWater(int amount, DateTime date) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _box.put(id, {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
    });
    return id;
  }

  Future<void> updateWater(String waterId, int amount, DateTime date) async {
    await _box.put(waterId, {
      'id': waterId,
      'amount': amount,
      'date': date.toIso8601String(),
    });
  }

  Future<void> deleteWater(String waterId) async {
    await _box.delete(waterId);
  }
}
