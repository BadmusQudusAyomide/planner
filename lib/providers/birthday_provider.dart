import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/birthday.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';
import 'event_provider.dart';

final birthdayListProvider = StateNotifierProvider<BirthdayListNotifier, List<Birthday>>((ref) {
  final service = ref.watch(localStorageServiceProvider);
  final notifications = ref.watch(notificationServiceProvider);
  return BirthdayListNotifier(service, notifications);
});

class BirthdayListNotifier extends StateNotifier<List<Birthday>> {
  final LocalStorageService _service;
  final NotificationService _notifications;

  BirthdayListNotifier(this._service, this._notifications) : super([]) {
    _loadBirthdays();
  }

  void _loadBirthdays() {
    state = _service.getAllBirthdays();
  }

  Future<void> addBirthday(Birthday birthday) async {
    await _service.saveBirthday(birthday);
    try {
      await _notifications.scheduleBirthdayNotification(birthday);
    } catch (e, st) {
      debugPrint('Failed to schedule birthday notification: $e');
      debugPrintStack(stackTrace: st);
    }
    _loadBirthdays();
  }

  Future<void> updateBirthday(Birthday birthday) async {
    await _service.saveBirthday(birthday); // Hive handles updates
    try {
      await _notifications.scheduleBirthdayNotification(
        birthday,
      ); // reschedule
    } catch (e, st) {
      debugPrint('Failed to update birthday notification: $e');
      debugPrintStack(stackTrace: st);
    }
    _loadBirthdays();
  }

  Future<void> deleteBirthday(String id) async {
    await _service.deleteBirthday(id);
    try {
      await _notifications.cancelNotification(id);
    } catch (e, st) {
      debugPrint('Failed to cancel birthday notification: $e');
      debugPrintStack(stackTrace: st);
    }
    _loadBirthdays();
  }

  List<Birthday> getUpcomingBirthdays(int count) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    List<Birthday> sorted = List.from(state);
    sorted.sort((a, b) {
      final nextA = _nextOccurrence(a.date, today);
      final nextB = _nextOccurrence(b.date, today);
      return nextA.difference(today).inDays.compareTo(nextB.difference(today).inDays);
    });
    
    return sorted.take(count).toList();
  }

  DateTime _nextOccurrence(DateTime birthDate, DateTime today) {
    DateTime next = DateTime(today.year, birthDate.month, birthDate.day);
    if (next.isBefore(today)) {
      next = DateTime(today.year + 1, birthDate.month, birthDate.day);
    }
    return next;
  }
}
