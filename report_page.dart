import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'medicine_model.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<MedicineModel>('medicineBox');

    int taken = 0, skipped = 0, pending = 0;

    for (final r in box.values) {
      for (final t in r.times) {
        if (t.status == 'taken') taken++;
        if (t.status == 'skipped') skipped++;
        if (t.status == 'pending') pending++;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Report & History")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _tile("Taken", taken, Colors.green),
            _tile("Skipped", skipped, Colors.orange),
            _tile("Pending", pending, Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _tile(String title, int count, Color color) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          count.toString(),
          style: TextStyle(color: color, fontSize: 20),
        ),
      ),
    );
  }
}
