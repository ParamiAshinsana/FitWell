import 'package:hive_flutter/hive_flutter.dart';
import 'appointment_model.dart';

class AppointmentService {
  Box get _box => Hive.box('appointmentBox');

  Future<List<Appointment>> getAppointments() async {
    final appointments = _box.values.toList();
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
  }

  Future<String> addAppointment(Appointment appointment) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _box.put(id, {
      'id': id,
      'date': appointment.date.toIso8601String(),
      'time': appointment.time,
      'title': appointment.title,
      'doctorName': appointment.doctorName,
      'location': appointment.location,
    });
    return id;
  }

  Future<void> updateAppointment(String appointmentId, Appointment appointment) async {
    await _box.put(appointmentId, {
      'id': appointmentId,
      'date': appointment.date.toIso8601String(),
      'time': appointment.time,
      'title': appointment.title,
      'doctorName': appointment.doctorName,
      'location': appointment.location,
    });
  }

  Future<void> deleteAppointment(String appointmentId) async {
    await _box.delete(appointmentId);
  }
}

