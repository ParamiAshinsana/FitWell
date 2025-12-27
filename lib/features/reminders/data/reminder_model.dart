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

  @override
  ReminderModel read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final startDate = DateTime.parse(reader.readString());
    final endDate = DateTime.parse(reader.readString());

    final count = reader.readInt();
    final times = List.generate(count, (_) {
      return ReminderTime(
        time: reader.readString(),
        status: reader.readString(),
        date: DateTime.parse(reader.readString()),
      );
    });

    return ReminderModel(
      id: id,
      name: name,
      startDate: startDate,
      endDate: endDate,
      times: times,
    );
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

