class Appointment {
  final String id;
  final DateTime date;
  final String time;
  final String title;
  final String doctorName;
  final String location;

  Appointment({
    required this.id,
    required this.date,
    required this.time,
    required this.title,
    required this.doctorName,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'time': time,
      'title': title,
      'doctorName': doctorName,
      'location': location,
    };
  }

  factory Appointment.fromMap(String id, Map<String, dynamic> map) {
    return Appointment(
      id: id,
      date: DateTime.parse(map['date'] as String),
      time: map['time'] as String,
      title: map['title'] as String,
      doctorName: map['doctorName'] as String,
      location: map['location'] as String,
    );
  }
}

