import 'package:hive_flutter/hive_flutter.dart';
import 'appointment_model.dart';

class AppointmentService {
  Future<Box> get _box async {
    if (Hive.isBoxOpen('appointmentBox')) {
      return Hive.box('appointmentBox');
    }
    return await Hive.openBox('appointmentBox');
  }

  Future<List<Appointment>> getAppointments() async {
    try {
      final box = await _box;
      final appointments = box.values.toList();
      return appointments.map((item) {
        final map = item as Map;
        return Appointment.fromMap(map['id'] as String, {
          'date': map['date'],
          'time': map['time'],
          'title': map['title'],
          'doctorName': map['doctorName'],
          'location': map['location'],
        });
      }).toList()
        ..sort((a, b) {
          final dateCompare = a.date.compareTo(b.date);
          if (dateCompare != 0) return dateCompare;
          return a.time.compareTo(b.time);
        });
    } catch (e) {
      print('Error getting appointments: $e');
      return [];
    }
  }

  Future<String> addAppointment(Appointment appointment) async {
    try {
      final box = await _box;
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await box.put(id, {
        'id': id,
        'date': appointment.date.toIso8601String(),
        'time': appointment.time,
        'title': appointment.title,
        'doctorName': appointment.doctorName,
        'location': appointment.location,
      });
      return id;
    } catch (e) {
      print('Error adding appointment: $e');
      rethrow;
    }
  }

  Future<void> updateAppointment(String appointmentId, Appointment appointment) async {
    try {
      final box = await _box;
      await box.put(appointmentId, {
        'id': appointmentId,
        'date': appointment.date.toIso8601String(),
        'time': appointment.time,
        'title': appointment.title,
        'doctorName': appointment.doctorName,
        'location': appointment.location,
      });
    } catch (e) {
      print('Error updating appointment: $e');
      rethrow;
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    try {
      final box = await _box;
      await box.delete(appointmentId);
    } catch (e) {
      print('Error deleting appointment: $e');
      rethrow;
    }
  }
}

