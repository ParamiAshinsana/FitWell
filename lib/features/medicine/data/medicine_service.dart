import 'package:hive_flutter/hive_flutter.dart';
import 'medicine_model.dart';

class MedicineService {
  Box<MedicineModel> get _box => Hive.box<MedicineModel>('medicineBox');

  Future<List<MedicineModel>> getMedicines() async {
    return _box.values.toList();
  }

  Future<String> addMedicine(MedicineModel medicine) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    medicine.id = id;
    await _box.put(id, medicine);
    return id;
  }

  Future<void> updateMedicine(String medicineId, MedicineModel medicine) async {
    medicine.id = medicineId;
    await _box.put(medicineId, medicine);
  }

  Future<void> deleteMedicine(String medicineId) async {
    await _box.delete(medicineId);
  }
}
