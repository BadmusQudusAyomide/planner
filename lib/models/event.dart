import 'package:hive/hive.dart';
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
}
