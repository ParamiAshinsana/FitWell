import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'medicine_model.dart';
import 'report_page.dart';

class MedicineHomePage extends StatefulWidget {
  const MedicineHomePage({super.key});

  @override
  State<MedicineHomePage> createState() => _MedicineHomePageState();
}

class _MedicineHomePageState extends State<MedicineHomePage> {
  final Color themeColor = const Color(0xFF7FAFA3);
  final Box<MedicineModel> box = Hive.box<MedicineModel>('medicineBox');

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
    final now = DateTime.now();
    final reminders = box.values.toList();

    final reminderDates =
        reminders
            .expand((r) => _getDatesBetween(r.startDate, r.endDate))
            .toSet()
            .toList()
          ..sort();

    final upcomingReminders =
        reminders.where((r) {
          if (selectedDate.isBefore(r.startDate) ||
              selectedDate.isAfter(r.endDate))
            return false;

          return r.times.any((t) {
            if (t.status != 'pending') return false;
            final dt = _combine(selectedDate, t.time);
            return _isSameDate(selectedDate, now) ? dt.isAfter(now) : true;
          });
        }).toList();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFF7FAFA3),
        elevation: 0,
        title: const Text(
          "Medcine Reminder",
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bar_chart,
              color: Color.fromARGB(255, 255, 255, 255),
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

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TODAY TEXT
            Text(
              "Today, ${_formatDate(selectedDate)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 16),

            /// DATE SCROLLER
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: reminderDates.length,
                itemBuilder: (_, i) {
                  final date = reminderDates[i];
                  final isSelected = _isSameDate(date, selectedDate);

                  return GestureDetector(
                    onTap: () => setState(() => selectedDate = date),
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? themeColor : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _weekday(date),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            /// UPCOMING TITLE + ADD REMINDER LINK
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Upcoming Medication",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: _showAddReminderPopup,
                  child: Text(
                    "Add reminder",
                    style: TextStyle(
                      color: themeColor,
                      fontWeight: FontWeight.w600,
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
    );
  }

  /// MEDICINE CARD
  Widget _medicineCard(MedicineModel r) {
    final now = DateTime.now();

    final validTimes =
        r.times.where((t) {
          if (t.status != 'pending') return false;
          final dt = _combine(selectedDate, t.time);
          return _isSameDate(selectedDate, now) ? dt.isAfter(now) : true;
        }).toList();

    if (validTimes.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          ...validTimes.map(
            (t) => Row(
              children: [
                /// TIME CHIP
                Chip(
                  label: Text(t.time, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.grey.shade100,
                ),

                const Spacer(),

                /// SKIPPED
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    foregroundColor: Colors.grey.shade500,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      t.status = 'skipped';
                      r.save();
                    });
                  },
                  child: const Text("Skipped", style: TextStyle(fontSize: 12)),
                ),

                const SizedBox(width: 6),

                /// TAKEN
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  onPressed: () {
                    setState(() {
                      t.status = 'taken';
                      r.save();
                    });
                  },
                  child: const Text("Taken", style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ADD REMINDER POPUP
  void _showAddReminderPopup() {
    final nameCtrl = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 7));
    List<MedicineTime> times = [];

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: const Text("Add Reminder"),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: "Medicine name",
                        ),
                      ),

                      ListTile(
                        title: Text("Start date: ${_formatDate(startDate)}"),
                        trailing: const Icon(Icons.calendar_today),
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
                        title: Text("End date: ${_formatDate(endDate)}"),
                        trailing: const Icon(Icons.calendar_today),
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

                      Wrap(
                        spacing: 8,
                        children:
                            times
                                .map(
                                  (t) => Chip(
                                    label: Text(t.time),
                                    onDeleted: () {
                                      setState(() => times.remove(t));
                                    },
                                  ),
                                )
                                .toList(),
                      ),

                      TextButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: const Text("Add time"),
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
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                    ),
                    onPressed: () {
                      if (nameCtrl.text.isEmpty || times.isEmpty) return;

                      box.add(
                        MedicineModel(
                          name: nameCtrl.text,
                          startDate: startDate,
                          endDate: endDate,
                          times: times,
                        ),
                      );

                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: const Text("Save"),
                  ),
                ],
              );
            },
          ),
    );
  }

  /// HELPERS
  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _weekday(DateTime d) =>
      ["S", "M", "T", "W", "T", "F", "S"][d.weekday % 7];

  String _formatDate(DateTime d) =>
      "${d.day} ${["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][d.month - 1]}, ${d.year}";

  List<DateTime> _getDatesBetween(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      dates.add(DateTime(start.year, start.month, start.day + i));
    }
    return dates;
  }

  DateTime _combine(DateTime date, String time) {
    final parts = time.split(' ');
    final hm = parts[0].split(':');
    int hour = int.parse(hm[0]);
    final minute = int.parse(hm[1]);
    final isPM = parts[1].toLowerCase() == 'pm';

    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
