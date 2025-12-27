import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Local notifications don't work on web, skip initialization
    if (kIsWeb) {
      return;
    }

    try {
      tz.initializeTimeZones();

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();

      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );
    } catch (e) {
      // Silently fail if notifications can't be initialized
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
  }) async {
    // Notifications don't work on web
    if (kIsWeb) {
      return;
    }

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(dateTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Reminder',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // Silently fail if notification can't be scheduled
    }
  }

  static Future<void> cancel(int id) async {
    if (kIsWeb) {
      return;
    }

    try {
      await _plugin.cancel(id);
    } catch (e) {
      // Silently fail if notification can't be cancelled
    }
  }
}

