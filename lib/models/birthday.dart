import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'birthday.g.dart';

@HiveType(typeId: 1)
class Birthday extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String relationship;

  @HiveField(4, defaultValue: false)
  bool includeYear;

  Birthday({
    required this.id,
    required this.name,
    required this.date,
    required this.relationship,
    this.includeYear = false,
  });

  factory Birthday.create({
    required String name,
    required DateTime date,
    required String relationship,
    bool includeYear = false,
  }) {
    return Birthday(
      id: const Uuid().v4(),
      name: name,
      date: date,
      relationship: relationship,
      includeYear: includeYear,
    );
  }

  Birthday copyWith({
    String? name,
    DateTime? date,
    String? relationship,
    bool? includeYear,
  }) {
    return Birthday(
      id: id,
      name: name ?? this.name,
      date: date ?? this.date,
      relationship: relationship ?? this.relationship,
      includeYear: includeYear ?? this.includeYear,
    );
  }
}
