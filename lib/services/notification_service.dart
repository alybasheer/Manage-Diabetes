import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleMedicationReminder({
    required String medicationName,
    required String dosage,
    required String time,
  }) async {
    try {
      final now = DateTime.now();
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      DateTime scheduledDate =
          DateTime(now.year, now.month, now.day, hour, minute);

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final tzLocation = tz.local;
      final tzScheduled = tz.TZDateTime.from(scheduledDate, tzLocation);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        medicationName.hashCode,
        '💊 Medication Reminder',
        'Time to take $medicationName ($dosage)',
        tzScheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminders',
            'Medication Reminders',
            channelDescription: 'Reminders for your medications',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            styleInformation: BigTextStyleInformation(
              'Take $medicationName ($dosage) as prescribed.',
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> cancelMedicationReminder(String medicationName) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(medicationName.hashCode);
    } catch (e) {
      print('Error canceling notification: $e');
    }
  }

  Future<void> cancelAllReminders() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      print('Error canceling all notifications: $e');
    }
  }
}
