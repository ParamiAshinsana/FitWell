import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'medicine_model.dart';
import 'medicine_home_page.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(MedicineModelAdapter());
  final box = await Hive.openBox<MedicineModel>('medicineBox');

  await NotificationService.init();

  /// ADD DEFAULT DATA (ONLY FIRST TIME)
  if (box.isEmpty) {
    final today = DateTime.now();

    box.addAll([
      MedicineModel(
        name: "Paracetamol",
        startDate: today,
        endDate: today.add(const Duration(days: 5)),
        times: [
          MedicineTime(time: "08:00 AM", date: today),
          MedicineTime(time: "08:00 PM", date: today),
        ],
      ),
      MedicineModel(
        name: "Vitamin C",
        startDate: today,
        endDate: today.add(const Duration(days: 10)),
        times: [
          MedicineTime(time: "09:00 AM", date: today),
        ],
      ),
      MedicineModel(
        name: "Cough Syrup",
        startDate: today,
        endDate: today.add(const Duration(days: 7)),
        times: [
          MedicineTime(time: "07:00 AM", date: today),
          MedicineTime(time: "02:00 PM", date: today),
          MedicineTime(time: "09:00 PM", date: today),
        ],
      ),
    ]);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MedicineHomePage(),
    );
  }
}

