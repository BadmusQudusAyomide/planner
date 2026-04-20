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
  String relationship; // Friend, Family, Partner, Other

  Birthday({
    required this.id,
    required this.name,
    required this.date,
    required this.relationship,
  });

  factory Birthday.create({
    required String name,
    required DateTime date,
    required String relationship,
  }) {
    return Birthday(
      id: const Uuid().v4(),
      name: name,
      date: date,
      relationship: relationship,
    );
  }
}
