import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

class WaterProvider with ChangeNotifier {
  final Box _waterBox = Hive.box('water');
  final CollectionReference _waterRef =
  FirebaseFirestore.instance.collection('water');

  /// GET ENTRIES
  List<Map<String, dynamic>> get entries {
    return List<Map<String, dynamic>>.from(
      _waterBox.values.map((e) {
        return {
          'id': e['id'],
          'amount': e['amount'],
          'date': DateTime.parse(e['date']),
        };
      }),
    );
  }

  int get total => entries.fold(
    0,
        (sum, item) => sum + (item['amount'] as int),
  );

  /// FETCH FROM FIRESTORE → SAVE TO HIVE
  Future<void> fetchWaterFromFirestore() async {
    final snapshot = await _waterRef.get();
    _waterBox.clear();

    for (var doc in snapshot.docs) {
      _waterBox.add({
        'id': doc.id,
        'amount': doc['amount'],
        'date': doc['date'],
      });
    }

    notifyListeners();
  }

  /// ADD
  Future<void> addWater(int amount, DateTime date) async {
    final doc = await _waterRef.add({
      'amount': amount,
      'date': date.toIso8601String(),
    });

    _waterBox.add({
      'id': doc.id,
      'amount': amount,
      'date': date.toIso8601String(),
    });

    notifyListeners();
  }

  /// EDIT
  Future<void> editWater(String docId, int index, int amount, DateTime date) async {
    await _waterRef.doc(docId).update({
      'amount': amount,
      'date': date.toIso8601String(),
    });

    _waterBox.putAt(index, {
      'id': docId,
      'amount': amount,
      'date': date.toIso8601String(),
    });

    notifyListeners();
  }

  /// DELETE
  Future<void> deleteWater(String docId, int index) async {
    await _waterRef.doc(docId).delete();
    await _waterBox.deleteAt(index);

    notifyListeners();
  }
}

