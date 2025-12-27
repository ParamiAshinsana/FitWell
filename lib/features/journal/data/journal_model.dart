class Journal {
  final String id;
  final DateTime date;
  final String description;

  Journal({
    required this.id,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory Journal.fromMap(String id, Map<String, dynamic> map) {
    return Journal(
      id: id,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String,
    );
  }
}

