import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/event.dart';
import '../models/birthday.dart';

class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    if (kIsWeb) {
      _isInitialized = true;
      return;
    }

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
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

    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    try {
      await androidImplementation?.requestNotificationsPermission();
    } catch (e, st) {
      debugPrint('Failed to request notification permission: $e');
      debugPrintStack(stackTrace: st);
    }

    _isInitialized = true;
  }

  Future<void> scheduleEventNotification(Event event) async {
    if (kIsWeb) {
      return;
    }

    await init();
    await cancelNotification(event.id);

    final parsedTime = Event.parseStoredTime(event.time);
    final scheduledDateTime = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
      parsedTime?.hour ?? 9,
      parsedTime?.minute ?? 0,
    );

    final tzDateTime = _toTzDateTime(scheduledDateTime);

    if (tzDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await _notifications.zonedSchedule(
      event.id.hashCode,
      'Event Reminder',
      event.title,
      tzDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'events_channel',
          'Events',
          channelDescription: 'Event reminder notifications',
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
    if (kIsWeb) {
      return;
    }

    await init();
    await cancelNotification(birthday.id);

    final now = DateTime.now();
    var nextBirthday = DateTime(
      now.year,
      birthday.date.month,
      birthday.date.day,
      9,
    );

    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(
        now.year + 1,
        birthday.date.month,
        birthday.date.day,
        9,
      );
    }

    final scheduledDate = _toTzDateTime(nextBirthday);
    await _notifications.zonedSchedule(
      birthday.id.hashCode,
      'Birthday Reminder',
      "It's ${birthday.name}'s birthday today!",
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'birthdays_channel',
          'Birthdays',
          channelDescription: 'Birthday reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          DateTimeComponents.dateAndTime,
    );
  }

  Future<void> cancelNotification(String id) async {
    if (kIsWeb) {
      return;
    }

    await _notifications.cancel(id.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    if (kIsWeb) {
      return;
    }

    await _notifications.cancelAll();
  }

  Future<void> showTestNotification() async {
    if (kIsWeb) {
      return;
    }

    await init();

    await _notifications.show(
      999001,
      'Planner Test',
      'If you can see this, local notifications are working.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Temporary test notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> scheduleTestNotification({
    Duration delay = const Duration(seconds: 5),
  }) async {
    if (kIsWeb) {
      return;
    }

    await init();

    final scheduledDate = _toTzDateTime(DateTime.now().add(delay));

    await _notifications.zonedSchedule(
      999002,
      'Planner Scheduled Test',
      'This reminder was scheduled a few seconds ago.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Temporary test notifications',
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

  tz.TZDateTime _toTzDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

}
