import 'package:flutter/material.dart';
import '../data/appointment_model.dart';
import '../data/appointment_service.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService _service = AppointmentService();
  List<Appointment> _appointments = [];
  bool _isLoading = false;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;

  Future<void> loadAppointments() async {
    _isLoading = true;
    notifyListeners();
    try {
      _appointments = await _service.getAppointments();
    } catch (e) {
      print('Error loading appointments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAppointment(Appointment appointment) async {
    try {
      if (appointment.title.trim().isEmpty || 
          appointment.doctorName.trim().isEmpty || 
          appointment.location.trim().isEmpty) {
        return false;
      }
      await _service.addAppointment(appointment);
      await loadAppointments();
      return true;
    } catch (e) {
      print('Error adding appointment: $e');
      return false;
    }
  }

  Future<bool> updateAppointment(String appointmentId, Appointment appointment) async {
    try {
      if (appointment.title.trim().isEmpty || 
          appointment.doctorName.trim().isEmpty || 
          appointment.location.trim().isEmpty) {
        return false;
      }
      await _service.updateAppointment(appointmentId, appointment);
      await loadAppointments();
      return true;
    } catch (e) {
      print('Error updating appointment: $e');
      return false;
    }
  }

  Future<bool> deleteAppointment(String appointmentId) async {
    try {
      await _service.deleteAppointment(appointmentId);
      await loadAppointments();
      return true;
    } catch (e) {
      print('Error deleting appointment: $e');
      return false;
    }
  }
}

