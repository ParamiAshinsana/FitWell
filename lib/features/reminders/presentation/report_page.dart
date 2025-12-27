import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../routes/app_routes.dart';
import '../provider/reminder_provider.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReminderProvider>(context);

    int taken = 0, skipped = 0, pending = 0;

    for (final r in provider.reminders) {
      for (final t in r.times) {
        if (t.status == 'taken') taken++;
        if (t.status == 'skipped') skipped++;
        if (t.status == 'pending') pending++;
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          },
        ),
        title: const Text(
          AppTexts.reportAndHistory,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _tile(AppTexts.taken, taken, Colors.green),
                const SizedBox(height: 16),
                _tile(AppTexts.skipped, skipped, Colors.orange),
                const SizedBox(height: 16),
                _tile(AppTexts.pending, pending, Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(String title, int count, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

