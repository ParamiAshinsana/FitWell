import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/provider/auth_provider.dart';
import '../../water/provider/water_provider.dart';
import '../../reminders/provider/reminder_provider.dart';
import '../../workout/provider/workout_provider.dart';
import '../../meal/provider/meal_provider.dart';
import '../provider/dashboard_provider.dart';
import '../../../core/utils/date_utils.dart';
import '../../../routes/app_routes.dart';
import '../../reminders/data/reminder_model.dart';
import '../../workout/data/workout_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
      final mealProvider = Provider.of<MealProvider>(context, listen: false);
      final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
      workoutProvider.refresh();
      mealProvider.refresh();
      reminderProvider.refresh();
    });
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.workout);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.meal);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.reminders);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.water);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.measurements);
        break;
    }
  }

  Widget _buildSidebar(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    final userName = dashboardProvider.userName ?? 'User';
    
    return Drawer(
      backgroundColor: Colors.white.withOpacity(0.1),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.gradientTeal,
              AppColors.gradientBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: AppColors.gradientBlue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              ListTile(
                leading: const Icon(Icons.mood, color: Colors.white, size: 28),
                title: const Text(
                  'What do you feel today?',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.journal);
                },
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                onTap: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
        ],
      ),
      endDrawer: _buildSidebar(context),
      body: GradientBackground(
        child: SafeArea(
          child: Consumer5<DashboardProvider, WaterProvider, ReminderProvider, WorkoutProvider, MealProvider>(
        builder: (context, dashboardProvider, waterProvider, reminderProvider, workoutProvider, mealProvider, _) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          
          final todayWater = waterProvider.entries
              .where((entry) => AppDateUtils.isSameDate(entry.date, today))
              .fold(0, (sum, entry) => sum + entry.amount);

          final daysFromMonday = (today.weekday - 1) % 7;
          final weekStart = today.subtract(Duration(days: daysFromMonday));
          
          final weeklyCalories = List.generate(7, (index) {
            final date = weekStart.add(Duration(days: index));

            final dayWorkouts = workoutProvider.workouts
                .where((w) => AppDateUtils.isSameDate(w.date, date))
                .toList();
            final burnedCalories = dayWorkouts.fold(0, (sum, w) => sum + w.caloriesBurned);

            final dayMeals = mealProvider.meals
                .where((m) => AppDateUtils.isSameDate(m.date, date))
                .toList();
            final consumedCalories = dayMeals.fold(0, (sum, m) => sum + m.calories);
            
            return {
              'day': AppDateUtils.weekday(date),
              'calories': burnedCalories,
              'consumed': consumedCalories,
            };
          });

          ReminderModel? nextMed;
          DateTime? nextTime;
          for (var med in reminderProvider.reminders) {
            for (var time in med.times) {
              if (time.status == 'pending') {
                try {
                  final medDateTime = AppDateUtils.combine(now, time.time);
                  if (medDateTime.isAfter(now) && (nextTime == null || medDateTime.isBefore(nextTime!))) {
                    nextTime = medDateTime;
                    nextMed = med;
                  }
                } catch (e) {
                  continue;
                }
              }
            }
          }

          Map<String, dynamic>? nextMedicine;
          if (nextMed != null && nextTime != null) {
            final hour12 = nextTime!.hour > 12 ? nextTime!.hour - 12 : (nextTime!.hour == 0 ? 12 : nextTime!.hour);
            final nextTimeStr = hour12.toString().padLeft(2, '0') + 
                               ':' + 
                               nextTime!.minute.toString().padLeft(2, '0') + 
                               ' ' + 
                               (nextTime!.hour >= 12 ? 'p.m' : 'a.m');
            nextMedicine = {
              'name': nextMed.name,
              'time': nextTimeStr,
              'doses': nextMed.times.where((t) => t.status == 'pending').length,
            };
          }

          final userName = dashboardProvider.userName ?? 'User';
          final waterProgress = (todayWater / 2000.0).clamp(0.0, 1.0);
          final waterRemaining = (2000 - todayWater).clamp(0, 2000);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  children: [
                    Text(
                      'Hi $userName! 👋',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Today summary',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),

                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today water intake:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: waterProgress.clamp(0.0, 1.0),
                                  strokeWidth: 10,
                                  backgroundColor: Colors.white.withOpacity(0.3),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                                Text(
                                  '${(waterProgress * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$todayWater ml / 2000 ml',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'You have $waterRemaining ml to go!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                if (nextMedicine != null)
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.medication,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nextMedicine['name'] ?? 'Reminder',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Schedule to be taken by ${nextMedicine['time'] ?? ''}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Take ${nextMedicine['doses'] ?? 0} doses',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                },
                                icon: const Icon(Icons.close, color: Colors.white),
                                label: const Text('Skip', style: TextStyle(color: Colors.white)),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.white.withOpacity(0.5)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Took'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.gradientBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (nextMedicine != null) const SizedBox(height: 20),

                // Burned Calories Chart
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Consumed calories(Kcal/Day):',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: weeklyCalories.map((dayData) {
                            final calories = dayData['consumed'] as int;
                            final maxCalories = 2500.0;
                            final height = (calories / maxCalories * 150).clamp(20.0, 150.0);
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 30,
                                  height: height,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      calories.toString(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.gradientBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  dayData['day'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.fitness_center,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
