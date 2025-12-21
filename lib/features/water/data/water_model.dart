class WaterLog {
  final String id;
  final int amount;
  final DateTime date;

  WaterLog({
    required this.id,
    required this.amount,
    required this.date,
  });

  factory WaterLog.fromMap(String id, Map<String, dynamic> map) {
    return WaterLog(
      id: id,
      amount: map['amount'] ?? 0,
      date: map['date'] != null
          ? DateTime.parse(map['date'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}

