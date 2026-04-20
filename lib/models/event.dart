import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

part 'event.g.dart';

@HiveType(typeId: 0)
class Event extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String? time;

  @HiveField(4)
  String tag; // Personal, Work, Other

  Event({
    required this.id,
    required this.title,
    required this.date,
    this.time,
    required this.tag,
  });

  factory Event.create({
    required String title,
    required DateTime date,
    String? time,
    required String tag,
  }) {
    return Event(
      id: const Uuid().v4(),
      title: title,
      date: date,
      time: time,
      tag: tag,
    );
  }

  Event copyWith({
    String? title,
    DateTime? date,
    String? time,
    String? tag,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      tag: tag ?? this.tag,
    );
  }

  static TimeOfDay? parseStoredTime(String? rawTime) {
    if (rawTime == null || rawTime.trim().isEmpty) {
      return null;
    }

    final normalized = rawTime
        .replaceAll('\u202f', ' ')
        .replaceAll('\u00a0', ' ')
        .trim();

    try {
      final parts = normalized.split(RegExp(r'\s+'));
      final timeParts = parts.first.split(':');
      var hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (parts.length > 1) {
        final meridiem = parts[1].toUpperCase();
        if (meridiem == 'PM' && hour < 12) {
          hour += 12;
        } else if (meridiem == 'AM' && hour == 12) {
          hour = 0;
        }
      }

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return null;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  static String? serializeTimeOfDay(TimeOfDay? time) {
    if (time == null) {
      return null;
    }

    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static String? formatStoredTime(BuildContext context, String? rawTime) {
    final parsed = parseStoredTime(rawTime);
    if (parsed == null) {
      return rawTime;
    }

    return parsed.format(context);
  }
}
