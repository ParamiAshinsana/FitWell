import 'package:hive/hive.dart';

class MedicineTime {
  String time; // "10:30 AM"
  String status; // pending | taken | skipped
  DateTime date; // date for history

  MedicineTime({
    required this.time,
    required this.date,
    this.status = 'pending',
  });
}

class MedicineModel extends HiveObject {
  String name;
  DateTime startDate;
  DateTime endDate;
  List<MedicineTime> times;

  MedicineModel({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.times,
  });
}

/// MANUAL ADAPTER (NO build_runner)
class MedicineModelAdapter extends TypeAdapter<MedicineModel> {
  @override
  final int typeId = 0;

  @override
  MedicineModel read(BinaryReader reader) {
    final name = reader.readString();
    final startDate = DateTime.parse(reader.readString());
    final endDate = DateTime.parse(reader.readString());

    final count = reader.readInt();
    final times = List.generate(count, (_) {
      return MedicineTime(
        time: reader.readString(),
        status: reader.readString(),
        date: DateTime.parse(reader.readString()),
      );
    });

    return MedicineModel(
      name: name,
      startDate: startDate,
      endDate: endDate,
      times: times,
    );
  }

  @override
  void write(BinaryWriter writer, MedicineModel obj) {
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


