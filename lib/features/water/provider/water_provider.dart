import 'package:flutter/material.dart';
import '../data/water_service.dart';
import '../data/water_model.dart';

class WaterProvider with ChangeNotifier {
  final WaterService _waterService = WaterService();

  List<WaterLog> _entries = [];
  List<WaterLog> get entries => _entries;

  int get total => _entries.fold(0, (sum, item) => sum + item.amount);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  WaterProvider() {
    _loadWater();
  }

  Future<void> _loadWater() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _entries = await _waterService.getWaterEntries();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addWater(int amount, DateTime date) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final id = await _waterService.addWater(amount, date);
      await _loadWater();

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

  Future<bool> updateWater(String waterId, int amount, DateTime date) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _waterService.updateWater(waterId, amount, date);
      await _loadWater();

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

  Future<bool> deleteWater(String waterId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _waterService.deleteWater(waterId);
      await _loadWater();

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
    _loadWater();
  }
}

