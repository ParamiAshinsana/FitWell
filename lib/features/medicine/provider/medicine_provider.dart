import 'package:flutter/material.dart';
import '../data/medicine_service.dart';
import '../data/medicine_model.dart';

class MedicineProvider with ChangeNotifier {
  final MedicineService _medicineService = MedicineService();

  List<MedicineModel> _medicines = [];
  List<MedicineModel> get medicines => _medicines;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  MedicineProvider() {
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _medicines = await _medicineService.getMedicines();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addMedicine(MedicineModel medicine) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final id = await _medicineService.addMedicine(medicine);
      await _loadMedicines();

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

  Future<bool> updateMedicine(String medicineId, MedicineModel medicine) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _medicineService.updateMedicine(medicineId, medicine);
      await _loadMedicines();

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

  Future<bool> deleteMedicine(String medicineId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _medicineService.deleteMedicine(medicineId);
      await _loadMedicines();

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
    _loadMedicines();
  }
}

