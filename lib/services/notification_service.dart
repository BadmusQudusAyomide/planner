import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/event.dart';
import '../models/birthday.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }

  Future<void> scheduleEventNotification(Event event) async {
    final scheduledDate = tz.TZDateTime.from(event.date, tz.local);
    
    // If the event has a time, we should ideally parse it and adjust scheduledDate.
    // For now, we'll notify at 9 AM on the day of the event if it's in the future.
    var notificationTime = scheduledDate.add(const Duration(hours: 9));
    
    if (notificationTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return; // Don't schedule for past events
    }

    await _notifications.zonedSchedule(
      event.id.hashCode,
      'Event Reminder',
      event.title,
      notificationTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'events_channel',
          'Events',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleBirthdayNotification(Birthday birthday) async {
    final now = DateTime.now();
    var nextBirthday = DateTime(now.year, birthday.date.month, birthday.date.day);
    
    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, birthday.date.month, birthday.date.day);
    }

    final scheduledDate = tz.TZDateTime.from(
      DateTime(nextBirthday.year, nextBirthday.month, nextBirthday.day, 9, 0),
      tz.local,
    );

    await _notifications.zonedSchedule(
      birthday.id.hashCode,
      'Birthday Reminder',
      "It's ${birthday.name}'s birthday today!",
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'birthdays_channel',
          'Birthdays',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.monthAndDay, // Repeat annually
    );
  }

  Future<void> cancelNotification(String id) async {
    await _notifications.cancel(id.hashCode);
  }
}
