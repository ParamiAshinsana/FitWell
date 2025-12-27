import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/services/notification_service.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/meal/provider/meal_provider.dart';
import 'features/meal/presentation/meal_screen.dart';
import 'features/water/provider/water_provider.dart';
import 'features/water/presentation/water_screen.dart';
import 'features/medicine/data/medicine_model.dart';
import 'features/medicine/provider/medicine_provider.dart';
import 'features/medicine/presentation/medicine_screen.dart';
import 'features/workout/provider/workout_provider.dart';
import 'features/workout/presentation/workout_list_screen.dart';
import 'features/progress/provider/progress_provider.dart';
import 'features/progress/presentation/progress_screen.dart';
import 'features/dashboard/provider/dashboard_provider.dart';
import 'features/journal/provider/journal_provider.dart';
import 'features/journal/presentation/journal_screen.dart';
import 'routes/app_routes.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  try {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MedicineModelAdapter());
    }

    await Hive.openBox('mealsBox');
    await Hive.openBox('waterBox');
    await Hive.openBox<MedicineModel>('medicineBox');
    await Hive.openBox('journalBox');
    debugPrint('Hive boxes initialized successfully');
  } catch (e) {
    debugPrint('Hive initialization error: $e');

  }

  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint('Notification service initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => WaterProvider()),
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProxyProvider3<MealProvider, WaterProvider,
            WorkoutProvider, ProgressProvider>(
          create: (context) => ProgressProvider(
            mealProvider: Provider.of<MealProvider>(context, listen: false),
            waterProvider: Provider.of<WaterProvider>(context, listen: false),
            workoutProvider:
                Provider.of<WorkoutProvider>(context, listen: false),
          ),
          update: (context, mealProvider, waterProvider, workoutProvider,
                  previous) =>
              previous ??
              ProgressProvider(
                mealProvider: mealProvider,
                waterProvider: waterProvider,
                workoutProvider: workoutProvider,
              ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FitWell',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.login,
        routes: {
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.signup: (_) => const SignUpScreen(),
          AppRoutes.dashboard: (_) => const DashboardScreen(),
          AppRoutes.meal: (_) => const MealScreen(),
          AppRoutes.water: (_) => const WaterScreen(),
          AppRoutes.medicine: (_) => const MedicineScreen(),
          AppRoutes.workout: (_) => const WorkoutListScreen(),
          AppRoutes.progress: (_) => const ProgressScreen(),
          AppRoutes.journal: (_) => const JournalScreen(),
        },
      ),
    );
  }
}
