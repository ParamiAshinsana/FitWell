import 'package:hive/hive.dart';

class ReminderTime {
  String time; 
  String status;
  DateTime date;

  ReminderTime({
    required this.time,
    required this.date,
    this.status = 'pending',
  });
}

class ReminderModel extends HiveObject {
  String id;
  String name;
  DateTime startDate;
  DateTime endDate;
  List<ReminderTime> times;

  ReminderModel({
    this.id = '',
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.times,
  });

  factory ReminderModel.fromMap(String id, Map<String, dynamic> map) {
    return ReminderModel(
      id: id,
      name: map['name'] ?? '',
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      times: (map['times'] as List?)
              ?.map((t) => ReminderTime(
                    time: t['time'],
                    status: t['status'] ?? 'pending',
                    date: DateTime.parse(t['date']),
                  ))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'times': times.map((t) => {
            'time': t.time,
            'status': t.status,
            'date': t.date.toIso8601String(),
          }).toList(),
    };
  }
}

class ReminderModelAdapter extends TypeAdapter<ReminderModel> {
  @override
  final int typeId = 0;

  DateTime _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // If parsing fails, return current date as fallback
      print('Error parsing date: $dateString, using current date as fallback');
      return DateTime.now();
    }
  }

  @override
  ReminderModel read(BinaryReader reader) {
    try {
      final id = reader.readString();
      final name = reader.readString();
      final startDateString = reader.readString();
      final endDateString = reader.readString();
      
      final startDate = _parseDate(startDateString);
      final endDate = _parseDate(endDateString);

      final count = reader.readInt();
      final times = List.generate(count, (_) {
        final time = reader.readString();
        final status = reader.readString();
        final dateString = reader.readString();
        return ReminderTime(
          time: time,
          status: status,
          date: _parseDate(dateString),
        );
      });

      return ReminderModel(
        id: id,
        name: name,
        startDate: startDate,
        endDate: endDate,
        times: times,
      );
    } catch (e) {
      print('Error reading ReminderModel: $e');
      // Return a default reminder model to prevent app crash
      return ReminderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Invalid Reminder',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        times: [],
      );
    }
  }

  @override
  void write(BinaryWriter writer, ReminderModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.startDate.toIso8601String());
    writer.writeString(obj.endDate.toIso8601String());

    writer.writeInt(obj.times.length);
    for (final t in obj.times) {
      writer.writeString(t.time);
      writer.writeString(t.status);
      writer.writeString(t.date.toIso8601String());
    }
  }
}

