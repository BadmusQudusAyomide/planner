import 'package:hive_flutter/hive_flutter.dart';
import '../models/event.dart';
import '../models/birthday.dart';

class LocalStorageService {
  static const String eventBoxName = 'events';
  static const String birthdayBoxName = 'birthdays';

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Adapters will be registered in main.dart or here
    // Hive.registerAdapter(EventAdapter());
    // Hive.registerAdapter(BirthdayAdapter());

    await Hive.openBox<Event>(eventBoxName);
    await Hive.openBox<Birthday>(birthdayBoxName);
  }

  Box<Event> getEventBox() => Hive.box<Event>(eventBoxName);
  Box<Birthday> getBirthdayBox() => Hive.box<Birthday>(birthdayBoxName);

  // Event methods
  List<Event> getAllEvents() => getEventBox().values.toList();
  Future<void> saveEvent(Event event) async => await getEventBox().put(event.id, event);
  Future<void> deleteEvent(String id) async => await getEventBox().delete(id);

  // Birthday methods
  List<Birthday> getAllBirthdays() => getBirthdayBox().values.toList();
  Future<void> saveBirthday(Birthday birthday) async => await getBirthdayBox().put(birthday.id, birthday);
  Future<void> deleteBirthday(String id) async => await getBirthdayBox().delete(id);
}
