class WaterLog {
  final String id;
  final double amount;
  final DateTime date;

  WaterLog({required this.id, required this.amount, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory WaterLog.fromMap(Map<String, dynamic> map) {
    return WaterLog(
      id: map['id'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
    );
  }
}
