import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/event.dart';
import '../services/local_storage_service.dart';

final localStorageServiceProvider = Provider((ref) => LocalStorageService());

final eventListProvider = StateNotifierProvider<EventListNotifier, List<Event>>((ref) {
  final service = ref.watch(localStorageServiceProvider);
  return EventListNotifier(service);
});

class EventListNotifier extends StateNotifier<List<Event>> {
  final LocalStorageService _service;

  EventListNotifier(this._service) : super([]) {
    _loadEvents();
  }

  void _loadEvents() {
    state = _service.getAllEvents();
  }

  Future<void> addEvent(Event event) async {
    await _service.saveEvent(event);
    _loadEvents();
  }

  Future<void> deleteEvent(String id) async {
    await _service.deleteEvent(id);
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
