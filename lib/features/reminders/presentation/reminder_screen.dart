import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/utils/date_utils.dart' as date_utils;
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../routes/app_routes.dart';
import '../provider/reminder_provider.dart';
import '../provider/appointment_provider.dart';
import '../data/reminder_model.dart';
import '../data/appointment_model.dart';
import 'report_page.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime selectedDate = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentProvider>(context, listen: false).loadAppointments();
      Provider.of<ReminderProvider>(context, listen: false).refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'Reminders',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          if (_tabController.index == 0)
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          indicatorColor: Colors.white,
          onTap: (index) {
            setState(() {});
          },
          tabs: const [
            Tab(text: 'Medicine Reminder'),
            Tab(text: 'Doctor Appointments'),
          ],
        ),
      ),
      body: GradientBackground(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMedicineReminderTab(),
            _buildDoctorAppointmentsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineReminderTab() {
    return Consumer<ReminderProvider>(
      builder: (context, provider, _) {
        final now = DateTime.now();
        final reminders = provider.reminders;

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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
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
                  'Upcoming Reminders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: _showAddReminderPopup,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '+ Add',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: upcomingReminders.isEmpty
                  ? Center(
                      child: Text(
                        'No reminders for this date',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: upcomingReminders.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _reminderCard(upcomingReminders[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
      );
    },
    );
  }

  Widget _reminderCard(ReminderModel r) {
    final now = DateTime.now();
    final selectedDate = this.selectedDate;

    final validTimes = r.times.where((t) {
      if (t.status != 'pending') return false;
      final dt = date_utils.AppDateUtils.combine(selectedDate, t.time);
      return date_utils.AppDateUtils.isSameDate(selectedDate, now) ? dt.isAfter(now) : true;
    }).toList();

    if (validTimes.isEmpty) return const SizedBox();

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.medication, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  r.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...validTimes.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      t.time,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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
                      final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
                      await reminderProvider.updateReminder(r.id, r);
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
                      final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
                      await reminderProvider.updateReminder(r.id, r);
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
    List<ReminderTime> times = [];

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
                              ReminderTime(
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

                            final provider = Provider.of<ReminderProvider>(context, listen: false);
                            final success = await provider.addReminder(
                              ReminderModel(
                                name: nameCtrl.text,
                                startDate: startDate,
                                endDate: endDate,
                                times: times,
                              ),
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              if (success) {
                                // Refresh the provider to update the list
                                Provider.of<ReminderProvider>(context, listen: false).refresh();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Reminder added successfully'),
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(provider.errorMessage ?? 'Error adding reminder'),
                                    backgroundColor: Colors.red,
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

  Widget _buildDoctorAppointmentsTab() {
    return SafeArea(
      child: Consumer<AppointmentProvider>(
        builder: (context, appointmentProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Your Appointments',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                appointmentProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : appointmentProvider.appointments.isEmpty
                        ? Center(
                            child: Text(
                              'No appointments yet',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: appointmentProvider.appointments.length,
                            itemBuilder: (context, index) {
                              final appointment = appointmentProvider.appointments[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GlassCard(
                                  padding: const EdgeInsets.all(16),
                                  borderRadius: 14,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  appointment.title,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      appointment.doctorName,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white.withOpacity(0.9),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.location_on,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        appointment.location,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white.withOpacity(0.9),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.calendar_today,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '${date_utils.AppDateUtils.formatDate(appointment.date)} at ${appointment.time}',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white.withOpacity(0.9),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                                                onPressed: () => _showEditAppointmentDialog(appointment),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                                                onPressed: () async {
                                                  final success = await appointmentProvider.deleteAppointment(appointment.id);
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(success
                                                            ? 'Appointment deleted'
                                                            : 'Error deleting appointment'),
                                                        backgroundColor: Colors.white.withOpacity(0.2),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddAppointmentDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Add Appointment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.gradientBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddAppointmentDialog() {
    _showAppointmentDialog();
  }

  void _showEditAppointmentDialog(Appointment appointment) {
    _showAppointmentDialog(appointment: appointment);
  }

  void _showAppointmentDialog({Appointment? appointment}) {
    final titleController = TextEditingController(text: appointment?.title ?? '');
    final doctorController = TextEditingController(text: appointment?.doctorName ?? '');
    final locationController = TextEditingController(text: appointment?.location ?? '');
    DateTime selectedDate = appointment?.date ?? DateTime.now();
    TimeOfDay selectedTime = appointment != null
        ? TimeOfDay(
            hour: int.parse(appointment.time.split(':')[0]),
            minute: int.parse(appointment.time.split(':')[1].split(' ')[0]),
          )
        : TimeOfDay.now();

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
                    Text(
                      appointment == null ? 'Add Appointment' : 'Edit Appointment',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Title',
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
                    TextField(
                      controller: doctorController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Doctor's Name",
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
                    TextField(
                      controller: locationController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Location',
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
                        'Date: ${date_utils.AppDateUtils.formatDate(selectedDate)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: const Icon(Icons.calendar_today, color: Colors.white),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => selectedDate = d);
                      },
                    ),
                    ListTile(
                      title: Text(
                        'Time: ${selectedTime.format(context)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: const Icon(Icons.access_time, color: Colors.white),
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (t != null) setState(() => selectedTime = t);
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
                            if (titleController.text.trim().isEmpty ||
                                doctorController.text.trim().isEmpty ||
                                locationController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill all fields'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
                            final timeString = selectedTime.format(context);
                            final newAppointment = Appointment(
                              id: appointment?.id ?? '',
                              date: selectedDate,
                              time: timeString,
                              title: titleController.text.trim(),
                              doctorName: doctorController.text.trim(),
                              location: locationController.text.trim(),
                            );

                            bool success;
                            if (appointment == null) {
                              success = await appointmentProvider.addAppointment(newAppointment);
                            } else {
                              success = await appointmentProvider.updateAppointment(appointment.id, newAppointment);
                            }

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success
                                      ? (appointment == null
                                          ? 'Appointment added successfully'
                                          : 'Appointment updated successfully')
                                      : 'Error saving appointment'),
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                ),
                              );
                            }
                          },
                          child: Text(appointment == null ? AppTexts.save : AppTexts.update),
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
