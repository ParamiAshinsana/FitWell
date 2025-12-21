import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/utils/date_utils.dart' as date_utils;
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../routes/app_routes.dart';
import '../provider/medicine_provider.dart';
import '../data/medicine_model.dart';
import 'report_page.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  DateTime selectedDate = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicineProvider>(context);
    final now = DateTime.now();
    final reminders = provider.medicines;

    final reminderDates = reminders
        .expand((r) => date_utils.AppDateUtils.getDatesBetween(r.startDate, r.endDate))
        .toSet()
        .toList()
      ..sort();

    final upcomingReminders = reminders.where((r) {
      if (selectedDate.isBefore(r.startDate) ||
          selectedDate.isAfter(r.endDate)) {
        return false;
      }
      return r.times.any((t) {
        if (t.status != 'pending') return false;
        final dt = date_utils.AppDateUtils.combine(selectedDate, t.time);
        return date_utils.AppDateUtils.isSameDate(selectedDate, now) ? dt.isAfter(now) : true;
      });
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          AppTexts.medicineReminder,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bar_chart,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportPage()),
              );
            },
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${AppTexts.today}, ${date_utils.AppDateUtils.formatDate(selectedDate)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: reminderDates.length,
                    itemBuilder: (_, i) {
                      final date = reminderDates[i];
                      final isSelected = date_utils.AppDateUtils.isSameDate(date, selectedDate);

                      return GestureDetector(
                        onTap: () => setState(() => selectedDate = date),
                        child: GlassCard(
                          padding: EdgeInsets.zero,
                          borderRadius: 12,
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  date_utils.AppDateUtils.weekday(date),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  date.day.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppTexts.upcomingMedication,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: _showAddReminderPopup,
                      child: const Text(
                        AppTexts.addReminder,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: upcomingReminders.length,
                    itemBuilder: (_, i) => _medicineCard(upcomingReminders[i]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _medicineCard(MedicineModel r) {
    final now = DateTime.now();
    final selectedDate = this.selectedDate;

    final validTimes = r.times.where((t) {
      if (t.status != 'pending') return false;
      final dt = date_utils.AppDateUtils.combine(selectedDate, t.time);
      return date_utils.AppDateUtils.isSameDate(selectedDate, now) ? dt.isAfter(now) : true;
    }).toList();

    if (validTimes.isEmpty) return const SizedBox();

    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            r.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          ...validTimes.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      t.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: () async {
                      setState(() {
                        t.status = 'skipped';
                      });
                      final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
                      await medicineProvider.updateMedicine(r.id, r);
                    },
                    child: const Text(AppTexts.skipped, style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.gradientBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    onPressed: () async {
                      setState(() {
                        t.status = 'taken';
                      });
                      final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
                      await medicineProvider.updateMedicine(r.id, r);
                    },
                    child: const Text(AppTexts.taken, style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddReminderPopup() {
    final nameCtrl = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 7));
    List<MedicineTime> times = [];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: GlassCard(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      AppTexts.addReminder,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: AppTexts.medicineName,
                        labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.6),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        "${AppTexts.startDate}: ${date_utils.AppDateUtils.formatDate(startDate)}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: const Icon(Icons.calendar_today, color: Colors.white),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => startDate = d);
                      },
                    ),
                    ListTile(
                      title: Text(
                        "${AppTexts.endDate}: ${date_utils.AppDateUtils.formatDate(endDate)}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: const Icon(Icons.calendar_today, color: Colors.white),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: endDate,
                          firstDate: startDate,
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => endDate = d);
                      },
                    ),
                    if (times.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: times
                            .map(
                              (t) => Chip(
                                label: Text(
                                  t.time,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.white.withOpacity(0.2),
                                deleteIcon: const Icon(Icons.close, color: Colors.white, size: 18),
                                onDeleted: () {
                                  setState(() => times.remove(t));
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 10),
                    TextButton.icon(
                      icon: const Icon(Icons.access_time, color: Colors.white),
                      label: const Text(
                        AppTexts.addTime,
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (t != null) {
                          setState(() {
                            times.add(
                              MedicineTime(
                                time: t.format(context),
                                date: startDate,
                              ),
                            );
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            AppTexts.cancel,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.gradientBlue,
                          ),
                          onPressed: () async {
                            if (nameCtrl.text.isEmpty || times.isEmpty) return;

                            final provider = Provider.of<MedicineProvider>(context, listen: false);
                            final success = await provider.addMedicine(
                              MedicineModel(
                                name: nameCtrl.text,
                                startDate: startDate,
                                endDate: endDate,
                                times: times,
                              ),
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Medicine reminder added successfully'),
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(AppTexts.save),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

