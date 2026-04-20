import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';

final localStorageServiceProvider = Provider((ref) => LocalStorageService());
final notificationServiceProvider = Provider((ref) => NotificationService());

final eventListProvider = StateNotifierProvider<EventListNotifier, List<Event>>((ref) {
  final service = ref.watch(localStorageServiceProvider);
  final notifications = ref.watch(notificationServiceProvider);
  return EventListNotifier(service, notifications);
});

class EventListNotifier extends StateNotifier<List<Event>> {
  final LocalStorageService _service;
  final NotificationService _notifications;

  EventListNotifier(this._service, this._notifications) : super([]) {
    _loadEvents();
  }

  void _loadEvents() {
    state = _service.getAllEvents();
  }

  Future<void> addEvent(Event event) async {
    await _service.saveEvent(event);
    try {
      await _notifications.scheduleEventNotification(event);
    } catch (e, st) {
      debugPrint('Failed to schedule event notification: $e');
      debugPrintStack(stackTrace: st);
    }
    _loadEvents();
  }

  Future<void> updateEvent(Event event) async {
    await _service.saveEvent(event); // Hive's put() handles updates
    try {
      await _notifications.scheduleEventNotification(event); // reschedule
    } catch (e, st) {
      debugPrint('Failed to update event notification: $e');
      debugPrintStack(stackTrace: st);
    }
    _loadEvents();
  }

  Future<void> deleteEvent(String id) async {
    await _service.deleteEvent(id);
    try {
      await _notifications.cancelNotification(id);
    } catch (e, st) {
      debugPrint('Failed to cancel event notification: $e');
      debugPrintStack(stackTrace: st);
    }
    _loadEvents();
  }

  List<Event> getEventsForDay(DateTime day) {
    return state.where((event) => 
      event.date.year == day.year && 
      event.date.month == day.month && 
      event.date.day == day.day
    ).toList();
  }
}
